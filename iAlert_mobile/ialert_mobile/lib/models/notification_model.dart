class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? createdAt;
  final String? readAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.createdAt,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      
      // FIX: Read directly from the root of the JSON, not inside ['data']
      title: json['title'] ?? 'New Notification',
      message: json['message'] ?? 'You have a new update.',
      type: json['type'] ?? 'info',
      
      createdAt: json['created_at'],
      readAt: json['read_at'],
    );
  }
}