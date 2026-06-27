class AppConstants {
  AppConstants._();

  static const String appName = 'منشی هوشمند فارسی';
  static const String appNameEn = 'AI Persian Secretary';
  static const String appVersion = '1.0.0';

  // API Keys placeholder
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  // AI Provider configs
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String anthropicApiKey = String.fromEnvironment(
    'ANTHROPIC_API_KEY',
  );
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Pagination
  static const int pageSize = 20;

  // Timeouts
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;

  // Shared Preferences Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefLocale = 'locale';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefUserId = 'user_id';
  static const String prefAuthToken = 'auth_token';
  static const String prefVoiceGender = 'voice_gender';
  static const String prefVoiceSpeed = 'voice_speed';
  static const String prefVoiceAssistantEnabled = 'voice_assistant_enabled';
  static const String prefMorningBriefing = 'morning_briefing';
  static const String prefEveningReview = 'evening_review';
  static const String prefPinEnabled = 'pin_enabled';
  static const String prefPinCode = 'pin_code';
  static const String prefBiometricEnabled = 'biometric_enabled';
  static const String prefLastSync = 'last_sync';

  // Feature flags
  static const bool enableVoiceAssistant = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
}
