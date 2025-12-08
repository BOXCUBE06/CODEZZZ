import 'package:flutter/material.dart';

// Helper Class to structure content
class _SafetyContent {
  final String title;
  final String description;
  final Color color;
  final List<String> steps;

  _SafetyContent({
    required this.title,
    required this.description,
    required this.color,
    required this.steps,
  });
}

class SafetyInstructionsDialog extends StatelessWidget {
  final String category;
  final VoidCallback onSubmitted;

  const SafetyInstructionsDialog({
    super.key,
    required this.category,
    required this.onSubmitted,
  });

  // --- LOGIC: Define Instructions per Category ---
  _SafetyContent _getSafetyInstructions(String category) {
    switch (category) {
      case 'Medical':
        return _SafetyContent(
          title: 'First Aid Protocols',
          description: 'Assess the situation. Protect yourself and the patient.',
          color: Colors.redAccent,
          steps: [
            'Asthma: Sit upright. Use inhaler immediately. Keep calm.',
            'Heat Exhaustion: Move to shade/AC. Sip water. Loosen clothes.',
            'Fainting: Lay flat, elevate legs to restore blood flow.',
            'Unconscious: Check breathing. Call Clinic. CPR if needed.',
          ],
        );
      case 'Fire':
        return _SafetyContent(
          title: 'Fire Safety (Sunog)',
          description: 'Evacuate calmly. Do not use elevators.',
          color: Colors.orange[800]!,
          steps: [
            'Electrical Fire: Unplug if safe. Do NOT use water.',
            'LPG Leak: Do NOT switch lights on/off. Open windows.',
            'Smoke: Cover nose with wet cloth. Crawl low.',
            'Evacuate: Go to designated Open Field immediately.',
          ],
        );
      case 'Security':
      case 'Harassment':
        return _SafetyContent(
          title: 'Security Threats',
          description: 'Theft, intruders, or physical threats.',
          color: Colors.blueGrey,
          steps: [
            'Theft (Salisi): Report to Guard. Block GCash/Bank apps.',
            'Intruder: Do not engage. Move to a crowded area.',
            'Fight/Rumble: Move away. Do not watch. Report to Security.',
            'Emergency: Call the Campus Security Hotline.',
          ],
        );
      case 'Accident':
        return _SafetyContent(
          title: 'Accidents & Electrical',
          description: 'Falls, shocks, and physical injuries.',
          color: Colors.amber[900]!,
          steps: [
            'Slip & Fall: Check for pain before standing. Don\'t move if severe.',
            'Electric Shock: Let go immediately. Do NOT touch device again.',
            'Live Wire: Do NOT touch the person. Cut power first.',
            'Hazard: Report "grounded" items or wet floors to Admin.',
          ],
        );
      case 'Natural Disaster':
        return _SafetyContent(
          title: 'Calamity Protocols',
          description: 'Typhoons, Earthquakes, and Floods.',
          color: Colors.brown,
          steps: [
            'Earthquake: DUCK, COVER, & HOLD. Evacuate after shaking.',
            'Typhoon: Stay indoors. Charge phones. Await announcements.',
            'Flood: Move to higher ground. Avoid floodwater (Lepto risk).',
            'Aftershock: Stay in open field away from buildings.',
          ],
        );
      case 'Other':
      default:
        return _SafetyContent(
          title: 'Stand By for Instructions',
          description: 'Report received. Please wait for assessment.',
          color: Colors.blue,
          steps: [
            'Remain in a safe location.',
            'Keep phone line open for responders.',
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final instructions = _getSafetyInstructions(category);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: instructions.color),
          const SizedBox(width: 10),
          Expanded(child: Text(instructions.title, style: TextStyle(color: instructions.color))),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(instructions.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            const Text("Immediate Steps:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            ...instructions.steps.map((step) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Expanded(child: Text(step)),
                  ],
                ),
              )
            ).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            onSubmitted();          // Navigate back
          },
          child: const Text("CLOSE & STAND BY"),
        ),
      ],
    );
  }
}