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
      Provider.of<StudentLoginProvider>(context, listen: false).fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentLoginProvider>(
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
              subtitle: Text(student.status ? 'Present' : 'Absent'),
              trailing: Switch(
                value: student.status,
                onChanged: (newStatus) {
                  provider.updateStudentStatus(student.id, newStatus);
                },
              ),
            );
          },
        );
      },
    );
  }
}
