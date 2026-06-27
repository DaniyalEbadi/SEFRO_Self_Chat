import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';

class HabitRepositoryImpl implements HabitRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;
  final _uuid = const Uuid();
  static const _storageKey = 'habits_cache';

  HabitRepositoryImpl(this._supabase, this._local);

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
  Future<HabitEntity> completeHabit(String id) async {
    final habit = await getHabit(id);
    final now = DateTime.now();
    final newStreak = _calculateStreak(habit, now);
    return updateHabit(
      habit.copyWith(
        currentStreak: newStreak,
        bestStreak: newStreak > habit.bestStreak ? newStreak : habit.bestStreak,
        totalCompletions: habit.totalCompletions + 1,
        lastCompletedAt: now,
      ),
    );
  }

  int _calculateStreak(HabitEntity habit, DateTime completionDate) {
    if (habit.lastCompletedAt == null) return 1;
    final diff = completionDate.difference(habit.lastCompletedAt!).inDays;
    if (diff <= 1) return habit.currentStreak + 1;
    if (diff <= 2 && habit.frequency == HabitFrequency.weekly)
      return habit.currentStreak + 1;
    return 1;
  }

  @override
  Future<HabitEntity> createHabit(HabitEntity habit) async {
    final rows = await _readRows();
    final now = DateTime.now().toIso8601String();
    final id = habit.id.isEmpty ? _uuid.v4() : habit.id;
    final data = _toJson(habit)
      ..['id'] = id
      ..['created_at'] = now
      ..['updated_at'] = now;
    rows.add(data);
    await _writeRows(rows);
    return _fromJson(data);
  }

  @override
  Future<void> deleteHabit(String id) async {
    final rows = await _readRows();
    rows.removeWhere((row) => row['id'] == id);
    await _writeRows(rows);
  }

  @override
  Future<HabitEntity> getHabit(String id) async {
    final rows = await _readRows();
    final row = rows.cast<Map<String, dynamic>?>().firstWhere(
      (row) => row?['id'] == id,
      orElse: () => null,
    );
    if (row == null) {
      throw Exception('عادت پیدا نشد');
    }
    return _fromJson(row);
  }

  @override
  Future<List<HabitEntity>> getHabits({bool? isActive}) async {
    final rows = await _readRows();
    var habits = rows.map(_fromJson).toList();
    if (isActive != null) {
      habits = habits.where((habit) => habit.isActive == isActive).toList();
    }
    return habits;
  }

  @override
  Future<List<HabitEntity>> getDueHabits() async {
    final habits = await getHabits(isActive: true);
    return habits.where((habit) => !habit.isCompletedToday).toList();
  }

  @override
  Future<Map<String, int>> getStreakStats(String habitId) async {
    final habit = await getHabit(habitId);
    return {
      'current': habit.currentStreak,
      'best': habit.bestStreak,
      'total': habit.totalCompletions,
    };
  }

  @override
  Future<HabitEntity> updateHabit(HabitEntity habit) async {
    final rows = await _readRows();
    final updatedRows = rows.map((row) {
      if (row['id'] == habit.id) {
        return {
          ..._toJson(habit),
          'id': habit.id,
          'created_at': row['created_at'],
          'updated_at': DateTime.now().toIso8601String(),
        };
      }
      return row;
    }).toList();

    await _writeRows(updatedRows);
    return habit.copyWith(updatedAt: DateTime.now());
  }

  Map<String, dynamic> _toJson(HabitEntity habit) => {
    'user_id': habit.userId,
    'name': habit.name,
    'description': habit.description,
    'frequency': habit.frequency.name,
    'target_days': habit.targetDays,
    'target_count': habit.targetCount,
    'icon_name': habit.iconName,
    'color_hex': habit.colorHex,
    'current_streak': habit.currentStreak,
    'best_streak': habit.bestStreak,
    'total_completions': habit.totalCompletions,
    'last_completed_at': habit.lastCompletedAt?.toIso8601String(),
    'is_active': habit.isActive,
  };

  HabitEntity _fromJson(Map<String, dynamic> json) => HabitEntity(
    id: json['id'] as String? ?? _uuid.v4(),
    userId: json['user_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    frequency: HabitFrequency.values.firstWhere(
      (frequency) => frequency.name == json['frequency'],
      orElse: () => HabitFrequency.daily,
    ),
    targetDays: json['target_days'] is List
        ? (json['target_days'] as List)
              .whereType<num>()
              .map((day) => day.toInt())
              .toList()
        : json['target_days'] is String
        ? (json['target_days'] as String)
              .split(',')
              .where((day) => day.isNotEmpty)
              .map(int.parse)
              .toList()
        : null,
    targetCount: json['target_count'] as int? ?? 1,
    iconName: json['icon_name'] as String?,
    colorHex: json['color_hex'] as String?,
    currentStreak: json['current_streak'] as int? ?? 0,
    bestStreak: json['best_streak'] as int? ?? 0,
    totalCompletions: json['total_completions'] as int? ?? 0,
    lastCompletedAt: json['last_completed_at'] != null
        ? DateTime.tryParse(json['last_completed_at'] as String)
        : null,
    isActive: json['is_active'] as bool? ?? true,
  );
}
