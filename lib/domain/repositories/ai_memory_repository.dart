import '../entities/ai_memory_entity.dart';

abstract class AiMemoryRepository {
  Future<List<AiMemoryEntity>> getMemories({MemoryType? type, String? query, int limit = 20});
  Future<AiMemoryEntity> saveMemory(AiMemoryEntity memory);
  Future<void> deleteMemory(String id);
  Future<void> incrementAccess(String id);
  Future<List<AiMemoryEntity>> getRecentMemories({int limit = 10});
  Future<List<AiMemoryEntity>> getTopMemories({int limit = 10});
}
