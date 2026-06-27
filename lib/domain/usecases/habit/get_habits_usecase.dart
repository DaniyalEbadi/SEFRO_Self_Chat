import '../../entities/habit_entity.dart';
import '../../repositories/habit_repository.dart';

class GetHabitsUseCase {
  final HabitRepository repository;
  GetHabitsUseCase(this.repository);

  Future<List<HabitEntity>> call({bool? isActive}) {
    return repository.getHabits(isActive: isActive);
  }
}
