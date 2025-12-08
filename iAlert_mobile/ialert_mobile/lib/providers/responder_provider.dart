import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/responder_service.dart';
import '../models/alert_model.dart';

class ResponderProvider with ChangeNotifier {
  final ResponderService _service;

  // --- STATE ---
  List<Alert> _alerts = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filter State
  String _currentFilter = 'pending';
  bool _showOnlyMine = false; 
  int? _currentUserId;
  int _pendingCount = 0; 

  // Heartbeat / Map State
  bool _isOnline = false;
  Timer? _heartbeatTimer;
  List<dynamic> _activeResponders = []; 

  // Safety State
  bool _isDisposed = false;

  ResponderProvider(this._service);

  // --- GETTERS ---
  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;
  bool get showOnlyMine => _showOnlyMine;
  int get pendingCount => _pendingCount;
  
  // Heartbeat Getters
  bool get isOnline => _isOnline;
  List<dynamic> get activeResponders => _activeResponders;

  // --- FILTER LOGIC ---
  List<Alert> get filteredAlerts {
    List<Alert> output = _alerts;

    // 1. Filter by Status Tab
    if (_currentFilter != 'all') {
      output = output.where((a) => a.status.toLowerCase() == _currentFilter).toList();
    }

    // 2. Filter by "My Alerts" Toggle
    if (_showOnlyMine && _currentUserId != null) {
      output = output.where((a) => a.responderId == _currentUserId).toList();
    }

    return output;
  }

  // --- SETTERS ---
  void setCurrentUserId(int id) {
    _currentUserId = id;
  }

  void toggleShowOnlyMine(bool value) {
    _showOnlyMine = value;
    notifyListeners();
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    
    // UX Logic: Auto-enable "Mine" for active work
    if (filter == 'accepted' || filter == 'arrived') {
       _showOnlyMine = true;
    } else if (filter == 'pending') {
       _showOnlyMine = false;
    }

    // Smart Fetching
    if (filter == 'resolved' || filter == 'all') {
      fetchAlerts(mode: filter);
    } else {
      fetchAlerts(mode: 'active');
    }
    
    notifyListeners();
  }

  // --- FETCH LOGIC ---
  Future<void> fetchAlerts({bool refresh = false, String mode = 'active'}) async {
    if (!refresh) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      // A. Fetch List
      final rawData = await _service.getAlerts(mode: mode);
      
      if (_isDisposed) return; // Safety Check

      _alerts = rawData.map((json) => Alert.fromJson(json)).toList();
      _alerts.sort((a, b) => b.id.compareTo(a.id)); 
      
      // B. Fetch Stats
      _pendingCount = await _service.getPendingCount();

      _errorMessage = null;
    } catch (e) {
      if (_isDisposed) return;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // --- HEARTBEAT LOGIC (For Duty Status) ---
  Future<void> toggleOnlineStatus(bool value) async {
    _isOnline = value;
    notifyListeners();

    if (_isOnline) {
      // Check Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isOnline = false; // Revert switch if denied
          notifyListeners();
          return;
        }
      }
      _startHeartbeat();
    } else {
      _stopHeartbeat();
    }
  }

  void _startHeartbeat() {
    print("💓 STARTING DUTY");
    _sendPing(); // Immediate

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _sendPing();
      _fetchTeammates();
    });
  }

  void _stopHeartbeat() {
    print("⚫ ENDING DUTY");
    _heartbeatTimer?.cancel();
    // Send offline signal
    _service.sendHeartbeat(lat: 0, long: 0, isOnline: false);
  }

  Future<void> _sendPing() async {
    try {
      Position pos = await Geolocator.getCurrentPosition();
      print("📍 Sending GPS: ${pos.latitude}, ${pos.longitude}");
      await _service.sendHeartbeat(
        lat: pos.latitude, 
        long: pos.longitude, 
        isOnline: true
      );
    } catch (e) {
      print("GPS Ping Error: $e");
    }
  }

  Future<void> _fetchTeammates() async {
    try {
      // Assuming you added getActiveResponders to ResponderService?
      // If not, this part might need adjustment based on your service code.
      // _activeResponders = await _service.getActiveResponders(); 
      // notifyListeners();
    } catch (e) {
      // Fail silently
    }
  }

  // --- ACTIONS ---
  Future<void> acceptAlert(int id) async {
    try {
      await _service.acceptAlert(id);
      _updateLocalStatus(id, 'accepted');
    } catch (e) {
      if (e.toString().contains("409")) fetchAlerts(refresh: true);
      rethrow;
    }
  }

  Future<void> markArrived(int id) async {
    try {
      await _service.markArrived(id);
      _updateLocalStatus(id, 'arrived');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resolveAlert(int id, String remarks) async {
    try {
      await _service.resolveAlert(id, remarks);
      _updateLocalStatus(id, 'resolved');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelAlert(int id) async {
    try {
      await _service.cancelAlert(id);
      _updateLocalStatus(id, 'cancelled');
    } catch (e) {
      rethrow;
    }
  }

  // --- HELPERS ---
  void _updateLocalStatus(int id, String newStatus) {
    if (_isDisposed) return;
    
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _alerts[index];
      _alerts[index] = Alert(
        id: old.id,
        type: old.type,
        latitude: old.latitude,
        longitude: old.longitude,
        status: newStatus,
        time: old.time,
        description: old.description,
        studentName: old.studentName,
        studentPhone: old.studentPhone,
        severity: old.severity,
        responderId: _currentUserId, 
        responderName: old.responderName, 
      );
      notifyListeners();
    }
  }
  
  // --- SAFETY ---
  @override
  void dispose() {
    _isDisposed = true;
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}