import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus { unauthenticated, authenticated, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unauthenticated;
  User? _user;
  StudentDetails? _studentDetails;
  ResponderDetails? _responderDetails;
  String? _token;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  StudentDetails? get studentDetails => _studentDetails;
  ResponderDetails? get responderDetails => _responderDetails;

  bool get isAuthenticated => _token != null;

  // --- LOGIN ---
  Future<bool> login({
    required String type,
    required String id,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(id, password);

    if (result.containsKey('token')) {
      _token = result['token'];
      _user = User.fromJson(result['user']);

      if (_user!.role == 'student' && result['details'] != null) {
        _studentDetails = StudentDetails.fromJson(result['details']);
        _responderDetails = null;
      } else if (_user!.role == 'responder' && result['details'] != null) {
        _responderDetails = ResponderDetails.fromJson(result['details']);
        _studentDetails = null;
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.unauthenticated;
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // --- LOGOUT ---
  void logout() {
    if (_token != null) {
      _authService.logout(_token!);
    }
    _token = null;
    _user = null;
    _studentDetails = null;
    _responderDetails = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // --- NEW: UPDATE PROFILE ---
  Future<bool> updateProfile({
    required String name,
    required String phoneNumber,
    String? password,
    String? passwordConfirmation,
    String? department,
    String? yearLevel,
    String? position,
  }) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final result = await _authService.updateProfile(
        token: _token!,
        name: name,
        phoneNumber: phoneNumber,
        password: password,
        passwordConfirmation: passwordConfirmation,
        department: department,
        yearLevel: yearLevel,
        position: position,
      );

      // --- CRITICAL: Update Local State with New Data ---
      // The backend returns: { 'message': '...', 'user': { ... with relationships ... } }
      final updatedUserJson = result['user'];
      
      // 1. Update Core User Data
      _user = User.fromJson(updatedUserJson);

      // 2. Update Details based on Role
      // Backend Eager Loads 'studentDetails' or 'responderDetails' in the response
      if (_user!.role == 'student') {
        if (updatedUserJson['student_details'] != null) {
           _studentDetails = StudentDetails.fromJson(updatedUserJson['student_details']);
        }
      } else if (_user!.role == 'responder') {
        if (updatedUserJson['responder_details'] != null) {
           _responderDetails = ResponderDetails.fromJson(updatedUserJson['responder_details']);
        }
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
      
    } catch (e) {
      _status = AuthStatus.authenticated; // Revert status, user is still logged in
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}