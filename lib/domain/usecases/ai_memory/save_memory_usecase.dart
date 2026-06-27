import '../../entities/ai_memory_entity.dart';
import '../../repositories/ai_memory_repository.dart';

class SaveMemoryUseCase {
  final AiMemoryRepository repository;
  SaveMemoryUseCase(this.repository);

  Future<AiMemoryEntity> call(AiMemoryEntity memory) => repository.saveMemory(memory);
}
