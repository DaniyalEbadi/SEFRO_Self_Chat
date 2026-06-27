class NoteEntity {
  final String id;
  final String userId;
  final String title;
  final String content;
  final bool isPinned;
  final List<String>? tags;
  final String? colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.tags,
    this.colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get preview => content.length > 100 ? '${content.substring(0, 100)}...' : content;

  NoteEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    bool? isPinned,
    List<String>? tags,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
