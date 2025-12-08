class Alert {
  final int id;
  final String type; // Maps to 'category' from backend
  final double latitude;
  final double longitude;
  final String status;
  final String time; // Maps to 'created_at'
  final String description;
  final String studentName;
  final String studentPhone;
  final String severity;

  // --- NEW FIELDS FOR FIX #2 ---
  final int? responderId;
  final String? responderName;

  Alert({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.time,
    required this.description,
    required this.studentName,
    required this.studentPhone,
    required this.severity,
    this.responderId,
    this.responderName,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    // 1. Safely extract nested Responder Name
    String? parsedResponderName;
    if (json['responder'] != null && json['responder']['name'] != null) {
      parsedResponderName = json['responder']['name'];
    }

    return Alert(
      id: json['id'],
      // Map 'category' to 'type' for UI consistency
      type: json['category'] ?? 'General', 
      
      // Safe Double Parsing (Handles string/num differences)
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      
      status: json['status'] ?? 'pending',
      time: json['created_at'] ?? '', // You might want to format this date string later
      description: json['description'] ?? '',
      
      // De-normalized Student Data
      studentName: json['student_name'] ?? 'Unknown Student',
      studentPhone: json['student_phone'] ?? 'N/A',
      severity: json['severity'] ?? 'moderate',

      // --- NEW MAPPINGS ---
      responderId: json['responder_id'],
      responderName: parsedResponderName,
    );
  }
}