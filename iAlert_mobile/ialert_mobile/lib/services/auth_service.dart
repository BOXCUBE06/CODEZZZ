import 'dart:convert';
import 'package:http/http.dart' as http;
import '../variables/variables.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String id, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          // We don't use jsonEncode here to match your existing working login
          // but we add Content-Type just in case backend gets strict
        },
        body: {'id': id, 'password': password},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<void> logout(String token) async {
    final url = Uri.parse('$baseUrl/logout');

    await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  // --- NEW: UPDATE PROFILE ---
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? phoneNumber,
    String? password,
    String? passwordConfirmation,
    // Student specifics
    String? department,
    String? yearLevel,
    // Responder specifics
    String? position,
  }) async {
    final url = Uri.parse('$baseUrl/profile'); // Maps to Route::put('/profile')

    // Build the body dynamically
    final Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;
    if (phoneNumber != null) body['phone_number'] = phoneNumber;

    // Only add password if user typed something
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
      body['password_confirmation'] = passwordConfirmation;
    }

    // Add role specifics
    if (department != null) body['department'] = department;
    if (yearLevel != null) body['year_level'] = yearLevel;
    if (position != null) body['position'] = position;

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // Required for JSON body
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Returns { message: "...", user: {...} }
      } else {
        final error = jsonDecode(response.body);
        // We throw an exception here so the Provider can catch it and show the error message
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      rethrow;
    }
  }
}