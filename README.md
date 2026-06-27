# SEFRO Self Chat

AI Persian Secretary built with Flutter.

SEFRO Self Chat is a Persian-first productivity assistant that combines chat, voice input/output, calendar planning, task tracking, habits, notes, reminders, and configurable daily briefings in one RTL experience.

## Highlights

- Persian RTL dashboard and navigation
- Voice assistant with speech-to-text and text-to-speech
- Daily briefing and review flow
- Calendar-driven task creation and editing
- Habits, notes, reminders, and analytics screens
- Authentication flows for email, OTP, Google, and Apple
- Persistent settings for voice, locale, and security preferences
- Web and mobile Flutter support

## Tech Stack

- Flutter
- Riverpod
- GoRouter
- SharedPreferences
- Hive
- `speech_to_text`
- `flutter_tts`
- `table_calendar`
- `flutter_secure_storage`
- Supabase integration layer

## Core Features

### Dashboard
- Shows daily overview cards, task progress, and recommendations
- Surfaces weekly focus and briefing content in Persian

### Voice Helper
- Listens to Persian speech input
- Speaks AI responses aloud
- Supports voice speed and gender preferences in settings

### Calendar and Tasks
- Creates tasks from selected dates
- Edits existing tasks from the calendar flow
- Keeps the daily schedule visible inside the app shell

### Settings
- Enables or disables voice assistant features
- Changes voice gender and speaking speed
- Controls briefing preferences and locale
- Supports biometric lock and PIN preferences

### Auth
- Login, register, and OTP screens
- Google and Apple login entry points
- Local session persistence for development and offline usage

## Project Structure

- `lib/core` - constants, routing, theme, utilities, and dependency injection
- `lib/data` - local/remote datasources and repository implementations
- `lib/domain` - entities, repository contracts, and use cases
- `lib/presentation` - screens, providers, and widgets
- `lib/services` - AI, voice, notification, and calendar services
- `web` - Flutter web shell and manifest
- `tools` - helper scripts, including cache diagnostics

## Getting Started

### Prerequisites

- Flutter 3.10+ / Dart 3.10+
- Chrome or another supported Flutter target

### Install

```powershell
flutter pub get
```

If your environment cannot reach pub.dev, use the configured mirror:

```powershell
$env:PUB_HOSTED_URL='https://pub.flutter-io.cn'
flutter pub get
```

### Run

```powershell
flutter run -d chrome
```

### Build Web

```powershell
flutter build web --release
```

## Environment Variables

The app reads these optional values from the environment:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `GEMINI_API_KEY`

Some flows work locally without external services, but the placeholders are ready for backend integration.

## Troubleshooting

- If the web app looks stale on `localhost:8000`, clear site data for that origin and hard refresh.
- If `flutter pub get` fails on a restricted network, set `PUB_HOSTED_URL=https://pub.flutter-io.cn`.
- If icons or fonts do not load on web, rebuild the app after clearing the browser cache and service worker data.

## Status

This repository is actively being shaped into a Persian AI secretary product. The current codebase includes the main UI, voice helper, settings, calendar/task flow, and local persistence layers.

