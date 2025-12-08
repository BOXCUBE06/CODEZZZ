import 'package:flutter/material.dart';

class IncidentDetails extends StatelessWidget {
  final String description;
  final String severity;
  final String time;

  const IncidentDetails({
    super.key,
    required this.description,
    required this.severity,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Incident Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(description, style: TextStyle(color: Colors.grey[800], height: 1.5)),
        const SizedBox(height: 16),
        Row(
          children: [
            Chip(
              label: Text("Severity: $severity"),
              backgroundColor: Colors.grey[100],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatTimeAMPM(time),
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTimeAMPM(String rawDate) {
    try {
      if (rawDate.isEmpty) return "N/A";
      final DateTime date = DateTime.parse(rawDate).toLocal();
      int hour = date.hour;
      final int minute = date.minute;
      final String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      final String minuteStr = minute.toString().padLeft(2, '0');
      return "$hour:$minuteStr $period";
    } catch (e) {
      return "Now";
    }
  }
}