import 'package:flutter/material.dart';
import '../services/notification_service.dart'; // Ensure this exists or use http directly
import '../models/notification_model.dart'; // Ensure you have a model

class NotificationProvider with ChangeNotifier {
  final NotificationService _service; // Or whatever service handling HTTP

  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  NotificationProvider(this._service);

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // 1. FETCH
  Future<void> fetchNotificationsHistory({bool refresh = false}) async {
  if (!refresh) {
    _isLoading = true;
    notifyListeners();
  }

  try {
    final data = await _service.getNotificationHistory();
    // Assuming data is a List of JSON objects
    _notifications = data.map((json) => AppNotification.fromJson(json)).toList();
  } catch (e) {
    debugPrint("Error fetching notifications history: $e");
  } finally {
    if (!refresh) {
      _isLoading = false;
      notifyListeners();
    } // Notify listeners after the refresh/fetch completes
  }
}

  Future<void> fetchNotifications({bool refresh = false}) async {
  if (!refresh) {
    _isLoading = true;
    notifyListeners();
  }

  try {
    final data = await _service.getNotifications();
    // Assuming data is a List of JSON objects
    _notifications = data.map((json) => AppNotification.fromJson(json)).toList();
  } catch (e) {
    debugPrint("Error fetching notifications (unread): $e");
  } finally {
    if (!refresh) {
      _isLoading = false;
          notifyListeners(); 
    }// Notify listeners after the refresh/fetch completes
  }
}



  // 2. MARK AS READ (Single) - Expecting int if your DB uses auto-increment
  Future<void> markAsRead(int id) async {
    try {
      // Optimistic update: Remove from list immediately
      _notifications.removeWhere((n) => n.id == id.toString());
      notifyListeners();

      await _service.markAsRead(id);
    } catch (e) {
      // Re-fetch if it fails
      fetchNotifications();
    }
  }

  // 3. MARK ALL AS READ (The missing method)
  Future<void> markAllAsRead() async {
    try {
      // Optimistic update: Clear list immediately
      _notifications.clear();
      notifyListeners();

      await _service.markAllAsRead();
    } catch (e) {
      fetchNotifications();
    }
  }
}