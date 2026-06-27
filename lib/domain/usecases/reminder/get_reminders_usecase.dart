import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';

class GetRemindersUseCase {
  final ReminderRepository repository;
  GetRemindersUseCase(this.repository);

  Future<List<ReminderEntity>> call({bool? isActive}) {
    return repository.getReminders(isActive: isActive);
  }
}
