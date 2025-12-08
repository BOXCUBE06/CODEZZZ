import 'package:flutter/material.dart';
import '../../components/live_map.dart'; // Make sure this path is correct

class LocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final VoidCallback onRefresh;

  const LocationCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background: Map or Loading State
          // Inside lib/features/student/components/location_card.dart

Positioned.fill(
  child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : (latitude != null)
          ? LiveMapWidget(
              showAllAlerts: false,
              inputLat: latitude, // Pass the lat
              inputLong: longitude, // Pass the long
            )
          : Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.location_off)),
            ),
),

          // Overlay: Coordinates & Refresh Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white.withOpacity(0.95),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.my_location,
                              size: 16, color: Colors.red[600]),
                          const SizedBox(width: 6),
                          Text(
                            isLoading ? "Locating..." : "Pinpoint Location",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latitude != null
                            ? "${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}"
                            : "Waiting for GPS...",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    tooltip: "Refresh Location",
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}