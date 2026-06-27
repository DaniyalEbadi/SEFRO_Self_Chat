import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/persian_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/habit_entity.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final List<HabitEntity> _habits = [
    HabitEntity(id: '1', userId: '1', name: 'ورزش صبحگاهی', frequency: HabitFrequency.daily, currentStreak: 5, bestStreak: 12, totalCompletions: 45, iconName: 'fitness', colorHex: '#D4A843'),
    HabitEntity(id: '2', userId: '1', name: 'مطالعه کتاب', frequency: HabitFrequency.daily, currentStreak: 3, bestStreak: 30, totalCompletions: 120, iconName: 'book', colorHex: '#06B6D4'),
    HabitEntity(id: '3', userId: '1', name: 'نوشیدن آب', frequency: HabitFrequency.daily, currentStreak: 7, bestStreak: 21, totalCompletions: 200, iconName: 'water', colorHex: '#10B981'),
    HabitEntity(id: '4', userId: '1', name: 'مدیتیشن', frequency: HabitFrequency.daily, currentStreak: 0, bestStreak: 7, totalCompletions: 30, iconName: 'meditation', colorHex: '#E11D48'),
  ];

  IconData _getIcon(String? name) {
    switch (name) {
      case 'fitness': return Icons.fitness_center;
      case 'book': return Icons.menu_book;
      case 'water': return Icons.water_drop;
      case 'meditation': return Icons.self_improvement;
      default: return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PersianStrings.habits)),
      body: Column(
        children: [
          _StreakSummary(currentStreak: 5, bestStreak: 30),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                final color = Color(int.parse(habit.colorHex!.replaceFirst('#', '0xFF')));
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_getIcon(habit.iconName), color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (habit.isCompletedToday)
                                  Chip(
                                    label: const Text('انجام شد', style: TextStyle(fontSize: 10, color: Colors.white)),
                                    backgroundColor: AppTheme.emerald,
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  )
                                else
                                  Chip(
                                    label: const Text('امروز', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                                    backgroundColor: AppTheme.card,
                                    side: BorderSide(color: AppTheme.cardBorder),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                const SizedBox(width: 8),
                                Icon(Icons.local_fire_department, size: 14, color: AppTheme.gold),
                                const SizedBox(width: 4),
                                Text('${habit.currentStreak} روز', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: habit.isCompletedToday,
                        onChanged: (_) {},
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        activeColor: AppTheme.emerald,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/habits/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StreakSummary extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  const _StreakSummary({required this.currentStreak, required this.bestStreak});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gold.withValues(alpha: 0.2), AppTheme.gold.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Icon(Icons.local_fire_department, color: AppTheme.gold, size: 32),
              const SizedBox(height: 4),
              Text('$currentStreak', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const Text(PersianStrings.currentStreak, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          Container(width: 1, height: 40, color: AppTheme.divider),
          Column(
            children: [
              const Icon(Icons.emoji_events, color: AppTheme.gold, size: 32),
              const SizedBox(height: 4),
              Text('$bestStreak', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const Text(PersianStrings.bestStreak, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
