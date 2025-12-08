import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '../components/profile_icon.dart'; // Assuming this component is reusable

// Import Responder-specific views
import '../ResponderPages/responder_home.dart';
import '../ResponderPages/responder_map.dart';
import '../ResponderPages/responder_notification.dart';

import '../ResponderPages/responder_profile.dart'; // Import the new profile page

class ResponderDashboard extends StatefulWidget {
  const ResponderDashboard({super.key});

  @override
  State<ResponderDashboard> createState() => _ResponderDashboardState();
}

class _ResponderDashboardState extends State<ResponderDashboard> {
  int _currentIndex = 1; // Default to Home/Panic

  // 1. COLOR THEME CHANGE: Red -> Blue for Responder
  final Color _primaryBlue = const Color(0xFF1976D2); // A strong primary blue
  final Color _bgGrey = const Color(0xFFF8F9FA);

  // 2. PAGE LIST CHANGE: Use Responder-specific pages
  final List<Widget> _pages = [
    const ResponderMapView(),
    const ResponderHomeView(),
    const ResponderNotifView(),
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
      extendBody: true,

      // Custom Top Bar (Instead of standard AppBar)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 24,
            right: 16,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95), // Using withOpacity instead of withValues
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3. HEADER TEXT CHANGE: Student -> Responder
                  Text(
                    "Hello, Responder",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "iAlert Dispatch",
                    style: TextStyle(
                      color: _primaryBlue, // Blue
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
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );

                  // 4. DATA CHANGE: Get ResponderDetails
                  final user = authProvider.user;
                  final details = authProvider.responderDetails; // Use responderDetails

                  // 5. NAVIGATION CHANGE: Navigate to ResponderProfilePage
                  if (user != null && details != null) {
                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ResponderProfilePage(), // No arguments needed!
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
      color: Colors.transparent,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Using withOpacity instead of withValues
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
              icon: Icons.pin_drop_rounded, // Use a more relevant icon for live incidents
              label: "Incidents",
              isSelected: _currentIndex == 0,
              onTap: () => _onTabTapped(0),
              activeColor: _primaryBlue, // Blue
            ),

            // 2. CENTER "HERO" BUTTON (Home/Panic)
            Transform.translate(
              offset: const Offset(0, -20),
              child: GestureDetector(
                onTap: () => _onTabTapped(1),
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    // 6. GRADIENT CHANGE: Use Blue gradient
                    gradient: LinearGradient(
                      colors: [_primaryBlue, const Color(0xFF64B5F6)], // Light blue
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryBlue.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    // 7. ICON CHANGE: Use a relevant icon for responder home/status
                    _currentIndex == 1
                        ? Icons.local_fire_department
                        : Icons.local_fire_department_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),

            // 3. Notification Icon
            _NavBarItem(
              icon: Icons.list_alt_rounded, // More suitable icon for tasks/dispatches
              label: "Dispatch",
              isSelected: _currentIndex == 2,
              onTap: () => _onTabTapped(2),
              activeColor: _primaryBlue, // Blue
            ),
          ],
        ),
      ),
    );
  }
}

// The helper widget _NavBarItem remains the same, but will use the activeColor property (now blue)
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
                    ? activeColor.withOpacity(0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.grey[400],
                size: 26,
              ),
            ),
            // The Label is not used in the Student implementation, but included here for completeness:
            // Text(
            //   label,
            //   style: TextStyle(
            //     fontSize: 10,
            //     color: isSelected ? activeColor : Colors.grey[400],
            //     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}