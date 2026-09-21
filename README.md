# TaxiGo

Tek mobil uygulama + Laravel API + admin + Firebase realtime.

## Structure

```
apps/passenger/        # TaxiGo mobil uygulaması (yolcu + sürücü tek app)
apps/admin/            # Windows masaüstü admin paneli
packages/taxigo_core/  # Paylaşılan Dart paketi
backend/               # Laravel API + Inertia/Vue admin
firebase/              # RTDB güvenlik kuralları
deploy/                # Shared-hosting API paketi
```

Paket adı: `taxigo` (`apps/passenger/pubspec.yaml`). Bundle ID: `com.taxigo.app`.

Sürücü modu aynı uygulamada: girişte **Driver** rolü veya **Account → Switch to driver** / KYC sonrası `/driver-home`.

> Ayrı bir `apps/driver` uygulaması yok; kaldırıldı.

## Prerequisites

- Flutter 3.x
- PHP 8.2+ and Composer (`php composer.phar` in repo root)
- Node.js 18+ (admin panel)
- MySQL 8 or SQLite (default)
- Firebase project (Realtime Database, FCM, **Google + Apple Sign-In**)
- Google Maps API keys
- Windows admin: Visual Studio 2022 (Desktop C++) + Edge WebView2 Runtime
- **iOS App Store:** Mac + Xcode 15+, Apple Developer account — see `apps/passenger/docs/APP_STORE_IOS.md`

> Social login: `apps/passenger/docs/SOCIAL_LOGIN.md`

## Quick start

### Backend

```bash
cd backend
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```

In another terminal:

```bash
cd backend && npm run dev
```

**Admin panel (web):** http://localhost:8000/login  
**Credentials:** `admin@taxigo.app` / `password`

### Windows admin panel (native Flutter)

Backend çalışırken:

```bash
cd apps/admin
flutter pub get
flutter run -d windows
```

Release exe:

```bash
cd apps/admin
flutter build windows --release
```

Çıktı: `apps/admin/build/windows/x64/runner/Release/taxigo_admin.exe`

Giriş: `admin@taxigo.app` / `password` — API: `http://127.0.0.1:8000/api/v1`

### TaxiGo mobile app

```bash
cd packages/taxigo_core && flutter pub get
cd ../../apps/passenger && flutter pub get && flutter run
```

## APK build

### Local

```bash
cd packages/taxigo_core && flutter pub get && flutter gen-l10n
cd ../../apps/passenger
flutter pub get
flutter build apk --release --dart-define=TAXIGO_API_BASE_URL=http://YOUR_IP:8000/api/v1
```

APK: `apps/passenger/build/app/outputs/flutter-apk/app-release.apk`

### GitLab CI / GitHub Actions

- GitLab: `build:apk` artifact (14 days). Variable: `TAXIGO_API_BASE_URL`
- GitHub: `.github/workflows/build-apk.yml` and `ios-testflight.yml` — only `apps/passenger`

### Configure before running on device

1. Firebase: `google-services.json` / `GoogleService-Info.plist` / `firebase_options.dart`
2. Google Maps API key in `AndroidManifest.xml` / iOS
3. API: `--dart-define=TAXIGO_API_BASE_URL=http://10.0.2.2:8000/api/v1` (Android emulator)

### Environment variables (backend `.env`)

```
FIREBASE_API_KEY=your_firebase_web_api_key
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
FIREBASE_DATABASE_SECRET=optional_for_server_writes
```

## Authentication

Login supports review credentials + social (platform-dependent). OTP module may be enabled server-side.

## API overview

- `POST /api/v1/auth/request-otp` — Generate in-app OTP
- `POST /api/v1/auth/verify-otp` — Verify OTP and login
- `POST /api/v1/rides/eta` — Fare estimate
- `POST /api/v1/rides` — Create ride
- `POST /api/v1/driver/rides/{id}/accept` — Driver accepts (same app, driver mode)
- Full list: `php artisan route:list --path=api`

## Localization

Supported: **TR, EN, Crnogorski (cnr), RU, Arabic (ar)** with RTL.

## Ride status flow

`pending` → `driver_assigned` → `driver_arriving` → `driver_arrived` → `passenger_on_board` → `in_progress` → `completed`

Cancellations: `cancelled_by_passenger`, `cancelled_by_driver`, `expired`
