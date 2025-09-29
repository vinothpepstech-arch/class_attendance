import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _url = 'YOUR_SUPABASE_URL';
  static const String _key = 'YOUR_SUPABASE_KEY';
  static final SupabaseClient _client = SupabaseClient(_url, _key);

  static SupabaseClient get client => _client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: _url,
      anonKey: _key,
    );
  }
}
