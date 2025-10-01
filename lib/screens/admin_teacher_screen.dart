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
  List<Map<String, dynamic>> _studentsData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final studentsRes = await SupabaseService.client
          .from('profiles')
          .select('id, full_name')
          .eq('role', 'student');

      final studentIds = studentsRes.map((s) => s['id'] as String).toList();
      final today = DateTime.now().toIso8601String().split('T').first;

      final attendanceRes = await SupabaseService.client
          .from('attendance')
          .select('student_id, status, reason')
          .inFilter('student_id', studentIds)
          .eq('date', today);

      final attendanceMap = {
        for (var record in attendanceRes)
          record['student_id']: {
            'status': record['status'],
            'reason': record['reason']
          }
      };

      final combinedData = studentsRes.map((student) {
        final attendance = attendanceMap[student['id']];
        return {
          'id': student['id'],
          'full_name': student['full_name'],
          'status': attendance?['status'],
          'reason': attendance?['reason'],
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _studentsData = combinedData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _showReasonDialog(String? reason) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reason for Absence'),
          content: Text(reason ?? 'No reason provided.'),
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

  void _updateAttendance(String studentId, String status) async {
    try {
      await SupabaseService.client.from('attendance').upsert({
        'student_id': studentId,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'status': status,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance updated to ${status.toUpperCase()}')),
      );
      _loadStudentData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating attendance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _studentsData.where((s) => s['status'] == 'present').length;
    final absentCount = _studentsData.where((s) => s['status'] == 'absent').length;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadStudentData,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Present', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 8),
                              Text('$presentCount', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.green)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Absent', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 8),
                              Text('$absentCount', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _studentsData.length,
                    itemBuilder: (context, index) {
                      final student = _studentsData[index];
                      final status = student['status'] as String?;
                      final reason = student['reason'] as String?;

                      IconData statusIcon;
                      Color statusColor;
                      String statusText;

                      switch (status) {
                        case 'present':
                          statusIcon = Icons.check_circle;
                          statusColor = Colors.green;
                          statusText = 'Present';
                          break;
                        case 'absent':
                          statusIcon = Icons.cancel;
                          statusColor = Colors.red;
                          statusText = 'Absent';
                          break;
                        default:
                          statusIcon = Icons.help_outline;
                          statusColor = Colors.grey;
                          statusText = 'Not Marked';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(statusIcon, color: statusColor),
                          title: Text(student['full_name']),
                          subtitle: Text(statusText),
                          onTap: status == 'absent' ? () => _showReasonDialog(reason) : null,
                          trailing: PopupMenuButton<String>(
                            onSelected: (newStatus) => _updateAttendance(student['id'], newStatus),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'present', child: Text('Mark Present')),
                              const PopupMenuItem(value: 'absent', child: Text('Mark Absent')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final List<String> _options = ['Assemble', 'Dismissal', 'Emergency', 'Event', 'Holiday'];
  String? _selectedOption;
  bool _isLoading = false;

  Future<void> _postAnnouncement() async {
    if (_selectedOption == null) return;

    setState(() => _isLoading = true);

    try {
      await SupabaseService.client.from('announcements').insert({
        'title': _selectedOption,
        'content': 'This is an announcement for ${_selectedOption!.toLowerCase()}.',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted successfully!')),
        );
        setState(() => _selectedOption = null);
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
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Post an Announcement',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: _options.map((option) {
                    return ChoiceChip(
                      label: Text(option),
                      selected: _selectedOption == option,
                      onSelected: (selected) {
                        setState(() => _selectedOption = selected ? option : null);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _selectedOption != null ? _postAnnouncement : null,
                        child: const Text('Post Announcement'),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
