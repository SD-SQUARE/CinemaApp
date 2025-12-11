import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final String _HOST = "192.168.1.22";
  static final String _URL = "http://${_HOST}:54321";
  static final String _ANON_KEY =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";
  static Future<void> init() async {
    await Supabase.initialize(
      url: _URL,
      anonKey: _ANON_KEY,
      // localStorage is automatically handled by supabase_flutter
    );
  }

  static String getURL() {
    return _URL;
  }

  static Future<void> addFcmToken(SupabaseClient dbClient, String token) async {
    final response = await dbClient
        .from('vendor_device_token')
        .upsert({
          'token': token,
          'platform': Platform.operatingSystem.toString(),
        })
        .eq('id', 1);

    print("Supabase FCM token upsert response: ${DateTime.now()}");
  }

  static SupabaseClient get client => Supabase.instance.client;
}
