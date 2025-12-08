import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// PROVIDERS
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/responder_provider.dart';
import 'providers/notification_provider.dart';

// SERVICES
import 'services/auth_service.dart';
import 'services/student_service.dart';
import 'services/responder_service.dart';
import 'services/notification_service.dart';

// PAGES
import '../login_page.dart';
import '../splash_screen.dart';
import '../pages/StudentPages/student_dashboard.dart';
import '../pages/ResponderPages/responder_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProxyProvider<AuthProvider, StudentProvider>(
          create: (_) => StudentProvider(StudentService('')),
          update: (context, auth, previous) =>
              StudentProvider(StudentService(auth.token ?? '')),
        ),

        ChangeNotifierProxyProvider<AuthProvider, ResponderProvider>(
          create: (_) => ResponderProvider(ResponderService('')),
          update: (context, auth, previous) =>
              ResponderProvider(ResponderService(auth.token ?? '')),
        ),

        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(NotificationService('')),
          update: (context, auth, previous) =>
              NotificationProvider(NotificationService(auth.token ?? '')),
        ),
      ],
      child: MaterialApp(
        title: 'iAlert',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.grey[50],
          useMaterial3: true,

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),

        home: const SplashScreen(),

        routes: {
          '/login': (context) => const LoginPage(),
          '/student': (context) => const StudentDashboard(),
          '/responder': (context) => const ResponderDashboard(),
        },
      ),
    );
  }
}
