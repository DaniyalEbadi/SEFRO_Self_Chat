enum MessageSender { user, ai }

class ChatMessageEntity {
  final String id;
  final String userId;
  final String? sessionId;
  final String content;
  final MessageSender sender;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  ChatMessageEntity({
    required this.id,
    required this.userId,
    this.sessionId,
    required this.content,
    required this.sender,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
