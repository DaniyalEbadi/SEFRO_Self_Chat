import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/persian_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../data/datasources/local/local_datasource.dart';
import '../../providers/task_provider.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final DateTime? initialDueDate;

  const AddTaskScreen({super.key, this.taskId, this.initialDueDate});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();
  final TaskRepository _taskRepository = ServiceLocator().get<TaskRepository>();
  final LocalDataSource _local = ServiceLocator().get<LocalDataSource>();

  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.personal;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.initialDueDate;
    if (widget.taskId != null) {
      Future.microtask(_loadExistingTask);
    }
  }

  Future<void> _loadExistingTask() async {
    try {
      final task = await _taskRepository.getTask(widget.taskId!);
      if (!mounted) return;
      setState(() {
        _titleController.text = task.title;
        _descriptionController.text = task.description ?? '';
        _priority = task.priority;
        _category = task.category;
        _dueDate = task.dueDate ?? _dueDate;
        _dueTime = task.dueTime;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(PersianStrings.addTask)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: PersianStrings.taskTitle,
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'عنوان را وارد کنید' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: PersianStrings.taskDescription,
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text(
                PersianStrings.priority,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _PrioritySelector(
                selected: _priority,
                onChanged: (p) => setState(() => _priority = p),
              ),
              const SizedBox(height: 16),
              Text(
                PersianStrings.category,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _CategorySelector(
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _dueDate != null
                      ? '${_dueDate!.year}/${_dueDate!.month}/${_dueDate!.day}'
                      : 'انتخاب تاریخ',
                ),
                trailing: _dueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dueDate = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _dueDate = date);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  _dueTime != null
                      ? '${_dueTime!.hour}:${_dueTime!.minute.toString().padLeft(2, '0')}'
                      : 'انتخاب زمان',
                ),
                trailing: _dueTime != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dueTime = null),
                      )
                    : null,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) setState(() => _dueTime = time);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text(PersianStrings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUserId =
        _local.getString(AppConstants.prefUserId) ?? 'current_user';
    final task = TaskEntity(
      id: widget.taskId ?? _uuid.v4(),
      userId: currentUserId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      dueDate: _dueDate,
      dueTime: _dueTime,
      priority: _priority,
      category: _category,
    );
    if (widget.taskId == null) {
      await ref.read(taskProvider.notifier).createTask(task);
    } else {
      await ref.read(taskProvider.notifier).updateTask(task);
    }
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _PrioritySelector extends StatelessWidget {
  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  const _PrioritySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final priorities = TaskPriority.values;
    final labels = {
      TaskPriority.critical: PersianStrings.critical,
      TaskPriority.high: PersianStrings.high,
      TaskPriority.medium: PersianStrings.medium,
      TaskPriority.low: PersianStrings.low,
    };
    final colors = {
      TaskPriority.critical: AppTheme.priorityCritical,
      TaskPriority.high: AppTheme.priorityHigh,
      TaskPriority.medium: AppTheme.priorityMedium,
      TaskPriority.low: AppTheme.priorityLow,
    };

    return Row(
      children: priorities.map((p) {
        final isSelected = p == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(p),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? colors[p]!.withValues(alpha: 0.15) : null,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? colors[p]! : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                labels[p]!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colors[p] : null,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final TaskCategory selected;
  final ValueChanged<TaskCategory> onChanged;

  const _CategorySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final categories = TaskCategory.values;
    final labels = {
      TaskCategory.work: PersianStrings.work,
      TaskCategory.personal: PersianStrings.personal,
      TaskCategory.health: PersianStrings.health,
      TaskCategory.education: PersianStrings.education,
      TaskCategory.finance: PersianStrings.finance,
      TaskCategory.family: PersianStrings.family,
    };
    final icons = {
      TaskCategory.work: Icons.work,
      TaskCategory.personal: Icons.person,
      TaskCategory.health: Icons.favorite,
      TaskCategory.education: Icons.school,
      TaskCategory.finance: Icons.attach_money,
      TaskCategory.family: Icons.family_restroom,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) {
        final isSelected = c == selected;
        return ChoiceChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icons[c]!, size: 16),
              const SizedBox(width: 6),
              Text(labels[c]!),
            ],
          ),
          onSelected: (_) => onChanged(c),
        );
      }).toList(),
    );
  }
}
