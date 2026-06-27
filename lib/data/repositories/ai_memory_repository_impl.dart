import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../domain/entities/ai_memory_entity.dart';
import '../../domain/repositories/ai_memory_repository.dart';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';

class AiMemoryRepositoryImpl implements AiMemoryRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;
  final _uuid = const Uuid();
  static const _storageKey = 'ai_memory_cache';

  AiMemoryRepositoryImpl(this._supabase, this._local);

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
  Future<void> deleteMemory(String id) async {
    final rows = await _readRows();
    rows.removeWhere((row) => row['id'] == id);
    await _writeRows(rows);
  }

  @override
  Future<List<AiMemoryEntity>> getMemories({
    MemoryType? type,
    String? query,
    int limit = 20,
  }) async {
    final rows = await _readRows();
    var memories = rows.map(_fromJson).toList();
    if (type != null) {
      memories = memories.where((memory) => memory.type == type).toList();
    }
    if (query != null && query.isNotEmpty) {
      final lowered = query.toLowerCase();
      memories = memories
          .where(
            (memory) =>
                memory.key.toLowerCase().contains(lowered) ||
                memory.value.toLowerCase().contains(lowered),
          )
          .toList();
    }
    return memories.take(limit).toList();
  }

  @override
  Future<List<AiMemoryEntity>> getRecentMemories({int limit = 10}) async {
    final memories = await getMemories();
    memories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return memories.take(limit).toList();
  }

  @override
  Future<List<AiMemoryEntity>> getTopMemories({int limit = 10}) async {
    final memories = await getMemories();
    memories.sort((a, b) => b.accessCount.compareTo(a.accessCount));
    return memories.take(limit).toList();
  }

  @override
  Future<void> incrementAccess(String id) async {
    final memory = await _getMemoryById(id);
    if (memory == null) return;

    await saveMemory(
      memory.copyWith(
        accessCount: memory.accessCount + 1,
        lastAccessedAt: DateTime.now(),
      ),
    );
  }

  Future<AiMemoryEntity?> _getMemoryById(String id) async {
    final memories = await getMemories(limit: 1000);
    try {
      return memories.firstWhere((memory) => memory.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AiMemoryEntity> saveMemory(AiMemoryEntity memory) async {
    final rows = await _readRows();
    final now = DateTime.now().toIso8601String();
    final id = memory.id.isEmpty ? _uuid.v4() : memory.id;
    final data = _toJson(memory)
      ..['id'] = id
      ..['created_at'] = memory.createdAt.toIso8601String()
      ..['updated_at'] = now;

    rows.removeWhere((row) => row['id'] == id);
    rows.add(data);
    await _writeRows(rows);
    return _fromJson(data);
  }

  Map<String, dynamic> _toJson(AiMemoryEntity memory) => {
    'user_id': memory.userId,
    'type': memory.type.name,
    'key': memory.key,
    'value': memory.value,
    'metadata': memory.metadata,
    'confidence': memory.confidence,
    'access_count': memory.accessCount,
    'last_accessed_at': memory.lastAccessedAt?.toIso8601String(),
  };

  AiMemoryEntity _fromJson(Map<String, dynamic> json) => AiMemoryEntity(
    id: json['id'] as String? ?? _uuid.v4(),
    userId: json['user_id'] as String? ?? '',
    type: MemoryType.values.firstWhere(
      (memoryType) => memoryType.name == json['type'],
      orElse: () => MemoryType.fact,
    ),
    key: json['key'] as String? ?? '',
    value: json['value'] as String? ?? '',
    metadata: json['metadata'] as Map<String, dynamic>?,
    confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    accessCount: json['access_count'] as int? ?? 0,
    lastAccessedAt: json['last_accessed_at'] != null
        ? DateTime.tryParse(json['last_accessed_at'] as String)
        : null,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : DateTime.now(),
  );
}
