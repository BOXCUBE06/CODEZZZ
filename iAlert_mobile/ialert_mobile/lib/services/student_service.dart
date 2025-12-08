import 'dart:convert';
import 'package:http/http.dart' as http;
import '../variables/variables.dart';

class StudentService {
  final String token;

  StudentService(this.token);

  Future<bool> sendEmergencyAlert({
    required double lat,
    required double long,
    required String category,
    required String severity,
    String? description,
  }) async {
    final url = Uri.parse('$baseUrl/alerts');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'category': category,
          'severity': severity,
          'description': description ?? 'Emergency triggered',
          'latitude': lat,
          'longitude': long,
          'status': 'pending',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("Error Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception sending alert: $e");
      return false;
    }
  }

  // --- NEW: FETCH LIVE RESPONDERS (For Map) ---
  Future<List<dynamic>> getActiveResponders() async {
    // This matches the route: Route::get('/student/map/responders', ...)
    final url = Uri.parse('$baseUrl/student/map/responders');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Backend returns: [{ "id": 1, "lat": 16.5, "lng": 121.5, ... }]
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching responders: $e");
      return [];
    }
  }
}