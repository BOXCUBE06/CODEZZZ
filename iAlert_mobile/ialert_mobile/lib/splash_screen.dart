import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../pages/StudentPages/student_dashboard.dart';
import '../pages/ResponderPages/responder_dashboard.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    if (auth.isAuthenticated) {
      if (auth.user?.role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResponderDashboard()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[700],
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, size: 100, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
