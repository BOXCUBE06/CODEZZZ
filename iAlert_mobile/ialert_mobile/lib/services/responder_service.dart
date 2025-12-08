import 'dart:convert';
import 'package:http/http.dart' as http;
import '../variables/variables.dart'; // Ensure this has 'baseUrl'

class ResponderService {
  final String token;

  ResponderService(this.token);

  // --- HEADERS HELPER ---
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // 1. GET ALERTS (List)
  Future<List<dynamic>> getAlerts({String mode = 'active'}) async {
    String queryParam = "";
    if (mode == 'all') {
      queryParam = "?status=all";
    } else if (mode == 'resolved') {
      queryParam = "?status=resolved";
    } 
    // If mode is 'active', backend defaults to pending/accepted/arrived

    final url = Uri.parse('$baseUrl/responder/alerts$queryParam');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final dynamic json = jsonDecode(response.body);
        if (json is List) return json;
        if (json is Map<String, dynamic> && json.containsKey('data')) return json['data'];
        return [];
      }
      return [];
    } catch (e) {
      print("Error fetching alerts: $e");
      return [];
    }
  }

  // 2. GET PENDING COUNT (Stats)
  Future<int> getPendingCount() async {
    final url = Uri.parse('$baseUrl/responder/stats');
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['pending_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // 3. SEND HEARTBEAT (The Missing Method!)
  Future<void> sendHeartbeat({
    required double lat, 
    required double long, 
    required bool isOnline
  }) async {
    final url = Uri.parse('$baseUrl/responder/heartbeat');
    
    try {
      await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'latitude': lat,
          'longitude': long,
          'is_online': isOnline
        }),
      );
    } catch (e) {
      print("Heartbeat failed: $e");
    }
  }

  // 4. GET ACTIVE RESPONDERS (For Teammate Map)
  Future<List<dynamic>> getActiveResponders() async {
    final url = Uri.parse('$baseUrl/map/responders'); // OR /student/map/responders depending on your route
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- ACTIONS ---

  Future<bool> acceptAlert(int alertId) async {
    final url = Uri.parse('$baseUrl/alerts/$alertId/accept');
    final response = await http.post(url, headers: _headers);

    if (response.statusCode == 200) return true;
    if (response.statusCode == 409) throw Exception("Alert already taken.");
    throw Exception("Failed to accept alert.");
  }

  Future<bool> markArrived(int alertId) async {
    final url = Uri.parse('$baseUrl/alerts/$alertId/arrived');
    final response = await http.post(url, headers: _headers);
    
    if (response.statusCode == 200) return true;
    throw Exception("Failed to update status.");
  }

  Future<bool> resolveAlert(int alertId, String remarks) async {
    final url = Uri.parse('$baseUrl/alerts/$alertId/resolve');
    final response = await http.post(
      url, 
      headers: _headers,
      body: jsonEncode({'remarks': remarks}),
    );
    
    if (response.statusCode == 200) return true;
    throw Exception("Failed to resolve alert.");
  }

  Future<bool> cancelAlert(int alertId) async {
    final url = Uri.parse('$baseUrl/alerts/$alertId/cancel');
    final response = await http.post(url, headers: _headers);
    
    if (response.statusCode == 200) return true;
    throw Exception("Failed to cancel alert.");
  }
}