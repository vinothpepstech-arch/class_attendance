import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import 'admin_teacher_screen.dart';
import 'student_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              const Text('Sample Logins:'),
              TextButton(
                onPressed: () => _prefillLogin('admin@example.com', '12345678'),
                child: const Text('Login as Admin'),
              ),
              TextButton(
                onPressed: () => _prefillLogin('teacher@example.com', 'password'),
                child: const Text('Login as Teacher'),
              ),
              TextButton(
                onPressed: () => _prefillLogin('student@example.com', '12345678'),
                child: const Text('Login as Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _prefillLogin(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        await authProvider.login(
            _emailController.text, _passwordController.text);

        final role = authProvider.role;
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                role == 'student'
                    ? const StudentScreen()
                    : const AdminTeacherScreen(),
          ),
        );
      } on AuthException catch (e) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.message)));
      } catch (e) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('An unexpected error occurred')));
      }
    }
  }
}
