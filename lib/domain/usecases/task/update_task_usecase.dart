import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;
  UpdateTaskUseCase(this.repository);

  Future<TaskEntity> call(TaskEntity task) => repository.updateTask(task);
}
