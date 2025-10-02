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
  bool _isPresent = true;
  String _absenceReason = '';
  bool _isLoading = false;
  String? _studentName;
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    await _loadStudentName();
    await _loadAnnouncements();
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

  Future<void> _loadAnnouncements() async {
    try {
      final response = await SupabaseService.client
          .from('announcements')
          .select()
          .order('created_at', ascending: false)
          .limit(5);
      if (mounted) {
        setState(() {
          _announcements = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _submitAttendance() async {
    setState(() => _isLoading = true);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    try {
      final profileRes = await SupabaseService.client
          .from('profiles')
          .select('full_name')
          .eq('id', user!.id)
          .single();
      final studentName = profileRes['full_name'];

      await SupabaseService.client
          .from('student_login')
          .update({
            'status': _isPresent,
            'reason': _isPresent ? null : _absenceReason,
            'last_updated': DateTime.now().toIso8601String(),
          })
          .eq('name', studentName);

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
        print(e);
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
                      'Mark Today\'s Attendance',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ToggleButtons(
                      isSelected: [_isPresent, !_isPresent],
                      onPressed: (index) => setState(() => _isPresent = index == 0),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline),
                              SizedBox(width: 8),
                              Text('Present'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(Icons.cancel_outlined),
                              SizedBox(width: 8),
                              Text('Absent'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: !_isPresent
                          ? TextField(
                              key: const ValueKey('reason_field'),
                              decoration: const InputDecoration(
                                labelText: 'Reason for Absence',
                                icon: Icon(Icons.notes),
                              ),
                              maxLines: 3,
                              onChanged: (value) => _absenceReason = value,
                            )
                          : const SizedBox(key: ValueKey('empty_sized_box')),
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
