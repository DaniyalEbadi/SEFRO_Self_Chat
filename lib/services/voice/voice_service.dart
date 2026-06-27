import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/datasources/local/local_datasource.dart';

enum VoiceGender { female, male }

class VoiceService {
  final LocalDataSource _local;
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _initialized = false;
  String? _selectedLocaleId;

  VoiceService(this._local);

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      final hasSpeech = await _speechToText.initialize(
        onStatus: (status) {
          _isListening = status == 'listening';
        },
        onError: (error) {
          _isListening = false;
          AppLogger.error('Speech error', error.errorMsg);
        },
      );

      if (!hasSpeech) {
        return false;
      }

      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.setLanguage(await _preferredLocale());
      await _flutterTts.setSpeechRate(_preferredSpeed());
      await _flutterTts.setPitch(1.0);

      _initialized = true;
      return true;
    } catch (e) {
      AppLogger.error('Voice init error', e);
      return false;
    }
  }

  Future<void> configureVoice() async {
    if (!_initialized) {
      await initialize();
    }
    try {
      final localeId = await _preferredLocale();
      _selectedLocaleId = localeId;
      final gender = await preferredGender();
      await _flutterTts.setLanguage(localeId);
      await _flutterTts.setSpeechRate(_preferredSpeed());
      await _flutterTts.setPitch(gender == VoiceGender.male ? 0.95 : 1.05);
    } catch (e) {
      AppLogger.error('Voice configuration error', e);
    }
  }

  Future<void> startListening({
    required Function(String text) onResult,
    Function(String? error)? onError,
  }) async {
    if (!await initialize()) {
      onError?.call('Voice service is unavailable');
      return;
    }

    try {
      final localeId = _selectedLocaleId ?? await _preferredLocale();
      final available = await _speechToText.locales();
      final localeExists = available.any(
        (locale) => locale.localeId == localeId,
      );
      final systemLocale = await _speechToText.systemLocale();
      final useLocale = localeExists
          ? localeId
          : (systemLocale?.localeId ?? localeId);

      _isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _isListening = false;
            onResult(result.recognizedWords.trim());
          }
        },
        localeId: useLocale,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: false,
      );
    } catch (e) {
      _isListening = false;
      onError?.call(e.toString());
      AppLogger.error('Start listening error', e);
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speechToText.stop();
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    if (!await initialize()) return;

    try {
      await configureVoice();
      _isSpeaking = true;
      await _flutterTts.speak(text);
      _isSpeaking = false;
    } catch (e) {
      _isSpeaking = false;
      AppLogger.error('TTS error', e);
    }
  }

  Future<void> stopSpeaking() async {
    _isSpeaking = false;
    await _flutterTts.stop();
  }

  Future<String> _preferredLocale() async {
    final locale = _local.getString(AppConstants.prefLocale);
    if (locale != null && locale.isNotEmpty) {
      return locale.replaceFirst('_', '-');
    }
    return 'fa-IR';
  }

  double _preferredSpeed() {
    final speed = _local.getDouble(AppConstants.prefVoiceSpeed) ?? 0.5;
    return speed.clamp(0.1, 1.0);
  }

  Future<VoiceGender> preferredGender() async {
    final gender = _local.getString(AppConstants.prefVoiceGender);
    return gender == 'male' ? VoiceGender.male : VoiceGender.female;
  }

  Future<void> dispose() async {
    await _speechToText.stop();
    await _flutterTts.stop();
  }
}
