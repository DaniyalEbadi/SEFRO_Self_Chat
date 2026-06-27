import 'package:flutter/material.dart';

enum TaskPriority { critical, high, medium, low }
enum TaskCategory { work, personal, health, education, finance, family }
enum TaskStatus { pending, inProgress, completed, cancelled }

class TaskEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final TaskPriority priority;
  final TaskCategory category;
  final TaskStatus status;
  final List<String>? attachments;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.dueTime,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
    this.status = TaskStatus.pending,
    this.attachments,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isOverdue {
    if (status == TaskStatus.completed) return false;
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueSoon {
    if (dueDate == null) return false;
    return dueDate!.difference(DateTime.now()).inHours <= 24 && dueDate!.isAfter(DateTime.now());
  }

  TaskEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    TaskPriority? priority,
    TaskCategory? category,
    TaskStatus? status,
    List<String>? attachments,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
