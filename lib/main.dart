import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './providers/auth_provider.dart';
import './screens/login_screen.dart';
import './screens/splash_screen.dart';
import './screens/student_screen.dart';
import './screens/admin_teacher_screen.dart';
import './services/supabase_service.dart';
import './theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'School Management',
            theme: AppTheme.lightTheme,
            home: auth.isLoading
                ? const SplashScreen()
                : auth.user == null
                    ? const LoginScreen()
                    : auth.role == 'student'
                        ? const StudentScreen()
                        : const AdminTeacherScreen(),
          );
        },
      ),
    );
  }
}
