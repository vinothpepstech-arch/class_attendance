import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  String _absenceReason = '';
  bool _isLoading = false;
  String? _studentName;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    await _loadStudentName();
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
    if (_absenceReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for your absence.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    try {
      final profileRes = await SupabaseService.client
          .from('profiles')
          .select('full_name')
          .eq('id', user!.id)
          .single();
      final studentName = profileRes['full_name'];

      // Insert new record for absence
      await SupabaseService.client.from('student_login').insert({
        'name': studentName,
        'status': false, // Always absent
        'reason': _absenceReason,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Absence reported successfully!')),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_studentName != null ? 'Hi, $_studentName!' : 'Student Dashboard'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudentData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Report an Absence',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      key: const ValueKey('reason_field'),
                      decoration: const InputDecoration(
                        labelText: 'Reason for Absence',
                        icon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
                      onChanged: (value) => _absenceReason = value,
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _submitAttendance,
                            icon: const Icon(Icons.send),
                            label: const Text('Submit'),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
