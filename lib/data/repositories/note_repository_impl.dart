import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';

class NoteRepositoryImpl implements NoteRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;
  final _uuid = const Uuid();
  static const _storageKey = 'notes_cache';

  NoteRepositoryImpl(this._supabase, this._local);

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
  Future<NoteEntity> createNote(NoteEntity note) async {
    final rows = await _readRows();
    final now = DateTime.now().toIso8601String();
    final id = note.id.isEmpty ? _uuid.v4() : note.id;
    final data = _toJson(note)
      ..['id'] = id
      ..['created_at'] = now
      ..['updated_at'] = now;
    rows.add(data);
    await _writeRows(rows);
    return _fromJson(data);
  }

  @override
  Future<void> deleteNote(String id) async {
    final rows = await _readRows();
    rows.removeWhere((row) => row['id'] == id);
    await _writeRows(rows);
  }

  @override
  Future<NoteEntity> getNote(String id) async {
    final rows = await _readRows();
    final row = rows.cast<Map<String, dynamic>?>().firstWhere(
      (row) => row?['id'] == id,
      orElse: () => null,
    );
    if (row == null) {
      throw Exception('یادداشت پیدا نشد');
    }
    return _fromJson(row);
  }

  @override
  Future<List<NoteEntity>> getNotes({String? query, bool? pinned}) async {
    final rows = await _readRows();
    var notes = rows.map(_fromJson).toList();
    if (pinned != null) {
      notes = notes.where((note) => note.isPinned == pinned).toList();
    }
    if (query != null && query.isNotEmpty) {
      final lowered = query.toLowerCase();
      notes = notes
          .where(
            (note) =>
                note.title.toLowerCase().contains(lowered) ||
                note.content.toLowerCase().contains(lowered),
          )
          .toList();
    }
    return notes;
  }

  @override
  Future<NoteEntity> togglePin(String id) async {
    final note = await getNote(id);
    return updateNote(note.copyWith(isPinned: !note.isPinned));
  }

  @override
  Future<NoteEntity> updateNote(NoteEntity note) async {
    final rows = await _readRows();
    final updatedRows = rows.map((row) {
      if (row['id'] == note.id) {
        return {
          ..._toJson(note),
          'id': note.id,
          'created_at': row['created_at'],
          'updated_at': DateTime.now().toIso8601String(),
        };
      }
      return row;
    }).toList();

    await _writeRows(updatedRows);
    return note.copyWith(updatedAt: DateTime.now());
  }

  Map<String, dynamic> _toJson(NoteEntity note) => {
    'user_id': note.userId,
    'title': note.title,
    'content': note.content,
    'is_pinned': note.isPinned,
    'tags': note.tags,
    'color_hex': note.colorHex,
  };

  NoteEntity _fromJson(Map<String, dynamic> json) => NoteEntity(
    id: json['id'] as String? ?? _uuid.v4(),
    userId: json['user_id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    isPinned: json['is_pinned'] as bool? ?? false,
    tags: json['tags'] is List
        ? (json['tags'] as List).whereType<String>().toList()
        : json['tags'] is String
        ? (json['tags'] as String)
              .split(',')
              .where((tag) => tag.isNotEmpty)
              .toList()
        : null,
    colorHex: json['color_hex'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : DateTime.now(),
  );
}
