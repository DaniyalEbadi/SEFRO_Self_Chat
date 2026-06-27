import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/voice/voice_service.dart';
import '../../core/di/service_locator.dart';

class VoiceState {
  final bool isListening;
  final bool isSpeaking;
  final String? recognizedText;
  final String? error;

  const VoiceState({
    this.isListening = false,
    this.isSpeaking = false,
    this.recognizedText,
    this.error,
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isSpeaking,
    String? recognizedText,
    String? error,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      recognizedText: recognizedText ?? this.recognizedText,
      error: error,
    );
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  return VoiceNotifier();
});

class VoiceNotifier extends StateNotifier<VoiceState> {
  final VoiceService _voiceService;

  VoiceNotifier()
    : _voiceService = ServiceLocator().get<VoiceService>(),
      super(const VoiceState());

  Future<void> initialize() async {
    await _voiceService.initialize();
  }

  Future<void> startListening() async {
    state = state.copyWith(
      isListening: true,
      error: null,
      recognizedText: null,
    );
    await _voiceService.startListening(
      onResult: (text) {
        state = state.copyWith(recognizedText: text, isListening: false);
      },
      onError: (error) {
        state = state.copyWith(error: error, isListening: false);
      },
    );
  }

  Future<void> stopListening() async {
    await _voiceService.stopListening();
    state = state.copyWith(isListening: false);
  }

  Future<void> speak(String text) async {
    state = state.copyWith(isSpeaking: true);
    await _voiceService.speak(text);
    state = state.copyWith(isSpeaking: false);
  }

  Future<void> stopSpeaking() async {
    await _voiceService.stopSpeaking();
    state = state.copyWith(isSpeaking: false);
  }

  void clearRecognizedText() {
    state = state.copyWith(recognizedText: null);
  }
}
