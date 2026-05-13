# FindMyPart — CLAUDE.md

## Project Overview
Full-stack automotive marketplace mobile app — university senior project.
- **Frontend**: Flutter (Clean Architecture, Riverpod, go_router) in `frontend/`
- **Backend**: Laravel 11 REST API in `backend/`
- **DB**: MySQL

## Flutter Architecture
Feature-based structure under `lib/features/`. Each feature contains:
- `data/models/` — plain Dart models with `fromJson`
- `data/repositories/` — API calls via `ApiClient`
- `providers/` — Riverpod `FutureProvider` / `AsyncNotifierProvider`
- `presentation/screens/` — full-page widgets (`ConsumerWidget`)
- `presentation/widgets/` — reusable feature-specific widgets

Core infrastructure:
- `lib/core/network/api_client.dart` — Dio client with auth + error interceptors
- `lib/core/router/app_router.dart` — go_router with auth guard
- `lib/core/theme/` — Material 3 light/dark theme
- `lib/shared/widgets/` — app-wide reusable widgets

## Laravel Architecture
- Controllers at `app/Http/Controllers/API/V1/`
- All responses follow `{ success, message, data, pagination }` format
- API versioned under `/api/v1/`
- Sanctum token auth — attach `Authorization: Bearer <token>` header

## Key Constants
- API base URL: `lib/core/constants/app_constants.dart` (`AppConstants.baseUrl`)
- For Android emulator: `http://10.0.2.2:8000/api/v1`
- For iOS simulator: `http://localhost:8000/api/v1`

## Common Commands
```bash
# Flutter
flutter pub get
flutter run
flutter build apk --release

# Laravel
php artisan serve
php artisan migrate:fresh --seed
php artisan route:list
```

## Demo Accounts
- customer@demo.com / password
- garage@demo.com / password
- yard@demo.com / password
