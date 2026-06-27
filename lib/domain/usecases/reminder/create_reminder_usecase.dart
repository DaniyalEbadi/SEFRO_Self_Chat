import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';

class CreateReminderUseCase {
  final ReminderRepository repository;
  CreateReminderUseCase(this.repository);

  Future<ReminderEntity> call(ReminderEntity reminder) => repository.createReminder(reminder);
}
