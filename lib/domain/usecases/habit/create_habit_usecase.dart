import '../../entities/habit_entity.dart';
import '../../repositories/habit_repository.dart';

class CreateHabitUseCase {
  final HabitRepository repository;
  CreateHabitUseCase(this.repository);

  Future<HabitEntity> call(HabitEntity habit) => repository.createHabit(habit);
}
