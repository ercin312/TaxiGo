# Social login (Google / Apple)

See also: [APP_STORE_IOS.md](./APP_STORE_IOS.md)

TaxiGo: **Firebase Auth** → Laravel `POST /api/v1/auth/firebase-verify`.

## Enable providers

1. Firebase project `taxigo-e7b4b`
2. Authentication → Sign-in method → **Google** + **Apple**
3. Android package (Play): `com.alanyaproje.taxigo` — SHA-1 must be registered or you get `ApiException: 10`
4. Re-download configs after SHA changes:
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist` (must include `CLIENT_ID` / `REVERSED_CLIENT_ID`)

## Android package + SHA-1

| Package | Use |
|---------|-----|
| `com.alanyaproje.taxigo` | Current Play / debug `applicationId` |
| `com.taxigo.app` | Legacy (kept in Firebase, not used by app) |

Registered on `com.alanyaproje.taxigo`:

- Debug SHA-1: `D1:5C:9A:02:FF:DD:D7:A4:30:98:6B:3F:95:EA:4F:12:FE:A6:E9:17`
- Upload SHA-1: `EF:0B:A7:DA:FD:44:A4:0E:2B:11:AE:86:01:F4:51:46:60:CA:65:C1`

Web / server client ID (for `GoogleSignIn.serverClientId` / ID token):

```
728811081033-qg42felr8cvkf5nqa37rim4p1b5dggmf.apps.googleusercontent.com
```

```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

## Optional dart-defines

```bash
flutter run \
  --dart-define=TAXIGO_GOOGLE_IOS_CLIENT_ID=xxxx.apps.googleusercontent.com \
  --dart-define=TAXIGO_GOOGLE_SERVER_CLIENT_ID=yyyy.apps.googleusercontent.com
```

## App flow

Google/Apple → Firebase ID token → API (or local session if API down)

## Troubleshooting

`ApiException: 10` (DEVELOPER_ERROR): package name / SHA-1 mismatch. Add the signing key SHA-1 to the Firebase Android app that matches `applicationId`, wait a few minutes, rebuild the app.
