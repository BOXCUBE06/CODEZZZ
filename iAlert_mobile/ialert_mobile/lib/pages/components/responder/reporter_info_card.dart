import 'package:flutter/material.dart';

class ReporterInfoCard extends StatelessWidget {
  final String name;
  final String phone;

  const ReporterInfoCard({
    super.key,
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("REPORTED BY",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (phone != 'N/A')
                Text(phone, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ],
          ),
        ],
      ),
    );
  }
}