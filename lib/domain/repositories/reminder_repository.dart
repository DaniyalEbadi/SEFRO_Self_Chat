import '../entities/reminder_entity.dart';

abstract class ReminderRepository {
  Future<List<ReminderEntity>> getReminders({bool? isActive});
  Future<ReminderEntity> getReminder(String id);
  Future<ReminderEntity> createReminder(ReminderEntity reminder);
  Future<ReminderEntity> updateReminder(ReminderEntity reminder);
  Future<void> deleteReminder(String id);
  Future<List<ReminderEntity>> getDueReminders();
  Future<void> acknowledgeReminder(String id);
}
