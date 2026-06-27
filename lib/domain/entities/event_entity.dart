class EventEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? calendarSource;
  final String? externalEventId;
  final String? colorHex;
  final List<String>? attendeeIds;
  final String? recurrenceRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.calendarSource,
    this.externalEventId,
    this.colorHex,
    this.attendeeIds,
    this.recurrenceRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Duration get duration => endTime.difference(startTime);
  bool get isOngoing => startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now());
  bool get isPast => endTime.isBefore(DateTime.now());

  EventEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? calendarSource,
    String? externalEventId,
    String? colorHex,
    List<String>? attendeeIds,
    String? recurrenceRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      calendarSource: calendarSource ?? this.calendarSource,
      externalEventId: externalEventId ?? this.externalEventId,
      colorHex: colorHex ?? this.colorHex,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
