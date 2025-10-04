import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_login_provider.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch students when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentLoginProvider>(context, listen: false).fetchAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Log'),
      ),
      body: Consumer<StudentLoginProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: provider.students.length,
            itemBuilder: (context, index) {
              final student = provider.students[index];
              return ListTile(
                title: Text(student.name),
                subtitle: Text('${student.status ? 'Present' : 'Absent'} at ${student.lastUpdated}'),
                trailing: student.status
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
              );
            },
          );
        },
      ),
    );
  }
}
