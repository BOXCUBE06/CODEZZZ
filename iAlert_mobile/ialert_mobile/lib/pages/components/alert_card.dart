import 'package:flutter/material.dart';
import '../../../models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;

  const AlertCard({
    super.key,
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. DETERMINE STATUS STYLE
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (alert.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.red;
        statusIcon = Icons.warning_amber_rounded;
        statusLabel = "PENDING ACCEPTANCE";
        break;
      case 'accepted':
        statusColor = Colors.orange;
        statusIcon = Icons.directions_run;
        statusLabel = "IN PROGRESS";
        break;
      case 'arrived':
        statusColor = Colors.purple;
        statusIcon = Icons.location_on;
        statusLabel = "ON SCENE";
        break;
      case 'resolved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusLabel = "RESOLVED";
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info_outline;
        statusLabel = "UNKNOWN";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. COLORED STRIP
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),

              // 2. CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(statusIcon, size: 14, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  alert.type.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // TIME (AM/PM Fixed)
                          Text(
                            _formatTimeAMPM(alert.time), // <--- UPDATED
                            style: TextStyle(color: Colors.grey[400], fontSize: 11),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Student Name
                      Text(
                        alert.studentName.isNotEmpty ? alert.studentName : "Unknown Student",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        alert.description.isNotEmpty ? alert.description : "No description provided.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (alert.status != 'resolved')
                            Row(
                              children: [
                                Text(
                                  "View Details",
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW FORMATTER (AM/PM) ---
  String _formatTimeAMPM(String rawDate) {
    try {
      if (rawDate.isEmpty) return "N/A";
      final DateTime date = DateTime.parse(rawDate).toLocal();
      
      int hour = date.hour;
      final int minute = date.minute;
      final String period = hour >= 12 ? 'PM' : 'AM';
      
      hour = hour % 12;
      if (hour == 0) hour = 12;

      return "$hour:${minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      return "Now";
    }
  }
}