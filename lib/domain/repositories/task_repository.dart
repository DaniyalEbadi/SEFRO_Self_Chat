import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks({String? category, String? status, String? query});
  Future<TaskEntity> getTask(String id);
  Future<TaskEntity> createTask(TaskEntity task);
  Future<TaskEntity> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<List<TaskEntity>> getTodayTasks();
  Future<List<TaskEntity>> getUpcomingTasks({int days = 7});
  Future<int> getCompletedCount(DateTime start, DateTime end);
  Future<double> getCompletionRate(DateTime start, DateTime end);
}
