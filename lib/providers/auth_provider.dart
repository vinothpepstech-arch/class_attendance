import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _role;

  User? get user => _user;
  String? get role => _role;

  Future<void> login(String email, String password) async {
    final response = await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    _user = response.user;
    await _fetchRole();
    notifyListeners();
  }

  Future<void> _fetchRole() async {
    final data = await SupabaseService.client
        .from('profiles')
        .select('role')
        .eq('id', _user!.id)
        .single();
    _role = data['role'];
  }

  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
    _user = null;
    _role = null;
    notifyListeners();
  }
}
