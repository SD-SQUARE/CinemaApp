create table public.customers (
  id uuid not null default gen_random_uuid (),
  uid uuid not null,
  name text not null,
  constraint customers_pkey primary key (id),
  constraint customers_uid_key unique (uid),
  constraint customers_uid_fkey foreign KEY (uid) references auth.users (id)
) TABLESPACE pg_default;


create table public.movies (
  id uuid not null default gen_random_uuid (),
  title text not null,
  description text not null,
  price double precision not null,
  image text not null,
  seats_number integer null default 47,
  "createdAt" timestamp with time zone null default now(),
  constraint movies_pkey primary key (id),
  constraint movies_title_key unique (title),
  constraint movies_image_key unique (image)
) TABLESPACE pg_default;

create table public.timeshows (
  id uuid not null default gen_random_uuid (),
  mid uuid not null,
  time timestamp with time zone not null,
  constraint timeshows_pkey primary key (id),
  constraint timeshows_mid_time_key unique (mid, "time"),
  constraint timeshows_mid_fkey foreign KEY (mid) references movies (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.reservations (
  id uuid not null default gen_random_uuid (),
  cid uuid not null,
  mid uuid not null,
  tid uuid not null,
  seat text not null,
  test text null,
  constraint reservations_pkey primary key (id),
  constraint reservations_mid_tid_seat_key unique (mid, tid, seat),
  constraint reservations_cid_fkey foreign KEY (cid) references customers (id) on delete CASCADE,
  constraint reservations_mid_fkey foreign KEY (mid) references movies (id) on delete CASCADE,
  constraint reservations_tid_fkey foreign KEY (tid) references timeshows (id) on delete CASCADE
) TABLESPACE pg_default;


create table public.tickets (
  id uuid not null default gen_random_uuid (),
  total_price numeric not null,
  seats text[] not null,
  cid uuid not null,
  mid uuid not null,
  tid uuid not null,
  created_at timestamp with time zone not null default now(),
  constraint tickets_pkey primary key (id),
  constraint tickets_cid_fkey foreign KEY (cid) references customers (id) on delete CASCADE,
  constraint tickets_mid_fkey foreign KEY (mid) references movies (id) on delete CASCADE,
  constraint tickets_tid_fkey foreign KEY (tid) references timeshows (id) on delete CASCADE,
  constraint tickets_total_price_check check ((total_price > (0)::numeric))
) TABLESPACE pg_default;

alter table reservations  replica identity full;

create table vendor_device_token (
  id int primary key default 1,
  token text not null,
  platform text,
  updated_at timestamptz default now()
);


ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;


create policy "allow insert"
on tickets
for insert
to public
with check (true);


-- Allow Edge Functions to read "tickets"
create policy "edge select tickets"
on tickets
for select
to public
using (true);

-- Allow reading tokens table
create policy "edge select vendor tokens"
on vendor_device_token
for select
to public
using (true);

create or replace function notify_ticket_insert()
returns trigger as $$
begin
  perform
    net.http_post(
      url := 'http://192.168.1.22:54321/functions/v1/ticket_confirm',
      headers := jsonb_build_object(
        'Content-Type','application/json',
        'Authorization','Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
      ),
      body := jsonb_build_object('ticket_id', new.id)
    );

  return new;
end;
$$ language plpgsql;

create trigger on_ticket_insert
after insert on tickets
for each row
execute function notify_ticket_insert();


create or replace function get_tickets_summary()
returns jsonb
language plpgsql
as $$
declare
  v_total_tickets int;
  v_total_price numeric;
  v_ticket_list jsonb;
begin
  -- 1. Total number of tickets
  select count(*) into v_total_tickets from tickets;

  -- 2. Total price sum
  select coalesce(sum(total_price), 0) into v_total_price from tickets;

  -- 3. Ticket list with details
  select jsonb_agg(
    jsonb_build_object(
      'ticket_id', t.id,
      'customer_name', c.name,
      'movie_name', m.title,
      'show_time', ts.time,
      'price', m.price,
      'total_price', t.total_price
    )
  )
  into v_ticket_list
  from tickets t
  join customers c on t.cid = c.id
  join movies m on t.mid = m.id
  join timeshows ts on t.tid = ts.id;

  -- 4. Return final JSON object
  return jsonb_build_object(
    'total_tickets', v_total_tickets,
    'total_price', v_total_price,
    'tickets', coalesce(v_ticket_list, '[]'::jsonb)
  );
end;
$$;

-- delete ticket function

create or replace function cancel_ticket( p_ticket_id uuid )
returns jsonb
language plpgsql
security definer
as $$
declare v_cid uuid; v_tid uuid; v_mid uuid; v_showtime timestamptz; v_seats text[]; -- Variable to hold the array of seats
begin select cid, tid, mid, seats into v_cid, v_tid, v_mid, v_seats from tickets where id = p_ticket_id;

if v_cid is null then return jsonb_build_object('ok', false, 'reason', 'ticket_not_found'); end if;

if v_cid not in (select id from customers where uid = auth.uid()) then return jsonb_build_object('ok', false, 'reason', 'not_owner'); end if;

select time into v_showtime from timeshows where id = v_tid;

if now() >= v_showtime then return jsonb_build_object('ok', false, 'reason', 'expired'); end if;

delete from reservations where cid = v_cid and mid = v_mid and tid = v_tid and seat = any(v_seats); 

delete from tickets where id = p_ticket_id;

return jsonb_build_object('ok', true, 'ticket_id', p_ticket_id);
end;
$$;


-- statistcs Function

create or replace function get_tickets_summary()
returns jsonb
language plpgsql
as $$
declare
  v_total_tickets int;
  v_total_price numeric;
  v_ticket_list jsonb;
begin
  -- 1. Total number of tickets
  select count(*) into v_total_tickets from tickets;

  -- 2. Total price sum
  select coalesce(sum(total_price), 0) into v_total_price from tickets;

  -- 3. Ticket list with details
  select jsonb_agg(
    jsonb_build_object(
      'ticket_id', t.id,
      'customer_name', c.name,
      'movie_name', m.title,
      'show_time', ts.time,
      'price', m.price,
      'total_price', t.total_price
    )
  )
  into v_ticket_list
  from tickets t
  join customers c on t.cid = c.id
  join movies m on t.mid = m.id
  join timeshows ts on t.tid = ts.id;

  -- 4. Return final JSON object
  return jsonb_build_object(
    'total_tickets', v_total_tickets,
    'total_price', v_total_price,
    'tickets', coalesce(v_ticket_list, '[]'::jsonb)
  );
end;
$$;
