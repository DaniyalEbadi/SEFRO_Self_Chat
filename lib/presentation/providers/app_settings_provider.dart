import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../services/voice/voice_service.dart';

class AppSettingsState {
  final bool voiceAssistantEnabled;
  final bool morningBriefingEnabled;
  final bool eveningReviewEnabled;
  final bool pinLockEnabled;
  final bool biometricLockEnabled;
  final String locale;
  final VoiceGender voiceGender;
  final double voiceSpeed;

  const AppSettingsState({
    this.voiceAssistantEnabled = true,
    this.morningBriefingEnabled = true,
    this.eveningReviewEnabled = true,
    this.pinLockEnabled = false,
    this.biometricLockEnabled = false,
    this.locale = 'fa_IR',
    this.voiceGender = VoiceGender.female,
    this.voiceSpeed = 0.5,
  });

  AppSettingsState copyWith({
    bool? voiceAssistantEnabled,
    bool? morningBriefingEnabled,
    bool? eveningReviewEnabled,
    bool? pinLockEnabled,
    bool? biometricLockEnabled,
    String? locale,
    VoiceGender? voiceGender,
    double? voiceSpeed,
  }) {
    return AppSettingsState(
      voiceAssistantEnabled:
          voiceAssistantEnabled ?? this.voiceAssistantEnabled,
      morningBriefingEnabled:
          morningBriefingEnabled ?? this.morningBriefingEnabled,
      eveningReviewEnabled: eveningReviewEnabled ?? this.eveningReviewEnabled,
      pinLockEnabled: pinLockEnabled ?? this.pinLockEnabled,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      locale: locale ?? this.locale,
      voiceGender: voiceGender ?? this.voiceGender,
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
    );
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
      return AppSettingsNotifier();
    });

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  final LocalDataSource _local = ServiceLocator().get<LocalDataSource>();

  AppSettingsNotifier() : super(const AppSettingsState()) {
    _load();
  }

  void _load() {
    state = state.copyWith(
      voiceAssistantEnabled:
          _local.getBool(AppConstants.prefVoiceAssistantEnabled) ?? true,
      morningBriefingEnabled:
          _local.getBool(AppConstants.prefMorningBriefing) ?? true,
      eveningReviewEnabled:
          _local.getBool(AppConstants.prefEveningReview) ?? true,
      pinLockEnabled: _local.getBool(AppConstants.prefPinEnabled) ?? false,
      biometricLockEnabled:
          _local.getBool(AppConstants.prefBiometricEnabled) ?? false,
      locale: _local.getString(AppConstants.prefLocale) ?? 'fa_IR',
      voiceGender:
          (_local.getString(AppConstants.prefVoiceGender) ?? 'female') == 'male'
          ? VoiceGender.male
          : VoiceGender.female,
      voiceSpeed: _local.getDouble(AppConstants.prefVoiceSpeed) ?? 0.5,
    );
  }

  Future<void> setVoiceAssistantEnabled(bool value) async {
    state = state.copyWith(voiceAssistantEnabled: value);
    await _local.setBool(AppConstants.prefVoiceAssistantEnabled, value);
  }

  Future<void> setMorningBriefingEnabled(bool value) async {
    state = state.copyWith(morningBriefingEnabled: value);
    await _local.setBool(AppConstants.prefMorningBriefing, value);
  }

  Future<void> setEveningReviewEnabled(bool value) async {
    state = state.copyWith(eveningReviewEnabled: value);
    await _local.setBool(AppConstants.prefEveningReview, value);
  }

  Future<void> setPinLockEnabled(bool value) async {
    state = state.copyWith(pinLockEnabled: value);
    await _local.setBool(AppConstants.prefPinEnabled, value);
  }

  Future<void> setBiometricLockEnabled(bool value) async {
    state = state.copyWith(biometricLockEnabled: value);
    await _local.setBool(AppConstants.prefBiometricEnabled, value);
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await _local.setString(AppConstants.prefLocale, locale);
  }

  Future<void> setVoiceGender(VoiceGender gender) async {
    state = state.copyWith(voiceGender: gender);
    await _local.setString(AppConstants.prefVoiceGender, gender.name);
  }

  Future<void> setVoiceSpeed(double speed) async {
    state = state.copyWith(voiceSpeed: speed);
    await _local.setDouble(AppConstants.prefVoiceSpeed, speed);
  }
}

final voiceGenderLabelProvider = Provider<String>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.voiceGender == VoiceGender.male ? 'مرد' : 'زن';
});
