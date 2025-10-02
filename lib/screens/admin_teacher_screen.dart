import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../theme.dart';
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
        children: const [
          AttendanceManagementScreen(),
          AnnouncementScreen(),
        ],
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
          .select();

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
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

  @override
  Widget build(BuildContext context) {
    final presentCount = _studentsData.where((s) => s['status'] == 'present').length;
    final absentCount = _studentsData.where((s) => s['status'] == 'absent').length;
    final totalStudents = _studentsData.length;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadStudentData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat('Present', presentCount.toString(), Colors.green),
                          _buildStat('Absent', absentCount.toString(), Colors.red),
                          _buildStat('Total', totalStudents.toString(), Theme.of(context).primaryColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Students',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Reason')),
                      ],
                      rows: _filteredStudentsData.map((student) {
                        final status = student['status'] as String?;
                        final reason = student['reason'] as String?;
                        return DataRow(
                          cells: [
                            DataCell(Text(student['full_name'])),
                            DataCell(
                              Text(
                                status ?? 'Not Marked',
                                style: TextStyle(
                                  color: status == 'present' ? Colors.green : (status == 'absent' ? Colors.red : null),
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: status == 'absent' ? () => _showReasonDialog(reason) : null,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(title),
      ],
    );
  }
}

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedOption;
  final List<String> _options = ['Assemble', 'Dismissal', 'Emergency', 'Event', 'Holiday'];

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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Post an Announcement',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedOption,
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
                    validator: (value) => value == null ? 'Please select a category' : null,
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
