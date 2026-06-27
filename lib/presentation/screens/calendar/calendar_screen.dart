import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/persian_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/task_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(taskProvider.notifier).loadTasks());
  }

  List<TaskEntity> _tasksForDay(List<TaskEntity> tasks, DateTime day) {
    return tasks.where((task) {
      final dueDate = task.dueDate;
      return dueDate != null &&
          dueDate.year == day.year &&
          dueDate.month == day.month &&
          dueDate.day == day.day;
    }).toList();
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return AppTheme.priorityCritical;
      case TaskPriority.high:
        return AppTheme.priorityHigh;
      case TaskPriority.medium:
        return AppTheme.priorityMedium;
      case TaskPriority.low:
        return AppTheme.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final tasks = taskState.tasks;
    final dayTasks = _tasksForDay(tasks, _selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text(PersianStrings.calendar)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/add', extra: _selectedDay),
        icon: const Icon(Icons.add),
        label: const Text(PersianStrings.addTask),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              border: Border(bottom: BorderSide(color: AppTheme.divider)),
            ),
            child: TableCalendar<TaskEntity>(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onPageChanged: (focused) => _focusedDay = focused,
              locale: 'fa_IR',
              eventLoader: (day) => _tasksForDay(tasks, day),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonTextStyle: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
                titleTextStyle: const TextStyle(color: AppTheme.textPrimary),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: AppTheme.textSecondary,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.gold,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppTheme.gold,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: const TextStyle(color: AppTheme.textPrimary),
                todayTextStyle: const TextStyle(color: AppTheme.textPrimary),
                selectedTextStyle: const TextStyle(color: AppTheme.bg),
                weekendTextStyle: const TextStyle(color: AppTheme.textMuted),
                outsideTextStyle: const TextStyle(color: AppTheme.textMuted),
                cellPadding: const EdgeInsets.all(6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'وظایف ${_selectedDay.year}/${_selectedDay.month}/${_selectedDay.day}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(taskProvider.notifier).loadTasks(),
                  child: const Text('به‌روزرسانی'),
                ),
              ],
            ),
          ),
          Expanded(
            child: taskState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : dayTasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: AppTheme.textMuted,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'وظیفه‌ای برای این روز ندارید',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: dayTasks.length,
                    itemBuilder: (context, index) {
                      final task = dayTasks[index];
                      final priorityColor = _priorityColor(task.priority);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: priorityColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 48,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  if (task.description != null &&
                                      task.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: AppTheme.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        task.dueTime != null
                                            ? task.dueTime!.format(context)
                                            : 'بدون زمان',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                size: 20,
                              ),
                              color: AppTheme.textMuted,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
