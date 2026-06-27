import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ai/ai_service.dart';
import '../../services/voice/voice_service.dart';
import '../../core/di/service_locator.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.isLoading = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<ChatState> {
  final AiService _aiService = ServiceLocator().get<AiService>();
  final VoiceService _voiceService = ServiceLocator().get<VoiceService>();
  final LocalDataSource _local = ServiceLocator().get<LocalDataSource>();
  final _uuid = const Uuid();

  ChatNotifier() : super(const ChatState());

  Future<void> sendMessage(String content) async {
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: content,
      isUser: true,
    );

    final loadingMessage = ChatMessage(
      id: _uuid.v4(),
      content: '',
      isUser: false,
      isLoading: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, loadingMessage],
      isLoading: true,
    );

    try {
      final result = await _aiService.processMessage(content);

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: result.persianResponse,
        isUser: false,
      );

      state = state.copyWith(
        messages: [...state.messages.where((m) => !m.isLoading), aiMessage],
        isLoading: false,
        error: null,
      );

      final shouldSpeak =
          _local.getBool(AppConstants.prefVoiceAssistantEnabled) ?? true;
      if (shouldSpeak) {
        await _voiceService.speak(result.persianResponse);
      }
    } catch (e) {
      state = state.copyWith(
        messages: state.messages.where((m) => !m.isLoading).toList(),
        isLoading: false,
        error: 'خطا در ارتباط با دستیار',
      );
    }
  }

  void clearChat() {
    _aiService.clearHistory();
    state = const ChatState();
  }
}
