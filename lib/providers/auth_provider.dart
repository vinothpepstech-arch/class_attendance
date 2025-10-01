import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _role;
  String? _fullName;
  bool _isLoading = true;

  User? get user => _user;
  String? get role => _role;
  String? get fullName => _fullName;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = SupabaseService.client.auth.currentSession;
    if (session != null) {
      _user = session.user;
      await _fetchProfile();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    _user = response.user;
    await _fetchProfile();
    notifyListeners();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select('role, full_name')
          .eq('id', _user!.id)
          .single();
      _role = data['role'];
      _fullName = data['full_name'];
    } catch (e) {
      throw Exception('User profile not found. Please contact an administrator.');
    }
  }

  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
    _user = null;
    _role = null;
    _fullName = null;
    notifyListeners();
  }
}
