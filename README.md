# Futivo Interface

Flutter mobile and web interface for Futivo, a football news and fantasy
platform built around the World Cup 2026 experience.

## Highlights

- Football news feed with Telegram/backend integration.
- World Cup style matches, groups and standings screens.
- Fantasy hub with my team, private groups and player market.
- Player statistics and profile experience.
- French, Arabic and English localization support.
- Responsive Flutter web build support.

## Tech stack

- Flutter / Dart
- Supabase authentication integration
- ASP.NET Core backend API integration
- Provider state management
- Custom Futivo visual theme and assets

## Related repository

Backend API:

```text
https://github.com/medmess/futivo-backend-
```

## Local setup

Create a local `.env` file from `.env.example` before running the app. Real
secrets are intentionally not committed.

```powershell
cp .env.example .env
flutter pub get
flutter run
```

For Android:

```powershell
flutter build apk --debug
```

For web:

```powershell
flutter build web
```

## Notes

This repository contains only the Flutter interface. Backend logic, database
algorithms and API endpoints are kept in the Futivo backend repository.
