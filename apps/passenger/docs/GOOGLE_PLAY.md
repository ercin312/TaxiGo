# TaxiGo — Google Play (Proje Alanya)

## Hesap
- Play Console: **Proje Alanya** (`mixvideo806@gmail.com`)
- App: **TaxiGo** (Taslak)
- Package: `com.alanyaproje.taxigo`
  - Not: `com.taxigo.app` Play’de zaten alınmıştı; bu yüzden yeni paket kullanıldı.
- Console URL: https://play.google.com/console/u/1/developers/8534262622778006068/app/4975472021712314783/app-dashboard

## Uygulama dosyası (AAB)
- `C:\Users\excalibur\Desktop\google play yüklemeleri\taxi\play-assets\TaxiGo-1.0.0-15.aab`
- Version: `1.0.0` (versionCode 15)
- Upload keystore SHA-1: `EF:0B:A7:DA:FD:44:A4:0E:2B:11:AE:86:01:F4:51:46:60:CA:65:C1`
- Keystore (gizli, commit etme): `apps/passenger/android/keystore/upload-keystore.jks`
- `key.properties` gitignore’da

## Mağaza metinleri (en-US varsayılan)
**Kısa açıklama:**
Reliable taxi in Alanya. Book instantly, track your driver, ride safely.

**Tam açıklama:**
TaxiGo makes booking a taxi simple and safe.

• Request a ride quickly from the map
• Track your driver in real time
• Sign in with phone or Google
• Wallet and ride history
• Multi-language support

Location permission is used to show nearby cars and manage your trip.

Support: admin@alanyaproje.com
Privacy: https://alanyaproje.com/taxigo/privacy.html

## Yasal linkler
- Privacy: https://alanyaproje.com/taxigo/privacy.html
- Support: https://alanyaproje.com/taxigo/support.html
- Contact: admin@alanyaproje.com

## Görseller (yükle)
Klasör: `C:\Users\excalibur\Desktop\google play yüklemeleri\taxi\play-assets\`
- `icon-512.png` → Uygulama simgesi
- `feature-graphic-1024x500.png` → Özellik grafiği
- `phone\1.jpg` … `8.jpg` → Telefon (2–8 adet)
- `tablet-7\01.jpg` … `08.jpg` → 7" tablet
- `tablet-10\01.jpg` … `08.jpg` → 10" tablet

## Sonraki zorunlu adımlar (Play Console)
1. Mağaza girişi → görselleri yükle → Kaydet
2. Mağaza ayarları → kategori (Maps & Navigation / Travel), e-posta, gizlilik URL
3. Uygulama içeriği → Veri güvenliği, Reklam kimliği (Hayır), Hedef kitle, İçerik derecelendirmesi
4. Dahili test / Kapalı test → AAB yükle
5. Üretim erişimi (yeni hesap politikası gereği kapalı test sonrası)

## Firebase
- Yeni Android app: `com.alanyaproje.taxigo` (TaxiGo Play)
- `google-services.json` güncellendi
- Firebase Console’da bu app’e upload SHA-1 ekle (Google Sign-In için)
