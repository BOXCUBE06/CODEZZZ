import 'package:flutter/material.dart';
import '../services/student_service.dart';

enum EmergencyStatus { idle, sending, sent, failed }

class StudentProvider with ChangeNotifier {
  final StudentService _studentService;

  EmergencyStatus _status = EmergencyStatus.idle;
  String? _errorMessage;

  StudentProvider(this._studentService);

  EmergencyStatus get status => _status;
  String? get errorMessage => _errorMessage;
  
  // --- NEW: Expose Service for Map Page ---
  StudentService get studentService => _studentService;

  Future<void> sendPanicAlert({
    required double lat,
    required double long,
    required String category,
    required String severity,
    String? description,
  }) async {
    _status = EmergencyStatus.sending;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _studentService.sendEmergencyAlert(
        lat: lat,
        long: long,
        category: category,
        severity: severity,
        description: description,
      );

      if (success) {
        _status = EmergencyStatus.sent;
      } else {
        _status = EmergencyStatus.failed;
        _errorMessage = "Failed. Try again.";
      }
    } catch (e) {
      _status = EmergencyStatus.failed;
      _errorMessage = "Connection Error";
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _status = EmergencyStatus.idle;
    notifyListeners();
  }
}