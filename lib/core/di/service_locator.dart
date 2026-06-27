import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../data/repositories/ai_memory_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/ai_memory_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/task/create_task_usecase.dart';
import '../../domain/usecases/task/get_tasks_usecase.dart';
import '../../domain/usecases/task/update_task_usecase.dart';
import '../../domain/usecases/task/delete_task_usecase.dart';
import '../../domain/usecases/reminder/create_reminder_usecase.dart';
import '../../domain/usecases/reminder/get_reminders_usecase.dart';
import '../../domain/usecases/habit/create_habit_usecase.dart';
import '../../domain/usecases/habit/get_habits_usecase.dart';
import '../../domain/usecases/note/create_note_usecase.dart';
import '../../domain/usecases/note/get_notes_usecase.dart';
import '../../domain/usecases/ai_memory/save_memory_usecase.dart';
import '../../domain/usecases/ai_memory/get_memories_usecase.dart';
import '../../services/ai/ai_service.dart';
import '../../services/voice/voice_service.dart';
import '../../services/notification/notification_service.dart';
import '../../services/calendar_sync/calendar_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();
  factory ServiceLocator() => _instance;
  ServiceLocator._();

  final Map<Type, dynamic> _services = {};

  T get<T>() => _services[T] as T;
  bool isRegistered<T>() => _services.containsKey(T);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _services[SharedPreferences] = prefs;
    _services[FlutterSecureStorage] = const FlutterSecureStorage();
    _services[Connectivity] = Connectivity();
    _services[Dio] = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 30000),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _initDataSources();
    _initRepositories();
    _initUseCases();
    _initServices();
  }

  void _initDataSources() {
    _services[SupabaseDataSource] = SupabaseDataSource();
    _services[LocalDataSource] = LocalDataSource(
      _services[SharedPreferences],
      _services[FlutterSecureStorage],
    );
  }

  void _initRepositories() {
    _services[AuthRepository] = AuthRepositoryImpl(
      _services[SupabaseDataSource],
      _services[LocalDataSource],
    );
    _services[TaskRepository] = TaskRepositoryImpl(
      _services[SupabaseDataSource],
      _services[LocalDataSource],
    );
    _services[ReminderRepository] = ReminderRepositoryImpl(
      _services[SupabaseDataSource],
      _services[LocalDataSource],
    );
    _services[HabitRepository] = HabitRepositoryImpl(
      _services[SupabaseDataSource],
      _services[LocalDataSource],
    );
    _services[NoteRepository] = NoteRepositoryImpl(
      _services[SupabaseDataSource],
      _services[LocalDataSource],
    );
    _services[AiMemoryRepository] = AiMemoryRepositoryImpl(
      _services[SupabaseDataSource],
      _services[LocalDataSource],
    );
  }

  void _initUseCases() {
    _services[LoginUseCase] = LoginUseCase(_services[AuthRepository]);
    _services[RegisterUseCase] = RegisterUseCase(_services[AuthRepository]);
    _services[CreateTaskUseCase] = CreateTaskUseCase(_services[TaskRepository]);
    _services[GetTasksUseCase] = GetTasksUseCase(_services[TaskRepository]);
    _services[UpdateTaskUseCase] = UpdateTaskUseCase(_services[TaskRepository]);
    _services[DeleteTaskUseCase] = DeleteTaskUseCase(_services[TaskRepository]);
    _services[CreateReminderUseCase] = CreateReminderUseCase(
      _services[ReminderRepository],
    );
    _services[GetRemindersUseCase] = GetRemindersUseCase(
      _services[ReminderRepository],
    );
    _services[CreateHabitUseCase] = CreateHabitUseCase(
      _services[HabitRepository],
    );
    _services[GetHabitsUseCase] = GetHabitsUseCase(_services[HabitRepository]);
    _services[CreateNoteUseCase] = CreateNoteUseCase(_services[NoteRepository]);
    _services[GetNotesUseCase] = GetNotesUseCase(_services[NoteRepository]);
    _services[SaveMemoryUseCase] = SaveMemoryUseCase(
      _services[AiMemoryRepository],
    );
    _services[GetMemoriesUseCase] = GetMemoriesUseCase(
      _services[AiMemoryRepository],
    );
  }

  void _initServices() {
    _services[AiService] = AiService(
      _services[Dio],
      _services[SaveMemoryUseCase],
      _services[GetMemoriesUseCase],
    );
    _services[NotificationService] = NotificationService();
    _services[CalendarService] = CalendarService(_services[Dio]);
    _services[VoiceService] = VoiceService(_services[LocalDataSource]);
  }
}
