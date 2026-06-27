import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task/get_tasks_usecase.dart';
import '../../domain/usecases/task/create_task_usecase.dart';
import '../../domain/usecases/task/update_task_usecase.dart';
import '../../domain/usecases/task/delete_task_usecase.dart';
import '../../core/di/service_locator.dart';

class TaskState {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;
  final String? selectedStatus;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.selectedStatus,
  });

  TaskState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? selectedStatus,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<TaskState> {
  final GetTasksUseCase _getTasks = ServiceLocator().get<GetTasksUseCase>();
  final CreateTaskUseCase _createTask = ServiceLocator().get<CreateTaskUseCase>();
  final UpdateTaskUseCase _updateTask = ServiceLocator().get<UpdateTaskUseCase>();
  final DeleteTaskUseCase _deleteTask = ServiceLocator().get<DeleteTaskUseCase>();

  TaskNotifier() : super(const TaskState());

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true);
    try {
      final tasks = await _getTasks(
        category: state.selectedCategory,
        status: state.selectedStatus,
      );
      state = state.copyWith(tasks: tasks, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createTask(TaskEntity task) async {
    try {
      await _createTask(task);
      await loadTasks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    try {
      await _updateTask(task);
      await loadTasks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _deleteTask(id);
      await loadTasks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleTaskStatus(TaskEntity task) async {
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;
    await updateTask(task.copyWith(status: newStatus));
  }

  void setCategoryFilter(String? category) {
    state = state.copyWith(selectedCategory: category);
    loadTasks();
  }

  void setStatusFilter(String? status) {
    state = state.copyWith(selectedStatus: status);
    loadTasks();
  }

  List<TaskEntity> get todayTasks => state.tasks.where((t) {
    if (t.dueDate == null) return false;
    final now = DateTime.now();
    return t.dueDate!.year == now.year &&
        t.dueDate!.month == now.month &&
        t.dueDate!.day == now.day;
  }).toList();

  List<TaskEntity> get pendingTasks =>
      state.tasks.where((t) => t.status != TaskStatus.completed).toList();

  List<TaskEntity> get completedTasks =>
      state.tasks.where((t) => t.status == TaskStatus.completed).toList();
}
