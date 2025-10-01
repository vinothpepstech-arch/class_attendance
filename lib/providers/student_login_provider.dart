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

  Future<void> fetchStudents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.client.from('student_login').select();
      _students = data.map((item) => StudentLogin.fromMap(item)).toList();
    } catch (e) {
      // Handle error
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateStudentStatus(int id, bool status) async {
    try {
      await SupabaseService.client
          .from('student_login')
          .update({'status': status, 'last_updated': DateTime.now().toIso8601String()})
          .eq('id', id);

      final index = _students.indexWhere((student) => student.id == id);
      if (index != -1) {
        _students[index].status = status;
        notifyListeners();
      }
    } catch (e) {
      // Handle error
      print(e);
    }
  }
}
