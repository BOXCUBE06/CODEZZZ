import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '../components/profile_icon.dart';
import '../StudentPages/student_home.dart';
import '../StudentPages/student_map.dart';
import '../StudentPages/student_notification.dart';

import '../StudentPages/student_profile.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 1; // Default to Home/Panic

  // Theme Constants
  final Color _primaryRed = const Color(0xFFD32F2F);
  final Color _bgGrey = const Color(0xFFF8F9FA);

  final List<Widget> _pages = [
    const StudentMapPage(),
    const StudentHomeView(),
    const StudentNotifView(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      // We use extendBody so the map/content goes behind the floating nav
      extendBody: true,

      // Custom Top Bar (Instead of standard AppBar)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 24,
            right: 16, // adjusted for profile icon margin
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8), // Glass effect
            border: Border(
              bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Hello, Student",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    "iAlert Active",
                    style: TextStyle(
                      color: Color(0xFFD32F2F), // Red
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              // THE REDESIGNED PROFILE ICON
              ProfileIconButton(
                onTap: () {
                  // 1. Access the AuthProvider
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );

                  // 2. Safety Check (Optional but good): Ensure we are actually logged in
                  if (authProvider.user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // FIX: Remove 'user' and 'studentDetails'. 
                        // The page now gets them automatically via Provider.
                        builder: (context) => const StudentProfilePage(), 
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile data not available"),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),

      body: IndexedStack(index: _currentIndex, children: _pages),

      // Custom Floating Bottom Navigation
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      // Make background transparent so the capsule floats
      color: Colors.transparent,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35), // Capsule shape
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1. Map Icon
            _NavBarItem(
              icon: Icons.map_rounded,
              label: "Location",
              isSelected: _currentIndex == 0,
              onTap: () => _onTabTapped(0),
              activeColor: _primaryRed,
            ),

            // 2. CENTER "HERO" BUTTON (Home/Panic)
            Transform.translate(
              offset: const Offset(0, -20), // Move it up slightly
              child: GestureDetector(
                onTap: () => _onTabTapped(1),
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryRed, const Color(0xFFFF5252)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryRed.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _currentIndex == 1
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),

            // 3. Notification Icon
            _NavBarItem(
              icon: Icons.notifications_rounded,
              label: "Updates",
              isSelected: _currentIndex == 2,
              onTap: () => _onTabTapped(2),
              activeColor: _primaryRed,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Nav Items
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey[400],
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
