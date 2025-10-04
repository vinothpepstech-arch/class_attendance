import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {static const String _url = 'https://sxtejkwxnuxkomrdxhvf.supabase.co';
  static const String _key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4dGVqa3d4bnV4a29tcmR4aHZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNjEzNjMsImV4cCI6MjA3NDczNzM2M30.XIpjm6BVx0k2mvTXq_srOIGX17QyAZ6vS1RUMggL3uo';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: _url,
      anonKey: _key,
    );
  }
}
