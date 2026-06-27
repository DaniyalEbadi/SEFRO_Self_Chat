enum MemoryType { contact, location, preference, schedule, habit, fact }

class AiMemoryEntity {
  final String id;
  final String userId;
  final MemoryType type;
  final String key;
  final String value;
  final Map<String, dynamic>? metadata;
  final double confidence;
  final int accessCount;
  final DateTime? lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AiMemoryEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.key,
    required this.value,
    this.metadata,
    this.confidence = 1.0,
    this.accessCount = 0,
    this.lastAccessedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  AiMemoryEntity copyWith({
    String? id,
    String? userId,
    MemoryType? type,
    String? key,
    String? value,
    Map<String, dynamic>? metadata,
    double? confidence,
    int? accessCount,
    DateTime? lastAccessedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiMemoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      key: key ?? this.key,
      value: value ?? this.value,
      metadata: metadata ?? this.metadata,
      confidence: confidence ?? this.confidence,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
