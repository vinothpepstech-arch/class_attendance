import 'package:flutter/material.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  bool _isPresent = true;
  String _absenceReason = '';
  bool _isLoading = false;
  String? _studentName;

  @override
  void initState() {
    super.initState();
    _loadStudentName();
  }

  Future<void> _loadStudentName() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      final response = await SupabaseService.client
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .single();
      if (mounted) {
        setState(() {
          _studentName = response['full_name'];
        });
      }
    }
  }

  Future<void> _submitAttendance() async {
    setState(() => _isLoading = true);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    try {
      await SupabaseService.client.from('attendance').upsert({
        'student_id': user!.id,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'status': _isPresent ? 'present' : 'absent',
        'reason': _isPresent ? null : _absenceReason,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_studentName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Welcome, $_studentName!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mark Today\'s Attendance',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ToggleButtons(
                    isSelected: [_isPresent, !_isPresent],
                    onPressed: (index) => setState(() => _isPresent = index == 0),
                    borderRadius: BorderRadius.circular(8),
                    fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    selectedColor: Theme.of(context).primaryColor,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Present'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Absent'),
                      ),
                    ],
                  ),
                  if (!_isPresent) ...[
                    const SizedBox(height: 24),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Reason for Absence',
                      ),
                      maxLines: 3,
                      onChanged: (value) => _absenceReason = value,
                    ),
                  ],
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitAttendance,
                          child: const Text('Submit'),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
