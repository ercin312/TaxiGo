# TaxiGo — iOS App Store + Sign In with Apple

## Bundle ID (güncel)

| Platform | ID |
|----------|-----|
| **iOS (App Store)** | `com.erhancinar.taxigo` |
| Android | `com.taxigo.app` |
| Firebase iOS App ID | `1:728811081033:ios:a9bbd3a01c41ee05bade98` |
| Apple Team | `2J6MSH6HG8` |

> Eski `com.taxigo.app` Apple Developer’da alınmıştı; iOS için `com.erhancinar.taxigo` kullanılıyor.

## App Store Connect — zorunlu linkler

Backend canlı URL’nizi `APP_URL` olarak ayarlayın (ör. `https://api.taxigo.app`). Sayfalar:

| App Store alanı | Link (örnek) |
|-----------------|--------------|
| **Privacy Policy URL** (zorunlu) | `https://SENIN-DOMAIN/privacy` |
| **Support URL** (zorunlu) | `https://SENIN-DOMAIN/support` |
| Marketing URL (opsiyonel) | `https://SENIN-DOMAIN/` veya web sitesi |
| Terms of Use (opsiyonel / EULA) | `https://SENIN-DOMAIN/terms` |
| Account Deletion (Apple/Google ister) | `https://SENIN-DOMAIN/delete-account` |

Yerel test:

- http://127.0.0.1:8000/privacy  
- http://127.0.0.1:8000/terms  
- http://127.0.0.1:8000/support  
- http://127.0.0.1:8000/delete-account  

`.env` örneği:

```
APP_URL=https://api.taxigo.app
TAXIGO_SUPPORT_EMAIL=destek@taxigo.app
```

Destek e-postası sayfalarda görünür; gerçek bir gelen kutusu kullanın.

### App Privacy (App Store Connect anketi — kısa rehber)

| Veri | Toplanıyor mu? | Amaç |
|------|----------------|------|
| Konum | Evet | Uygulama işlevselliği (yakın taksi / yolculuk) |
| İletişim bilgisi (ad, telefon, e-posta) | Evet | Hesap |
| Kimlik belgeleri (sürücü) | Evet | Kimlik doğrulama / KYC |
| Kullanım verileri | Evet (sınırlı) | Analitik / hata |
| Ödeme bilgisi | Kart numarası bizde değil; işlem geçmişi olabilir | Finans |

“Tracking” (ATT) kullanmıyorsanız: **No, we do not track users**.

## Mac’te derleme / yükleme

```bash
cd apps/passenger
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
```

IPA → Transporter veya Xcode Organizer → App Store Connect.

Xcode (`ios/Runner.xcworkspace`):

1. Signing → Team: Erhan Çınar (`2J6MSH6HG8`)
2. Bundle ID: `com.erhancinar.taxigo`
3. Capabilities: Sign in with Apple, Push Notifications

## Apple Developer

- App ID: `com.erhancinar.taxigo` — Sign In with Apple + Push
- App Store Connect app: aynı Bundle ID

## Firebase

- Google / Apple providers açık
- iOS: `GoogleService-Info.plist` → `CLIENT_ID` + `REVERSED_CLIENT_ID`
- Android: SHA-1 + `google-services.json` (`oauth_client` dolu)
