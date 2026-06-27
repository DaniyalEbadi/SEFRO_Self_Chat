enum ReminderType { time, location, recurring }
enum RecurrenceType { daily, weekly, monthly, custom }
enum PriorityLevel { critical, high, medium, low }

class ReminderEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final ReminderType type;
  final DateTime? scheduledTime;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final double? radiusMeters;
  final RecurrenceType? recurrenceType;
  final List<int>? recurrenceDays;
  final PriorityLevel priority;
  final bool isActive;
  final bool isAcknowledged;
  final int? minutesBefore;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.type = ReminderType.time,
    this.scheduledTime,
    this.locationName,
    this.latitude,
    this.longitude,
    this.radiusMeters,
    this.recurrenceType,
    this.recurrenceDays,
    this.priority = PriorityLevel.medium,
    this.isActive = true,
    this.isAcknowledged = false,
    this.minutesBefore,
    this.relatedEntityId,
    this.relatedEntityType,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isExpired {
    if (scheduledTime == null) return false;
    return scheduledTime!.isBefore(DateTime.now());
  }

  ReminderEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    ReminderType? type,
    DateTime? scheduledTime,
    String? locationName,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    RecurrenceType? recurrenceType,
    List<int>? recurrenceDays,
    PriorityLevel? priority,
    bool? isActive,
    bool? isAcknowledged,
    int? minutesBefore,
    String? relatedEntityId,
    String? relatedEntityType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
