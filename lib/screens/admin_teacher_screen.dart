import 'package:flutter/material.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import 'student_login_screen.dart';

class AdminTeacherScreen extends StatefulWidget {
  const AdminTeacherScreen({super.key});

  @override
  State<AdminTeacherScreen> createState() => _AdminTeacherScreenState();
}

class _AdminTeacherScreenState extends State<AdminTeacherScreen> {
  int _selectedIndex = 0;

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin/Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          AttendanceManagementScreen(),
          AnnouncementScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Announcements',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  List<Map<String, dynamic>> _students = [];
  int _presentCount = 0;
  int _absentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _loadAttendanceSummary();
  }

  Future<void> _loadStudents() async {
    final data = await SupabaseService.client
        .from('student_login')
        .select('id, name, status, reason')
        .order('name', ascending: true);
    if (!mounted) return;
    setState(() => _students = data);
  }

  Future<void> _loadAttendanceSummary() async {
    final data = await SupabaseService.client.from('student_login').select('status');

    int present = 0;
    int absent = 0;
    for (final row in data) {
      if (row['status'] == true) {
        present++;
      } else {
        absent++;
      }
    }
    if (!mounted) return;
    setState(() {
      _presentCount = present;
      _absentCount = absent;
    });
  }

  void _showReasonDialog(String reason) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reason for Absence'),
          content: Text(reason.isEmpty ? 'No reason provided.' : reason),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Attendance: $_presentCount Present, $_absentCount Absent',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              final statusText = student['status'] ? 'Present' : 'Absent';
              return ListTile(
                title: Text(student['name']),
                subtitle: Text('Status: $statusText'),
                onTap: () {
                  if (student['status'] == false) {
                    _showReasonDialog(student['reason'] ?? 'No reason provided.');
                  }
                },
                trailing: PopupMenuButton<bool>(
                  onSelected: (status) =>
                      _updateAttendance(student['id'], status),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: true, child: Text('Present')),
                    const PopupMenuItem(value: false, child: Text('Absent')),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _updateAttendance(int studentId, bool status) async {
    await SupabaseService.client
        .from('student_login')
        .update({
          'status': status,
          'last_updated': DateTime.now().toIso8601String(),
        })
        .eq('id', studentId);
    _loadAttendanceSummary();
    // Reload students to get the updated status
    _loadStudents();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated for ${status ? 'PRESENT' : 'ABSENT'}')));
  }
}
class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final List<String> _options = [
    'Assemble',
    'Dismissal',
    'Emergency',
    'Event',
    'Holiday'
  ];
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Select Announcement Type',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _options.map((option) {
              return ChoiceChip(
                label: Text(option),
                selected: _selectedOption == option,
                onSelected: (selected) {
                  setState(() {
                    _selectedOption = selected ? option : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _selectedOption != null ? _postAnnouncement : null,
            child: const Text('Post Announcement'),
          ),
        ],
      ),
    );
  }

  void _postAnnouncement() async {
    if (_selectedOption == null) return;

    final audioFile = '${_selectedOption!.toLowerCase()}.mp3';

    try {
      await SupabaseService.client.from('play_queue').insert({
        'audio_file': audioFile,
      });

      if (!mounted) return;
      setState(() => _selectedOption = null);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Announcement posted to play queue')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting announcement: $e')),
      );
    }
  }
}
