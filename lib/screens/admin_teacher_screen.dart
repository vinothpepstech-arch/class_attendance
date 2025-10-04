import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../theme.dart';
import 'package:attendance_pt/screens/create_student_screen.dart';
import 'login_screen.dart';

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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmationDialog,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [AttendanceManagementScreen(), AnnouncementScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement_outlined),
            label: 'Announcements',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CreateStudentScreen(),
                ));
              },
              child: const Icon(Icons.add),
            )
          : null,
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
  List<Map<String, dynamic>> _filteredStudentsData = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudentData();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final studentLogins = await SupabaseService.client
          .from('student_login')
          .select()
          .order('last_updated', ascending: false);

      final combinedData = (studentLogins as List).map((student) {
        return {
          'id': student['id'],
          'full_name': student['name'],
          'status': student['status'] ? 'present' : 'absent',
          'reason': student['reason'],
        };
      }).toList();

      if (mounted) {
        setState(() {
          _studentsData = combinedData;
          _filteredStudentsData = combinedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudentsData = _studentsData.where((student) {
        return student['full_name'].toLowerCase().contains(query);
      }).toList();
    });
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

  Future<void> _markAsPresent(String studentName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Present'),
        content: Text('Are you sure you want to mark $studentName as present?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupabaseService.client.from('student_login').insert({
          'name': studentName,
          'status': true,
        });
        _loadStudentData(); // Refresh the data
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error marking present: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadStudentData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AttendanceStatsCard(studentsData: _studentsData),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search Students',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _StudentDataTable(
                    studentsData: _filteredStudentsData,
                    onMarkPresent: _markAsPresent,
                    onShowReason: _showReasonDialog,
                  ),
                ],
              ),
            ),
          );
  }
}

class _AttendanceStatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> studentsData;

  const _AttendanceStatsCard({required this.studentsData});

  @override
  Widget build(BuildContext context) {
    final presentCount = studentsData.where((s) => s['status'] == 'present').length;
    final absentCount = studentsData.where((s) => s['status'] == 'absent').length;
    final totalStudents = studentsData.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildStat(context, 'Present', presentCount.toString(), Colors.green),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildStat(context, 'Absent', absentCount.toString(), Colors.red),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildStat(context, 'Total', totalStudents.toString(), Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _StudentDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> studentsData;
  final void Function(String) onMarkPresent;
  final void Function(String?) onShowReason;

  const _StudentDataTable({
    required this.studentsData,
    required this.onMarkPresent,
    required this.onShowReason,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dataRowMinHeight: 60,
          dataRowMaxHeight: 80,
          headingRowColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => Theme.of(context).primaryColor.withAlpha(50),
          ),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(studentsData.length, (index) {
            final student = studentsData[index];
            final status = student['status'] as String?;
            final reason = student['reason'] as String?;
            final isEven = index.isEven;

            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (isEven) {
                    return Colors.grey.withAlpha(25);
                  }
                  return null; // Use default value for other states and odd rows.
                },
              ),
              cells: [
                DataCell(Text(student['full_name'])),
                DataCell(
                  Text(
                    status ?? 'Not Marked',
                    style: TextStyle(
                      color: status == 'present'
                          ? Colors.green
                          : (status == 'absent' ? Colors.red : null),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                        tooltip: 'Mark Present',
                        onPressed: () => onMarkPresent(student['full_name']),
                      ),
                      if (status == 'absent')
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          tooltip: 'Show Reason',
                          onPressed: () => onShowReason(reason),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AudioAnnouncementForm();
  }
}



class AudioAnnouncementForm extends StatefulWidget {
  const AudioAnnouncementForm({super.key});

  @override
  State<AudioAnnouncementForm> createState() => _AudioAnnouncementFormState();
}

class _AudioAnnouncementFormState extends State<AudioAnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedOption;
  final List<String> _options = [
    'Assemble',
    'cs_today',
    'googleform',
    'pmss',
    'retest',
  ];

  Future<void> _postAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await SupabaseService.client.from('play_queue').insert({
        'audio_file': '${_selectedOption!.toLowerCase()}.mp3',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted successfully!')),
        );
        setState(() {
          _selectedOption = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Post an Audio Announcement',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedOption,
                    hint: const Text('Select Category'),
                    items: _options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedOption = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _postAnnouncement,
                          icon: const Icon(Icons.send),
                          label: const Text('Post Announcement'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
