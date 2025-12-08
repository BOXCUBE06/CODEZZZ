import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Optional: Add flutter_animate to pubspec.yaml for polish
import '../../../providers/student_provider.dart';
import 'student_form.dart';

class StudentHomeView extends StatelessWidget {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final double currentLat = 16.7208;
    final double currentLong = 121.6913;
    final bool isSent = studentProvider.status == EmergencyStatus.sent;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Gradient (Subtle Pulse)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: isSent
                    ? [Colors.green.shade50, Colors.white]
                    : [Colors.red.shade50, Colors.white],
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Header
                Text(
                  isSent ? "HELP IS ON THE WAY" : "EMERGENCY",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: isSent ? Colors.green[800] : Colors.red[900],
                  ),
                ).animate().fadeIn().slideY(begin: -0.5, end: 0),
                
                const SizedBox(height: 8),
                Text(
                  isSent 
                    ? "Responders have been notified of your location." 
                    : "Press and hold the button for immediate help.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),

                const Spacer(),

                // 3. The Panic Button (Hero Widget)
                Center(
                  child: GestureDetector(
                    onTap: studentProvider.status == EmergencyStatus.sending
                        ? null
                        : () {
                            // HapticFeedback.heavyImpact(); // Add this for better feel
                            studentProvider.sendPanicAlert(
                              lat: currentLat,
                              long: currentLong,
                              category: 'Other',
                              severity: 'severe',
                              description: 'PANIC BUTTON TRIGGERED',
                            );
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutBack,
                      width: isSent ? 200 : 260,
                      height: isSent ? 200 : 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Dynamic Gradient based on status
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _getButtonGradient(studentProvider.status),
                        ),
                        boxShadow: [
                          // Outer Glow
                          BoxShadow(
                            color: _getShadowColor(studentProvider.status).withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                            offset: const Offset(0, 10),
                          ),
                          // Inner Highlight (Neumorphic feel)
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: -5,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple Effect Rings (Purely decorative)
                          if (!isSent)
                            ...List.generate(3, (index) => Container(
                              margin: EdgeInsets.all(20.0 * index),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 2,
                                ),
                              ),
                            )),
                          
                          // Icon & Text
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getButtonIcon(studentProvider.status),
                                size: isSent ? 60 : 80,
                                color: Colors.white,
                              ),
                              if (!isSent) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _getButtonText(studentProvider.status),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(target: isSent ? 0 : 1).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

                const Spacer(),

                // 4. Live Location Card
                if (isSent)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.my_location, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Location Active",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "${currentLat.toStringAsFixed(4)}, ${currentLong.toStringAsFixed(4)}",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().slideY(begin: 1, end: 0),

                const SizedBox(height: 30),

                // 5. Detailed Report Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentFormPage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit_note, color: Colors.grey[800]),
                    label: Text(
                      "Report specific details",
                      style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Error Toast (Floating Overlay)
          if (studentProvider.errorMessage != null)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(10),
                color: Colors.redAccent,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          studentProvider.errorMessage!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().slideY(begin: -2, end: 0),
            ),
        ],
      ),
    );
  }

  // --- HELPERS ---
  
  List<Color> _getButtonGradient(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.sending:
        return [Colors.orange.shade400, Colors.orange.shade700];
      case EmergencyStatus.sent:
        return [Colors.green.shade400, Colors.green.shade700];
      case EmergencyStatus.failed:
        return [Colors.grey.shade400, Colors.grey.shade600];
      default:
        // Default Panic Red
        return [const Color(0xFFFF5252), const Color(0xFFD50000)];
    }
  }

  Color _getShadowColor(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.sending: return Colors.orange;
      case EmergencyStatus.sent: return Colors.green;
      case EmergencyStatus.failed: return Colors.grey;
      default: return Colors.red;
    }
  }

  String _getButtonText(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.sending: return "SENDING...";
      case EmergencyStatus.sent: return "";
      case EmergencyStatus.failed: return "RETRY";
      default: return "SOS";
    }
  }

  IconData _getButtonIcon(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.sending: return Icons.wifi_tethering;
      case EmergencyStatus.sent: return Icons.check;
      case EmergencyStatus.failed: return Icons.refresh;
      default: return Icons.touch_app; // Or Icons.emergency
    }
  }
}