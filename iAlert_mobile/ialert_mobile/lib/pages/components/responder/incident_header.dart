import 'package:flutter/material.dart';

class IncidentHeader extends StatelessWidget {
  final String type;
  final String status;
  final Color headerColor;

  const IncidentHeader({
    super.key,
    required this.type,
    required this.status,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: headerColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning_amber_rounded, color: headerColor, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.toUpperCase(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "Status: ${status.toUpperCase()}",
                style: TextStyle(color: headerColor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}