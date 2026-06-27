import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/persian_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/task_provider.dart';
import '../../widgets/tasks/task_filter_bar.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(taskProvider.notifier).loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final tasks = taskState.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(PersianStrings.tasks),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          TaskFilterBar(
            selectedCategory: taskState.selectedCategory,
            selectedStatus: taskState.selectedStatus,
            onCategoryChanged: (c) => ref.read(taskProvider.notifier).setCategoryFilter(c),
            onStatusChanged: (s) => ref.read(taskProvider.notifier).setStatusFilter(s),
          ),
          Expanded(
            child: taskState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                    ? _EmptyTasks()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) => _TaskListItem(
                          task: tasks[index],
                          onToggle: () => ref.read(taskProvider.notifier).toggleTaskStatus(tasks[index]),
                          onDelete: () => ref.read(taskProvider.notifier).deleteTask(tasks[index].id),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          const Text('وظیفه‌ای وجود ندارد', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          const Text('وظیفه جدید اضافه کنید', style: TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskListItem({required this.task, required this.onToggle, required this.onDelete});

  Color _priorityColor() {
    switch (task.priority) {
      case TaskPriority.critical: return AppTheme.priorityCritical;
      case TaskPriority.high: return AppTheme.priorityHigh;
      case TaskPriority.medium: return AppTheme.priorityMedium;
      case TaskPriority.low: return AppTheme.priorityLow;
    }
  }

  Color _categoryColor() {
    switch (task.category) {
      case TaskCategory.work: return AppTheme.categoryWork;
      case TaskCategory.personal: return AppTheme.categoryPersonal;
      case TaskCategory.health: return AppTheme.categoryHealth;
      case TaskCategory.education: return AppTheme.categoryEducation;
      case TaskCategory.finance: return AppTheme.categoryFinance;
      case TaskCategory.family: return AppTheme.categoryFamily;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isOverdue ? AppTheme.rose.withValues(alpha: 0.3) : AppTheme.cardBorder,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(
                task.status == TaskStatus.completed
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked_outlined,
                color: task.status == TaskStatus.completed
                    ? AppTheme.emerald
                    : AppTheme.textMuted,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    decoration: task.status == TaskStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.status == TaskStatus.completed
                        ? AppTheme.textMuted
                        : AppTheme.textPrimary,
                  ),
                ),
                if (task.description != null && task.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      task.description!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _categoryColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.category.name,
                        style: TextStyle(fontSize: 10, color: _categoryColor()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _priorityColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${task.dueDate!.month}/${task.dueDate!.day}',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                    if (task.isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.rose.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('دیر شده', style: TextStyle(fontSize: 10, color: AppTheme.rose)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') context.push('/tasks/edit/${task.id}');
              if (v == 'delete') onDelete();
            },
            icon: Icon(Icons.more_vert, color: AppTheme.textMuted, size: 20),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text(PersianStrings.edit)),
              const PopupMenuItem(value: 'delete', child: Text(PersianStrings.delete)),
            ],
          ),
        ],
      ),
    );
  }
}
