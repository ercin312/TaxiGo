# TaxiGo

Full-stack taxi platform: passenger app, driver app, Laravel API + admin, Firebase realtime.

## Structure

```
apps/passenger/        # Tek TaxiGo mobil uygulaması (yolcu + sürücü)
apps/admin/            # Windows masaüstü admin paneli (Laravel UI kabuğu)
packages/taxigo_core/  # Paylaşılan Dart paketi
backend/               # Laravel 13 API + Inertia/Vue admin
firebase/              # RTDB güvenlik kuralları
```

> **Not:** `apps/driver/` artık kullanılmıyor. Sürücü özellikleri `apps/passenger/` içinde.

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
> Bundle ID (iOS+Android): `com.taxigo.app`

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
(WebView yok; native masaüstü UI + `/api/v1/admin/*`)

### Flutter apps

```bash
cd packages/taxigo_core && flutter pub get
cd apps/passenger && flutter pub get && flutter run
```

## APK build

### Local (Windows / macOS / Linux)

```bash
cd packages/taxigo_core && flutter pub get && flutter gen-l10n
cd ../../apps/passenger
flutter pub get
flutter build apk --release --dart-define=TAXIGO_API_BASE_URL=http://YOUR_IP:8000/api/v1
```

APK output: `apps/passenger/build/app/outputs/flutter-apk/app-release.apk`

### GitLab CI

Push to GitLab — pipeline runs `build:apk` and saves the APK as artifact (14 days).

Set variable `TAXIGO_API_BASE_URL` in **Settings → CI/CD → Variables**.

### GitHub Actions

Workflow: `.github/workflows/build-apk.yml` — manual or push to `main`.

Download APK from **Actions → Artifacts**.

### Configure before running on device

1. Create Firebase project and add `google-services.json` to the Android app
2. Run `flutterfire configure` or add `firebase_options.dart`
3. Set Google Maps API key in `AndroidManifest.xml`
4. Point API: `--dart-define=TAXIGO_API_BASE_URL=http://10.0.2.2:8000/api/v1` (Android emulator)

### Environment variables (backend `.env`)

```
FIREBASE_API_KEY=your_firebase_web_api_key
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
FIREBASE_DATABASE_SECRET=optional_for_server_writes
```

## Authentication (OTP)

Giriş **SMS ile değil**, backend üzerinden **uygulama içi OTP** ile yapılır:

1. Kullanıcı telefon numarasını girer
2. `POST /api/v1/auth/request-otp` — 6 haneli kod üretilir
3. Kod doğrulama ekranında uygulama içinde gösterilir (`.env`: `TAXIGO_OTP_DELIVER_IN_APP=true`)
4. `POST /api/v1/auth/verify-otp` — Sanctum token döner

## API overview

- `POST /api/v1/auth/request-otp` — Generate in-app OTP
- `POST /api/v1/auth/verify-otp` — Verify OTP and login
- `POST /api/v1/rides/eta` — Fare estimate
- `POST /api/v1/rides` — Create ride
- `POST /api/v1/driver/rides/{id}/accept` — Driver accepts
- Full list: `php artisan route:list --path=api`

## Localization

Supported: **TR, EN, RU, Karabağca (xh), Arabic (ar)** with RTL.

Add a language:

1. Create `packages/taxigo_core/lib/l10n/intl_XX.arb`
2. Register in `supported_locales.dart`
3. Run `flutter gen-l10n` in `taxigo_core`

## Ride status flow

`pending` → `driver_assigned` → `driver_arriving` → `driver_arrived` → `passenger_on_board` → `in_progress` → `completed`

Cancellations: `cancelled_by_passenger`, `cancelled_by_driver`, `expired`
