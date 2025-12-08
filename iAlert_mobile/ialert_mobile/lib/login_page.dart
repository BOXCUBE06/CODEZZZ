import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/components/login_widgets.dart';
import '../pages/StudentPages/student_dashboard.dart';
import '../pages/ResponderPages/responder_dashboard.dart';
import 'providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  
  // State
  String _userType = 'student';
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Theme Logic
  Color get _activePrimary => _userType == 'student' 
      ? const Color(0xFFD32F2F)  // Student Red
      : const Color(0xFF1565C0); // Responder Blue

  Color get _activeSecondary => _userType == 'student'
      ? const Color(0xFFEF5350)
      : const Color(0xFF42A5F5);

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      type: _userType,
      id: _idController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final role = authProvider.user?.role;
      if (role == 'student') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentDashboard()));
      } else if (role == 'responder') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResponderDashboard()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unknown user role.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // --- SECTION 1: Dynamic Background Header ---
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: size.height * 0.45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_activePrimary, _activeSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(60)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon Animation
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          _userType == 'student' 
                              ? Icons.warning_amber_rounded 
                              : Icons.shield_moon_rounded,
                          key: ValueKey(_userType),
                          size: 80,
                          // UPDATED: withValues
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'iAlert System',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 60), 
                    ],
                  ),
                ),
              ),

              // --- SECTION 2: Floating Form Card ---
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        // UPDATED: withValues
                        color: _activePrimary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // COMPONENT: Role Switcher
                        RoleToggleSwitch(
                          activeRole: _userType,
                          activeColor: _activePrimary,
                          onRoleChanged: (val) {
                            setState(() {
                              _userType = val;
                              _idController.clear();
                            });
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Text(
                          _userType == 'student' ? 'Student Portal' : 'Responder Access',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // COMPONENT: ID Input
                        ModernTextField(
                          controller: _idController,
                          label: _userType == 'student' ? 'Student ID' : 'Badge / Email',
                          hint: _userType == 'student' ? '202X-XXXXX' : 'officer@ialert.com',
                          icon: _userType == 'student' ? Icons.badge_outlined : Icons.email_outlined,
                          activeColor: _activePrimary,
                          isEmail: _userType != 'student',
                          validator: (value) {
                             if (value == null || value.isEmpty) return 'Field is required';
                             if (_userType != 'student' && !value.contains('@')) return 'Invalid email';
                             return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // COMPONENT: Password Input
                        ModernTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          activeColor: _activePrimary,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (value) => (value == null || value.isEmpty) ? 'Password required' : null,
                        ),

                        const SizedBox(height: 32),

                        // COMPONENT: Login Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return PrimaryButton(
                              text: 'Secure Login',
                              isLoading: authProvider.status == AuthStatus.loading,
                              color: _activePrimary,
                              onPressed: _submitLogin,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}