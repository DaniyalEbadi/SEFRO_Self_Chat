import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/event_entity.dart';

class CalendarService {
  final Dio _dio;

  CalendarService(this._dio);

  Future<List<EventEntity>> getGoogleCalendarEvents(String accessToken, {DateTime? start, DateTime? end}) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.googleCalendar}/calendars/primary/events',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
        queryParameters: {
          if (start != null) 'timeMin': start.toIso8601String(),
          if (end != null) 'timeMax': end.toIso8601String(),
          'singleEvents': true,
          'orderBy': 'startTime',
        },
      );
      final items = response.data['items'] as List<dynamic>? ?? [];
      return items.map((item) => _googleEventToEntity(item)).toList();
    } catch (e) {
      AppLogger.error('Google Calendar sync error', e);
      return [];
    }
  }

  Future<bool> createGoogleEvent(String accessToken, EventEntity event) async {
    try {
      await _dio.post(
        '${ApiEndpoints.googleCalendar}/calendars/primary/events',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
        data: _entityToGoogleEvent(event),
      );
      return true;
    } catch (e) {
      AppLogger.error('Create Google Calendar event error', e);
      return false;
    }
  }

  Future<bool> deleteGoogleEvent(String accessToken, String eventId) async {
    try {
      await _dio.delete(
        '${ApiEndpoints.googleCalendar}/calendars/primary/events/$eventId',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
      );
      return true;
    } catch (e) {
      AppLogger.error('Delete Google Calendar event error', e);
      return false;
    }
  }

  EventEntity _googleEventToEntity(dynamic json) {
    return EventEntity(
      id: json['id'] as String? ?? '',
      userId: '',
      title: json['summary'] as String? ?? 'بدون عنوان',
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: DateTime.parse(json['start']?['dateTime'] ?? json['start']?['date'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['end']?['dateTime'] ?? json['end']?['date'] ?? DateTime.now().toIso8601String()),
      isAllDay: json['start']?['date'] != null,
      calendarSource: 'google',
      externalEventId: json['id'] as String?,
      attendeeIds: (json['attendees'] as List<dynamic>?)?.map((a) => a['email'] as String).toList(),
    );
  }

  Map<String, dynamic> _entityToGoogleEvent(EventEntity event) {
    return {
      'summary': event.title,
      'description': event.description,
      'location': event.location,
      'start': {
        'dateTime': event.startTime.toIso8601String(),
        'timeZone': 'Asia/Tehran',
      },
      'end': {
        'dateTime': event.endTime.toIso8601String(),
        'timeZone': 'Asia/Tehran',
      },
      if (event.attendeeIds != null)
        'attendees': event.attendeeIds!.map((email) => {'email': email}).toList(),
    };
  }

  Future<bool> syncWithOutlook(String accessToken) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.outlookCalendar,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Outlook sync error', e);
      return false;
    }
  }

  Future<bool> syncWithAppleCalendar(String token) async {
    // Apple Calendar sync requires EKEventStore on iOS
    AppLogger.info('Apple Calendar sync - platform specific');
    return false;
  }
}
