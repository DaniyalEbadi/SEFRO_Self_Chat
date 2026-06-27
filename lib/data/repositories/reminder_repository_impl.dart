import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;
  final _uuid = const Uuid();
  static const _storageKey = 'reminders_cache';

  ReminderRepositoryImpl(this._supabase, this._local);

  Future<List<Map<String, dynamic>>> _readRows() async {
    final raw = _local.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .cast<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _writeRows(List<Map<String, dynamic>> rows) async {
    await _local.setString(_storageKey, jsonEncode(rows));
  }

  @override
  Future<ReminderEntity> createReminder(ReminderEntity reminder) async {
    final rows = await _readRows();
    final now = DateTime.now().toIso8601String();
    final id = reminder.id.isEmpty ? _uuid.v4() : reminder.id;
    final data = _toJson(reminder)
      ..['id'] = id
      ..['created_at'] = now
      ..['updated_at'] = now;
    rows.add(data);
    await _writeRows(rows);
    return _fromJson(data);
  }

  @override
  Future<void> deleteReminder(String id) async {
    final rows = await _readRows();
    rows.removeWhere((row) => row['id'] == id);
    await _writeRows(rows);
  }

  @override
  Future<ReminderEntity> getReminder(String id) async {
    final rows = await _readRows();
    final row = rows.cast<Map<String, dynamic>?>().firstWhere(
      (row) => row?['id'] == id,
      orElse: () => null,
    );
    if (row == null) {
      throw Exception('یادآوری پیدا نشد');
    }
    return _fromJson(row);
  }

  @override
  Future<List<ReminderEntity>> getReminders({bool? isActive}) async {
    final rows = await _readRows();
    var reminders = rows.map(_fromJson).toList();
    if (isActive != null) {
      reminders = reminders
          .where((reminder) => reminder.isActive == isActive)
          .toList();
    }
    return reminders;
  }

  @override
  Future<List<ReminderEntity>> getDueReminders() async {
    final reminders = await getReminders(isActive: true);
    return reminders
        .where(
          (reminder) =>
              reminder.scheduledTime != null &&
              reminder.scheduledTime!.isBefore(
                DateTime.now().add(const Duration(minutes: 5)),
              ) &&
              !reminder.isAcknowledged,
        )
        .toList();
  }

  @override
  Future<ReminderEntity> updateReminder(ReminderEntity reminder) async {
    final rows = await _readRows();
    final updatedRows = rows.map((row) {
      if (row['id'] == reminder.id) {
        return {
          ..._toJson(reminder),
          'id': reminder.id,
          'created_at': row['created_at'],
          'updated_at': DateTime.now().toIso8601String(),
        };
      }
      return row;
    }).toList();

    await _writeRows(updatedRows);
    return reminder.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> acknowledgeReminder(String id) async {
    final reminder = await getReminder(id);
    await updateReminder(reminder.copyWith(isAcknowledged: true));
  }

  Map<String, dynamic> _toJson(ReminderEntity reminder) => {
    'user_id': reminder.userId,
    'title': reminder.title,
    'description': reminder.description,
    'type': reminder.type.name,
    'scheduled_time': reminder.scheduledTime?.toIso8601String(),
    'location_name': reminder.locationName,
    'latitude': reminder.latitude,
    'longitude': reminder.longitude,
    'radius_meters': reminder.radiusMeters,
    'recurrence_type': reminder.recurrenceType?.name,
    'recurrence_days': reminder.recurrenceDays,
    'priority': reminder.priority.name,
    'is_active': reminder.isActive,
    'is_acknowledged': reminder.isAcknowledged,
    'minutes_before': reminder.minutesBefore,
    'related_entity_id': reminder.relatedEntityId,
    'related_entity_type': reminder.relatedEntityType,
  };

  ReminderEntity _fromJson(Map<String, dynamic> json) => ReminderEntity(
    id: json['id'] as String? ?? _uuid.v4(),
    userId: json['user_id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    type: ReminderType.values.firstWhere(
      (type) => type.name == json['type'],
      orElse: () => ReminderType.time,
    ),
    scheduledTime: json['scheduled_time'] != null
        ? DateTime.tryParse(json['scheduled_time'] as String)
        : null,
    locationName: json['location_name'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    radiusMeters: (json['radius_meters'] as num?)?.toDouble(),
    recurrenceType: json['recurrence_type'] != null
        ? RecurrenceType.values.firstWhere(
            (type) => type.name == json['recurrence_type'],
            orElse: () => RecurrenceType.daily,
          )
        : null,
    recurrenceDays: json['recurrence_days'] is List
        ? (json['recurrence_days'] as List)
              .whereType<num>()
              .map((day) => day.toInt())
              .toList()
        : json['recurrence_days'] is String
        ? (json['recurrence_days'] as String)
              .split(',')
              .where((day) => day.isNotEmpty)
              .map(int.parse)
              .toList()
        : null,
    priority: PriorityLevel.values.firstWhere(
      (priority) => priority.name == json['priority'],
      orElse: () => PriorityLevel.medium,
    ),
    isActive: json['is_active'] as bool? ?? true,
    isAcknowledged: json['is_acknowledged'] as bool? ?? false,
    minutesBefore: json['minutes_before'] as int?,
    relatedEntityId: json['related_entity_id'] as String?,
    relatedEntityType: json['related_entity_type'] as String?,
  );
}
