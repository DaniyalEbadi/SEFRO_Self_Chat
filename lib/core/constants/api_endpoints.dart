class ApiEndpoints {
  ApiEndpoints._();

  // Supabase
  static const String supabaseUsers = 'users';
  static const String supabaseTasks = 'tasks';
  static const String supabaseReminders = 'reminders';
  static const String supabaseEvents = 'events';
  static const String supabaseHabits = 'habits';
  static const String supabaseNotes = 'notes';
  static const String supabaseAiMemory = 'ai_memory';
  static const String supabaseNotifications = 'notifications';
  static const String supabaseVoicePreferences = 'voice_preferences';
  static const String supabaseChatHistory = 'chat_history';

  // AI Providers
  static const String openAiChat = 'https://api.openai.com/v1/chat/completions';
  static const String anthropicMessages = 'https://api.anthropic.com/v1/messages';
  static const String geminiChat = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  // Calendar APIs
  static const String googleCalendar = 'https://www.googleapis.com/calendar/v3';
  static const String outlookCalendar = 'https://graph.microsoft.com/v1.0/me/events';
}
