import '../../entities/ai_memory_entity.dart';
import '../../repositories/ai_memory_repository.dart';

class GetMemoriesUseCase {
  final AiMemoryRepository repository;
  GetMemoriesUseCase(this.repository);

  Future<List<AiMemoryEntity>> call({MemoryType? type, String? query, int limit = 20}) {
    return repository.getMemories(type: type, query: query, limit: limit);
  }
}
