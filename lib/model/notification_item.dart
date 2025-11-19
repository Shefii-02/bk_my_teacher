class NotificationItem {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String time;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.time,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] ?? false,
      time: json['time']?.toString() ?? '',
    );
  }
}

class NotificationResponse {
  final int count;
  final List<NotificationItem> notifications;

  NotificationResponse({
    required this.count,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      count: json['count'] ?? 0,
      notifications: (json['notifications'] as List? ?? [])
          .map((e) => NotificationItem.fromJson(e))
          .toList(),
    );
  }
}
