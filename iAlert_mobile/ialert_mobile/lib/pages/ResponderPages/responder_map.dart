import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/live_map.dart'; 
import '../../../providers/responder_provider.dart';

class ResponderMapView extends StatelessWidget {
  const ResponderMapView({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to provider to show real alert counts on the map HUD
    final provider = context.watch<ResponderProvider>();
    final activeCount = provider.alerts.where((a) => a.status == 'pending').length;

    return Scaffold(
      // Extend body so map goes behind the status bar
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. FULL SCREEN MAP
          const Positioned.fill(
            child: LiveMapWidget(showAllAlerts: true),
          ),

          // 2. TOP TACTICAL HUD (Dark Theme for contrast against map)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // Dark glassmorphism
                color: Colors.black.withOpacity(0.75), // Changed withValues to withOpacity for compatibility
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Pulsing Dot Animation (Simulated with Icon)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.radar, color: Colors.greenAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  
                  // Text Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "LIVE MONITORING",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$activeCount Active Threats",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Status Badge
                ],
              ),
            ),
          ),

          // 3. BOTTOM LEGEND (Floating Card)
          Positioned(
            // FIXED: Raised from 20 to 120 to clear the floating nav bar
            bottom: 120, 
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(Colors.red, "Pending"),
                  Container(width: 1, height: 20, color: Colors.grey[300]),
                  _buildLegendItem(Colors.orange, "Responding"),
                  Container(width: 1, height: 20, color: Colors.grey[300]),
                  _buildLegendItem(Colors.blue, "You"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}