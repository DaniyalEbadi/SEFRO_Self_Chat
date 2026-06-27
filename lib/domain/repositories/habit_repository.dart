import '../entities/habit_entity.dart';

abstract class HabitRepository {
  Future<List<HabitEntity>> getHabits({bool? isActive});
  Future<HabitEntity> getHabit(String id);
  Future<HabitEntity> createHabit(HabitEntity habit);
  Future<HabitEntity> updateHabit(HabitEntity habit);
  Future<void> deleteHabit(String id);
  Future<HabitEntity> completeHabit(String id);
  Future<List<HabitEntity>> getDueHabits();
  Future<Map<String, int>> getStreakStats(String habitId);
}
