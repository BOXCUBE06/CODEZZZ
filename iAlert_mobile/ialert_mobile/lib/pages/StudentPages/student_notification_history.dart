import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';
// Import the helper methods from StudentNotifView (or extract them into a shared file)
// NOTE: For this example, the helper methods are duplicated below for quick testing.

class StudentHistoryView extends StatefulWidget {
  const StudentHistoryView({super.key});

  @override
  State<StudentHistoryView> createState() => _StudentHistoryViewState();
}

class _StudentHistoryViewState extends State<StudentHistoryView> {

  @override
  void initState() {
    super.initState();
    // Fetch History immediately when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotificationsHistory(); 
    });
  }

  // Helper method for refreshing now only calls the history fetch
  Future<void> _fetchData({bool refresh = false}) async {
    await context.read<NotificationProvider>().fetchNotificationsHistory(refresh: refresh); 
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Notification History",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        // Removed all actions
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchData, 
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      // Determine read status based on API response
                      final bool isRead = notif.readAt != null; 
                      return _buildHistoryItem(context, notif, isRead);
                    },
                  ),
                ),
    );
  }

  // NOTE: This item is non-interactive (no Dismissible, no GestureDetector/onTap)
  Widget _buildHistoryItem(BuildContext context, dynamic notif, bool isRead) {
    // 1. DATA MAPPING (Assumes AppNotification model)
    final String title = notif.title;
    final String message = notif.message;
    final String type = notif.type;
    final String time = notif.createdAt ?? DateTime.now().toString();
    final Color themeColor = _getTypeColor(type);

    // Padding/Container used instead of Dismissible/GestureDetector
    return Padding( 
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.blue.withOpacity(0.03), 
          borderRadius: BorderRadius.circular(16),
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
            // Status Strip 
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
            // ... (rest of visual content copied)
            Padding(padding: const EdgeInsets.all(16.0), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: themeColor.withOpacity(0.1), shape: BoxShape.circle,), child: Icon(_getTypeIcon(type), color: themeColor, size: 24),),),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(title, style: TextStyle(fontWeight: isRead ? FontWeight.w500 : FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis,),), Text(_formatTime(time), style: TextStyle(color: isRead ? Colors.grey : themeColor, fontSize: 11, fontWeight: isRead ? FontWeight.normal : FontWeight.bold),),],), const SizedBox(height: 6), Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis,),],),),),
          ],
        ),
      ),
    );
  }

  // NOTE: Helper methods are duplicated here for quick testing.
  Widget _buildEmptyState() {return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.notifications_off_outlined, size: 50, color: Colors.grey[300]), const SizedBox(height: 10), const Text("No notifications found.", style: TextStyle(color: Colors.grey)),],),);}
  Color _getTypeColor(String type) {if (type.toLowerCase() == 'success' || type.toLowerCase() == 'resolved') return Colors.green; if (type.toLowerCase() == 'alert' || type.toLowerCase() == 'emergency') return Colors.red; return Colors.blueAccent;}
  IconData _getTypeIcon(String type) {if (type.toLowerCase() == 'success' || type.toLowerCase() == 'resolved') return Icons.check_circle_outline; if (type.toLowerCase() == 'alert' || type.toLowerCase() == 'emergency') return Icons.warning_amber_rounded; return Icons.info_outline;}
  String _formatTime(String rawDate) {try {DateTime date = DateTime.parse(rawDate); final now = DateTime.now(); final difference = now.difference(date); if (difference.inMinutes < 60) return "${difference.inMinutes}m ago"; if (difference.inHours < 24) return "${difference.inHours}h ago"; return "${date.month}/${date.day}";} catch (e) {return "Just now";}}
}