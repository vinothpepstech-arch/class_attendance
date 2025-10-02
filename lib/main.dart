import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'School Management',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isLoading) {
                  return const SplashScreen();
                }
                if (auth.user == null) {
                  return const LoginScreen();
                }
                if (auth.role == 'student') {
                  return const StudentScreen();
                }
                return const AdminTeacherScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
