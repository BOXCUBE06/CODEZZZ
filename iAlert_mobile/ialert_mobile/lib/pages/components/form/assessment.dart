import 'package:flutter/material.dart';

class SeverityAssessmentDialog extends StatefulWidget {
  final String category;
  final Function(String severity) onScoreCalculated;

  const SeverityAssessmentDialog({
    super.key,
    required this.category,
    required this.onScoreCalculated,
  });

  @override
  State<SeverityAssessmentDialog> createState() => _SeverityAssessmentDialogState();
}

class _SeverityAssessmentDialogState extends State<SeverityAssessmentDialog> {
  // We keep track of the answers. true = YES, false = NO
  List<bool> _answers = [false, false, false];
  late List<String> _questions;

  @override
  void initState() {
    super.initState();
    _questions = _getQuestions(widget.category);
  }

  // LOGIC: Specific questions for accuracy
  List<String> _getQuestions(String category) {
    switch (category) {
      case 'Medical':
        return [
          'Is the person unconscious or unable to speak?',
          'Is there bleeding that soaks through a cloth?',
          'Is the person gasping or unable to breathe?',
        ];
      case 'Fire':
        return [
          'Is the fire larger than a trash can?',
          'Is thick smoke filling the room?',
          'Is the fire blocking the exit?',
        ];
      case 'Security':
      case 'Harassment':
        return [
          'Can you see a weapon right now?',
          'Has physical violence/fighting started?',
          'Is the threat currently inside the room?',
        ];
      case 'Accident':
        return [
          'Is the victim unable to stand/move?',
          'Is there sparking or live wires?',
          'Did this involve a vehicle crash?',
        ];
      case 'Natural Disaster':
        return [
          'Are there visible cracks in walls or falling debris?',
          'Is floodwater rising rapidly or reaching outlets?',
          'Is anyone currently trapped or unable to exit?',
        ];
      default:
        return [
          'Is there immediate danger to life?',
          'Is the situation escalating?',
          'Do you need help right now?',
        ];
    }
  }

  void _calculateAndSubmit() {
    int yesCount = _answers.where((a) => a == true).length;
    String result;

    if (yesCount >= 2) {
      result = 'severe';
    } else if (yesCount == 1) {
      result = 'moderate';
    } else {
      result = 'mild';
    }

    // Close dialog and send back result
    Navigator.pop(context);
    widget.onScoreCalculated(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Row(
        children: [
          Icon(Icons.assignment_late, color: Colors.redAccent),
          SizedBox(width: 10),
          Text('Assess Severity'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please answer truthfully to help us prioritize.',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            const SizedBox(height: 15),
            
            // --- NEW UI: Question Cards with YES/NO Buttons ---
            for (int i = 0; i < _questions.length; i++)
              _buildQuestionCard(i, _questions[i]),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); 
          },
          child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: _calculateAndSubmit,
          child: const Text("CONFIRM"),
        ),
      ],
    );
  }

  // Helper widget to build the "Yes/No" layout
  Widget _buildQuestionCard(int index, String question) {
    bool isYes = _answers[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // NO BUTTON
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _answers[index] = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !isYes ? Colors.green[100] : Colors.white,
                      border: Border.all(
                        color: !isYes ? Colors.green : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "NO",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !isYes ? Colors.green[800] : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // YES BUTTON
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _answers[index] = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isYes ? Colors.red[100] : Colors.white,
                      border: Border.all(
                        color: isYes ? Colors.red : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "YES",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isYes ? Colors.red[800] : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}