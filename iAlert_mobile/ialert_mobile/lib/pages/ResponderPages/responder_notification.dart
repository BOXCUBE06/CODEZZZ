import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';

class ResponderNotifView extends StatefulWidget {
  const ResponderNotifView({super.key});

  @override
  State<ResponderNotifView> createState() => _ResponderNotifView();
}

class _ResponderNotifView extends State<ResponderNotifView> {
  // 1. STATE VARIABLE: Tracks if the user wants to see history (read/unread)
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    // Initial fetch always gets UNREAD (default view)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  // Helper method to fetch based on the current state
  Future<void> _fetchData({bool refresh = false}) async {
    final provider = context.read<NotificationProvider>();
    if (_showHistory) {
      // Hits the /notifications/history endpoint (ALL)
      await provider.fetchNotificationsHistory(refresh: refresh); 
    } else {
      // Hits the /notifications endpoint (UNREAD ONLY)
      await provider.fetchNotifications(refresh: refresh); 
    }
  }

  // Handler for the toggle switch
  void _toggleHistory(bool newValue) {
    setState(() {
      _showHistory = newValue;
    });
    // Fetch data immediately when the toggle changes state
    _fetchData(); 
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _showHistory ? "Notification History" : "New Notifications",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          // 2. TOGGLE SWITCH (Replaces the "Mark All Read" button location)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Text(
                  _showHistory ? "History" : "Unread",
                  style: TextStyle(
                    color: _showHistory ? Colors.blue : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Switch(
                  value: _showHistory,
                  onChanged: _toggleHistory,
                  activeColor: Colors.blueAccent, // Color for history mode
                  inactiveThumbColor: Colors.redAccent, // Color for unread mode
                ),
              ],
            ),
          ),
          
          // "Mark All Read" button (Only shown in Unread mode or if list isn't empty)
          if (!_showHistory && notifications.isNotEmpty)
            IconButton(
              onPressed: () => provider.markAllAsRead(),
              icon: const Icon(Icons.done_all, color: Colors.blue),
              tooltip: "Mark all as read",
            )
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  // Use the helper method for refreshing
                  onRefresh: () => _fetchData(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      // Determine read status based on API response
                      final bool isRead = notif.readAt != null; 
                      return _buildNotificationItem(context, notif, provider, isRead);
                    },
                  ),
                ),
    );
  }

  // NOTE: Added 'isRead' parameter to the item builder
  Widget _buildNotificationItem(BuildContext context, dynamic notif, NotificationProvider provider, bool isRead) {
    // 1. ID MAPPING
    final int id = int.tryParse(notif.id.toString()) ?? 0;
    
    // 2. DATA MAPPING
    final String title = notif.title;
    final String message = notif.message;
    final String type = notif.type;
    final String time = notif.createdAt ?? DateTime.now().toString();

    final Color themeColor = _getTypeColor(type);
    
    return Dismissible(
      key: Key(notif.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        provider.markAsRead(id);
      },
      child: GestureDetector(
        onTap: () {
          // Show details, then mark as read
          _showNotificationDetails(context, title, message, time, themeColor, () {
             provider.markAsRead(id);
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            // Use isRead to change background color
            color: isRead ? Colors.white : Colors.blue.withOpacity(0.03), 
            borderRadius: BorderRadius.circular(16),
            // Light blue border for unread items
            border: Border.all(color: isRead ? Colors.grey.shade200 : Colors.blue.withOpacity(0.1)),
            boxShadow: [
              if (!isRead)
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Status Strip (Visible only if unread)
              if (!isRead)
                Container(
                  width: 4,
                  height: 90, 
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              // ... rest of the item content ...
              // 2. Icon Bubble
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getTypeIcon(type), color: themeColor, size: 24),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              // Text style contrast for read/unread
                              style: TextStyle(fontWeight: isRead ? FontWeight.w500 : FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(time),
                            style: TextStyle(color: isRead ? Colors.grey : themeColor, fontSize: 11, fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW: DETAILS POPUP ---
  void _showNotificationDetails(BuildContext context, String title, String message, String time, Color color, VoidCallback onMarkRead) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.notifications_active, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_formatTime(time), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const Divider(height: 30),
              
              // Full Message
              Expanded( // Wrap message in Expanded if it might be long
                child: SingleChildScrollView(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close modal
                    onMarkRead();       // Mark as read and remove from list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Okay, Got it", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("No notifications", style: TextStyle(color: Colors.grey)), // Simplified
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    if (type.toLowerCase() == 'success' || type.toLowerCase() == 'resolved') return Colors.green;
    if (type.toLowerCase() == 'alert' || type.toLowerCase() == 'emergency') return Colors.red;
    return Colors.blueAccent;
  }

  IconData _getTypeIcon(String type) {
    if (type.toLowerCase() == 'success' || type.toLowerCase() == 'resolved') return Icons.check_circle_outline;
    if (type.toLowerCase() == 'alert' || type.toLowerCase() == 'emergency') return Icons.warning_amber_rounded;
    return Icons.info_outline;
  }

  String _formatTime(String rawDate) {
    try {
      DateTime date = DateTime.parse(rawDate);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
      if (difference.inHours < 24) return "${difference.inHours}h ago";
      return "${date.month}/${date.day}";
    } catch (e) {
      return "Just now";
    }
  }
}