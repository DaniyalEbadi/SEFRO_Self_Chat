import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/usecases/habit/get_habits_usecase.dart';
import '../../domain/usecases/habit/create_habit_usecase.dart';
import '../../core/di/service_locator.dart';

class HabitState {
  final List<HabitEntity> habits;
  final bool isLoading;
  final String? error;

  const HabitState({this.habits = const [], this.isLoading = false, this.error});

  HabitState copyWith({List<HabitEntity>? habits, bool? isLoading, String? error}) {
    return HabitState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  return HabitNotifier();
});

class HabitNotifier extends StateNotifier<HabitState> {
  final GetHabitsUseCase _getHabits = ServiceLocator().get<GetHabitsUseCase>();
  final CreateHabitUseCase _createHabit = ServiceLocator().get<CreateHabitUseCase>();

  HabitNotifier() : super(const HabitState());

  Future<void> loadHabits() async {
    state = state.copyWith(isLoading: true);
    try {
      final habits = await _getHabits();
      state = state.copyWith(habits: habits, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createHabit(HabitEntity habit) async {
    try {
      await _createHabit(habit);
      await loadHabits();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
