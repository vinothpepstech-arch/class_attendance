import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class StudentLogin {
  final int id;
  final String name;
  bool status;
  final String? reason;
  final DateTime lastUpdated;

  StudentLogin({
    required this.id,
    required this.name,
    required this.status,
    this.reason,
    required this.lastUpdated,
  });

  factory StudentLogin.fromMap(Map<String, dynamic> map) {
    return StudentLogin(
      id: map['id'],
      name: map['name'],
      status: map['status'],
      reason: map['reason'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }
}

class StudentLoginProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StudentLogin> _students = [];
  List<StudentLogin> get students => _students;

  Future<void> fetchAttendance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.client.from('student_login').select().order('last_updated', ascending: false);
      _students = data.map((item) => StudentLogin.fromMap(item)).toList();
    } catch (e) {
      // Handle error
    }
    notifyListeners();
  }

  Future<void> addStudentAttendance(String name, bool status, {String? reason}) async {
    try {
      await SupabaseService.client.from('student_login').insert({
        'name': name,
        'status': status,
        'reason': reason,
      });
      fetchAttendance(); // Refresh the list
    } catch (e) {
      // Handle error
    }
  }
}
