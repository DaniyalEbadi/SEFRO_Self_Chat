enum NotificationType { standard, voice, urgent }

class NotificationEntity {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? payloadJson;
  final bool isRead;
  final bool isAcknowledged;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = NotificationType.standard,
    this.payloadJson,
    this.isRead = false,
    this.isAcknowledged = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
