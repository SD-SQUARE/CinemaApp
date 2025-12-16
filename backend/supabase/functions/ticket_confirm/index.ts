import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import serviceAccount from "./service_account.json" assert { type: "json" };

// Convert PEM private key to ArrayBuffer
function pemToArrayBuffer(pem: string): Uint8Array {
  const b64 = pem.replace(/-----BEGIN PRIVATE KEY-----/, '')
                 .replace(/-----END PRIVATE KEY-----/, '')
                 .replace(/\s/g, '');
  const binary = atob(b64);
  const buffer = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) buffer[i] = binary.charCodeAt(i);
  return buffer;
}

// Base64Url encode
function base64UrlEncode(buffer: Uint8Array): string {
  let binary = "";
  buffer.forEach((b) => binary += String.fromCharCode(b));
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

// Sign JWT manually with RS256
async function createSignedJWT(): Promise<string> {
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: serviceAccount.token_uri,
    iat: now,
    exp: now + 3600,
  };

  const encodedHeader = base64UrlEncode(new TextEncoder().encode(JSON.stringify(header)));
  const encodedPayload = base64UrlEncode(new TextEncoder().encode(JSON.stringify(payload)));
  const unsignedJWT = `${encodedHeader}.${encodedPayload}`;

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(serviceAccount.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signatureBuffer = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(unsignedJWT)
  );

  const signature = base64UrlEncode(new Uint8Array(signatureBuffer));
  return `${unsignedJWT}.${signature}`;
}

// Get access token from Google OAuth
async function getAccessToken(): Promise<string> {
  const jwt = await createSignedJWT();
  const res = await fetch(serviceAccount.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(`Failed to get access token: ${JSON.stringify(data)}`);
  return data.access_token;
}

// Send FCM notification
async function sendFCM(token: string, ticket:any, accessToken: string) {
  const res = await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token,
        notification: {
          title: `The Customer ${ticket.customers.name} has Bought a ticket for ${ticket.movies.title}.`,
          body: `Seats: ${ticket.seats.join(", ")} | Total: $${ticket.total_price} | Show Time: ${new Date(ticket.timeshows.time).toLocaleString()}`,
        },
        data: {
          movie_id: ticket.movies.id.toString(),
          navigate_to: "movie-details", // your Flutter screen route
        }
      },
    }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(`FCM failed: ${JSON.stringify(data)}`);
  return data;
}

Deno.serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get("SUPABASEURL") ?? "",
      Deno.env.get("SUPABASEANON_KEY") ?? "",
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
    );

    // Get latest ticket
    const { data: ticket, error: ticketError } = await supabase
          .from("tickets")
          .select(`
            id,
            total_price,
            seats,
            created_at,
            customers:cid (
              id,
              uid,
              name
            ),
            movies:mid (
              id,
              title,
              description,
              price,
              image
            ),
            timeshows:tid (
              id,
              time
            )
          `)
          .order("created_at", { ascending: false })
          .limit(1)
          .maybeSingle();

    if (ticketError) throw ticketError;
    if (!ticket) throw new Error("No ticket found or RLS blocked access");

    // Get FCM tokens
    const { data: tokens, error: tokenError } = await supabase
      .from("vendor_device_token")
      .select("*");
    if (tokenError) throw tokenError;
    if (!tokens || tokens.length === 0) throw new Error("No FCM tokens found");

    const accessToken = await getAccessToken();

    // Send notifications in parallel
    await Promise.all(tokens.map(t => t.token ? sendFCM(t.token, ticket, accessToken) : null));

    return new Response(JSON.stringify({ data: ticket, sent: true }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });

  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ message: err?.message ?? err }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});
