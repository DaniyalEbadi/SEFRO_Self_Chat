import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

class AiResponse {
  final String content;
  final Map<String, dynamic>? extractedEntities;
  final String? intent;
  final String? error;

  AiResponse({required this.content, this.extractedEntities, this.intent, this.error});
}

class AiDataSource {
  final Dio _dio;

  AiDataSource(this._dio);

  Future<AiResponse> chatWithOpenAI(List<Map<String, String>> messages) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.openAiChat,
        options: Options(headers: {
          'Authorization': 'Bearer ${AppConstants.openAiApiKey}',
        }),
        data: {
          'model': 'gpt-4',
          'messages': messages,
          'temperature': 0.7,
        },
      );
      final content = response.data['choices'][0]['message']['content'] as String;
      return _parseAiResponse(content);
    } catch (e) {
      AppLogger.error('OpenAI API error', e);
      return AiResponse(content: '', error: e.toString());
    }
  }

  Future<AiResponse> chatWithClaude(List<Map<String, String>> messages) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.anthropicMessages,
        options: Options(headers: {
          'x-api-key': AppConstants.anthropicApiKey,
          'anthropic-version': '2023-06-01',
        }),
        data: {
          'model': 'claude-3-sonnet-20241022',
          'max_tokens': 1024,
          'messages': messages,
        },
      );
      final content = response.data['content'][0]['text'] as String;
      return _parseAiResponse(content);
    } catch (e) {
      AppLogger.error('Claude API error', e);
      return AiResponse(content: '', error: e.toString());
    }
  }

  Future<AiResponse> chatWithGemini(List<Map<String, String>> messages) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.geminiChat}?key=${AppConstants.geminiApiKey}',
        data: {
          'contents': messages.map((m) => {
            'role': m['role'],
            'parts': [{'text': m['content']}],
          }).toList(),
        },
      );
      final content = response.data['candidates'][0]['content']['parts'][0]['text'] as String;
      return _parseAiResponse(content);
    } catch (e) {
      AppLogger.error('Gemini API error', e);
      return AiResponse(content: '', error: e.toString());
    }
  }

  AiResponse _parseAiResponse(String rawContent) {
    String content = rawContent;
    Map<String, dynamic>? entities;
    String? intent;

    try {
      final jsonMatch = RegExp(r'\{[^{}]*\}').firstMatch(rawContent);
      if (jsonMatch != null) {
        entities = jsonDecode(jsonMatch.group(0)!);
        content = rawContent.replaceFirst(jsonMatch.group(0)!, '').trim();
      }
    } catch (_) {}

    final intentMatch = RegExp(r'\[(TASK|MEETING|REMINDER|NOTE|QUERY|GREETING)\]').firstMatch(rawContent);
    if (intentMatch != null) {
      intent = intentMatch.group(1);
      content = content.replaceFirst(intentMatch.group(0)!, '').trim();
    }

    return AiResponse(content: content, extractedEntities: entities, intent: intent);
  }
}
