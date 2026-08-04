# TaxiGo Admin (Windows — native)

Flutter masaüstü uygulaması. WebView yok; native UI + Laravel Admin API.

## Çalıştırma

```powershell
# Terminal 1 — API
cd C:\Users\excalibur\Desktop\TaxiGo\backend
php artisan serve

# Terminal 2 — panel
cd C:\Users\excalibur\Desktop\TaxiGo\apps\admin
flutter pub get
flutter run -d windows
```

Giriş: `admin@taxigo.app` / `password`  
API: `http://127.0.0.1:8000/api/v1`

## Release

```powershell
cd C:\Users\excalibur\Desktop\TaxiGo\apps\admin
flutter build windows --release
```

Exe: `build\windows\x64\runner\Release\taxigo_admin.exe`

## Ekranlar

- Özet (istatistikler)
- Sürücüler (onay / red)
- Kullanıcılar (aktif / pasif)
- Yolculuklar (aktif / geçmiş)
