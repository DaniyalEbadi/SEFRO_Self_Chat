import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;
  final _uuid = const Uuid();
  static const _storageKey = 'tasks_cache';

  TaskRepositoryImpl(this._supabase, this._local);

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
  Future<TaskEntity> createTask(TaskEntity task) async {
    final rows = await _readRows();
    final now = DateTime.now().toIso8601String();
    final id = task.id.isEmpty ? _uuid.v4() : task.id;
    final data = _toJson(task)
      ..['id'] = id
      ..['created_at'] = now
      ..['updated_at'] = now;
    rows.add(data);
    await _writeRows(rows);
    return _fromJson(data);
  }

  @override
  Future<void> deleteTask(String id) async {
    final rows = await _readRows();
    rows.removeWhere((row) => row['id'] == id);
    await _writeRows(rows);
  }

  @override
  Future<TaskEntity> getTask(String id) async {
    final rows = await _readRows();
    final row = rows.cast<Map<String, dynamic>?>().firstWhere(
      (row) => row?['id'] == id,
      orElse: () => null,
    );
    if (row == null) {
      throw Exception('وظیفه پیدا نشد');
    }
    return _fromJson(row);
  }

  @override
  Future<List<TaskEntity>> getTasks({
    String? category,
    String? status,
    String? query,
  }) async {
    final rows = await _readRows();
    var tasks = rows.map(_fromJson).toList();

    if (category != null && category.isNotEmpty) {
      tasks = tasks.where((task) => task.category.name == category).toList();
    }
    if (status != null && status.isNotEmpty) {
      tasks = tasks.where((task) => task.status.name == status).toList();
    }
    if (query != null && query.isNotEmpty) {
      final lowered = query.toLowerCase();
      tasks = tasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(lowered) ||
                (task.description ?? '').toLowerCase().contains(lowered) ||
                (task.notes ?? '').toLowerCase().contains(lowered),
          )
          .toList();
    }

    return tasks;
  }

  @override
  Future<List<TaskEntity>> getTodayTasks() async {
    final tasks = await getTasks();
    final now = DateTime.now();
    return tasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.year == now.year &&
              task.dueDate!.month == now.month &&
              task.dueDate!.day == now.day &&
              task.status != TaskStatus.completed,
        )
        .toList();
  }

  @override
  Future<List<TaskEntity>> getUpcomingTasks({int days = 7}) async {
    final tasks = await getTasks();
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    return tasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.isAfter(now) &&
              task.dueDate!.isBefore(end) &&
              task.status != TaskStatus.completed,
        )
        .toList();
  }

  @override
  Future<int> getCompletedCount(DateTime start, DateTime end) async {
    final tasks = await getTasks();
    return tasks
        .where(
          (task) =>
              task.status == TaskStatus.completed &&
              task.updatedAt.isAfter(start) &&
              task.updatedAt.isBefore(end),
        )
        .length;
  }

  @override
  Future<double> getCompletionRate(DateTime start, DateTime end) async {
    final tasks = await getTasks();
    final total = tasks
        .where(
          (task) =>
              task.createdAt.isAfter(start) && task.createdAt.isBefore(end),
        )
        .length;
    if (total == 0) return 0;

    final completed = tasks
        .where(
          (task) =>
              task.status == TaskStatus.completed &&
              task.updatedAt.isAfter(start) &&
              task.updatedAt.isBefore(end),
        )
        .length;
    return completed / total;
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    final rows = await _readRows();
    final updatedRows = rows.map((row) {
      if (row['id'] == task.id) {
        return {
          ..._toJson(task),
          'id': task.id,
          'created_at': row['created_at'],
          'updated_at': DateTime.now().toIso8601String(),
        };
      }
      return row;
    }).toList();

    await _writeRows(updatedRows);
    return task.copyWith(updatedAt: DateTime.now());
  }

  Map<String, dynamic> _toJson(TaskEntity task) => {
    'user_id': task.userId,
    'title': task.title,
    'description': task.description,
    'due_date': task.dueDate?.toIso8601String(),
    'due_time': task.dueTime != null
        ? {'hour': task.dueTime!.hour, 'minute': task.dueTime!.minute}
        : null,
    'priority': task.priority.name,
    'category': task.category.name,
    'status': task.status.name,
    'attachments': task.attachments,
    'notes': task.notes,
  };

  TaskEntity _fromJson(Map<String, dynamic> json) => TaskEntity(
    id: json['id'] as String? ?? _uuid.v4(),
    userId: json['user_id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    dueDate: json['due_date'] != null
        ? DateTime.tryParse(json['due_date'] as String)
        : null,
    dueTime: json['due_time'] is Map<String, dynamic>
        ? TimeOfDay(
            hour: (json['due_time'] as Map<String, dynamic>)['hour'] as int,
            minute: (json['due_time'] as Map<String, dynamic>)['minute'] as int,
          )
        : null,
    priority: TaskPriority.values.firstWhere(
      (priority) => priority.name == json['priority'],
      orElse: () => TaskPriority.medium,
    ),
    category: TaskCategory.values.firstWhere(
      (category) => category.name == json['category'],
      orElse: () => TaskCategory.personal,
    ),
    status: TaskStatus.values.firstWhere(
      (status) => status.name == json['status'],
      orElse: () => TaskStatus.pending,
    ),
    attachments: json['attachments'] is List
        ? (json['attachments'] as List).whereType<String>().toList()
        : json['attachments'] is String
        ? (json['attachments'] as String)
              .split(',')
              .where((item) => item.isNotEmpty)
              .toList()
        : null,
    notes: json['notes'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : DateTime.now(),
  );
}
