import 'dart:convert';
import 'package:http/http.dart' as http;
import '../variables/variables.dart'; // Contains 'apiBaseUrl'

class NotificationService {
  final String token;

  // Constructor now requires the token
  NotificationService(this.token);

  // Helper to get headers using the class variable 'token'
  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. GET ALERTS
  Future<List<dynamic>> getNotifications() async {
    // Using apiBaseUrl from variables.dart
    final url = Uri.parse('$baseUrl/notifications');
    
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<List<dynamic>> getNotificationHistory() async {
    // Using apiBaseUrl from variables.dart
    final url = Uri.parse('$baseUrl/notifications/history');
    
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // 2. MARK ONE READ
  Future<void> markAsRead(int id) async {
    final url = Uri.parse('$baseUrl/notifications/$id/read');
    
    final response = await http.put(url, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  // 3. MARK ALL READ
  Future<void> markAllAsRead() async {
    final url = Uri.parse('$baseUrl/notifications/read-all');
    
    final response = await http.put(url, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all as read');
    }
  }
}