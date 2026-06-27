import 'package:dio/dio.dart';

import '../../core/utils/logger.dart';
import '../../data/datasources/remote/ai_datasource.dart';
import '../../domain/entities/ai_memory_entity.dart';
import '../../domain/entities/daily_plan_entity.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/ai_memory/get_memories_usecase.dart';
import '../../domain/usecases/ai_memory/save_memory_usecase.dart';

class IntentResult {
  final String intent;
  final Map<String, dynamic> entities;
  final String persianResponse;
  final TaskEntity? task;
  final ReminderEntity? reminder;
  final EventEntity? event;

  IntentResult({
    required this.intent,
    this.entities = const {},
    required this.persianResponse,
    this.task,
    this.reminder,
    this.event,
  });
}

class AiService {
  final Dio _dio;
  final SaveMemoryUseCase _saveMemory;
  final GetMemoriesUseCase _getMemories;
  late final AiDataSource _dataSource;
  final List<Map<String, String>> _conversationHistory = [];
  String? _userId;

  AiService(this._dio, this._saveMemory, this._getMemories) {
    _dataSource = AiDataSource(_dio);
  }

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<List<AiMemoryEntity>> getPersonalizedContext() async {
    if (_userId == null) return [];
    return _getMemories();
  }

  Future<IntentResult> processMessage(String userMessage) async {
    final context = await _buildContextPrompt();
    final messages = [
      {'role': 'system', 'content': _systemPrompt + context},
      ..._conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];

    final response = await _dataSource.chatWithOpenAI(messages);
    if (response.error != null) {
      return IntentResult(
        intent: 'UNKNOWN',
        persianResponse: 'متأسفانه خطایی رخ داد. لطفاً دوباره تلاش کنید.',
      );
    }

    _conversationHistory.add({'role': 'user', 'content': userMessage});
    _conversationHistory.add({
      'role': 'assistant',
      'content': response.content,
    });
    if (_conversationHistory.length > 20) {
      _conversationHistory.removeRange(0, 2);
    }

    await _learnFromMessage(userMessage, response);

    return _parseIntent(response);
  }

  String get _systemPrompt => '''
شما یک دستیار شخصی هوشمند و حرفه‌ای هستید که به زبان فارسی صحبت می‌کنید.
نام شما "منشی هوشمند" است.
شما می‌توانید:
- وظایف جدید ایجاد کنید
- یادآوری تنظیم کنید
- رویدادهای تقویم را مدیریت کنید
- برنامه روزانه پیشنهاد دهید
- به سوالات پاسخ دهید
- خاطرات و اطلاعات کاربر را ذخیره کنید

برای اقدامات خاص از این فرمت استفاده کنید:
[TASK] برای وظیفه
[MEETING] برای جلسه
[REMINDER] برای یادآوری
[NOTE] برای یادداشت
[QUERY] برای سوال
[GREETING] برای سلام

و اطلاعات ساخت‌یافته را در JSON قرار دهید:
{"title": "...", "date": "...", "time": "...", "person": "...", "location": "..."}

همیشه پاسخ خود را با لحنی گرم و دوستانه بدهید.
از کاربر درباره جزئیات نامشخص سوال بپرسید.
پاسخ‌ها باید مختصر و مفید باشند.
''';

  Future<String> _buildContextPrompt() async {
    if (_userId == null) return '';
    try {
      final memories = await _getMemories(limit: 5);
      if (memories.isEmpty) return '';
      return '\n\nاطلاعات مربوط به کاربر:\n${memories.map((m) => '- ${m.key}: ${m.value}').join('\n')}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _learnFromMessage(String userMessage, _) async {
    if (_userId == null) return;
    try {
      final personName = RegExp(
        r'با\s+(\S+)',
      ).firstMatch(userMessage)?.group(1);
      if (personName != null) {
        await _saveMemory(
          AiMemoryEntity(
            id: '',
            userId: _userId!,
            type: MemoryType.contact,
            key: 'contact_${personName.toLowerCase()}',
            value: personName,
            metadata: {'source': 'chat', 'count': 1},
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Learn error', e);
    }
  }

  IntentResult _parseIntent(AiResponse response) {
    return IntentResult(
      intent: response.intent ?? 'GENERAL',
      entities: response.extractedEntities ?? const {},
      persianResponse: response.content.trim().isNotEmpty
          ? response.content.trim()
          : 'چطور می‌توانم به شما کمک کنم؟',
    );
  }

  Future<DailyPlanEntity> generateDailyPlan(DateTime date) async {
    return DailyPlanEntity(
      date: date,
      greeting: 'صبح بخیر! امروز ${date.toLocal()} یک روز عالی برای شروع است.',
      morningItems: [],
      afternoonItems: [],
      eveningItems: [],
      priorities: ['تمرکز روی مهم‌ترین وظایف'],
      suggestions: ['با یک کار کوچک شروع کنید'],
      productivityScore: 0.0,
    );
  }

  Future<String> generateEveningReview() async {
    return '''
خلاصه روزانه:
✓ امروز ۳ وظیفه انجام شد
✗ ۱ وظیفه باقی ماند
امتیاز بهره‌وری: ۷۵٪
پیشنهاد: فردا با اولویت‌بندی بهتر شروع کنید.
''';
  }

  void clearHistory() {
    _conversationHistory.clear();
  }
}
