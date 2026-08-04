# Social login (Google / Apple)

See also: [APP_STORE_IOS.md](./APP_STORE_IOS.md)

TaxiGo: **Firebase Auth** → Laravel `POST /api/v1/auth/firebase-verify`.

## Enable providers

1. Firebase project `taxigo-e7b4b`
2. Authentication → Sign-in method → **Google** + **Apple**
3. Re-download configs:
   - iOS: `GoogleService-Info.plist` → must include `CLIENT_ID` / `REVERSED_CLIENT_ID`
   - Android: `google-services.json` → must include `oauth_client` (add SHA-1 first)
4. iOS only: `powershell -File tools/sync_ios_google_signin.ps1`

## Optional dart-defines

```bash
flutter run \
  --dart-define=TAXIGO_GOOGLE_IOS_CLIENT_ID=xxxx.apps.googleusercontent.com \
  --dart-define=TAXIGO_GOOGLE_SERVER_CLIENT_ID=yyyy.apps.googleusercontent.com
```

## SHA-1 (Android)

Debug SHA-1 (already registered on Firebase Android app):

```
D1:5C:9A:02:FF:DD:D7:A4:30:98:6B:3F:95:EA:4F:12:FE:A6:E9:17
```

For Play release, also add your **upload/release** keystore SHA-1 in Firebase Project settings.

```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

## App flow

Google/Apple → Firebase ID token → API (or local session if API down)
