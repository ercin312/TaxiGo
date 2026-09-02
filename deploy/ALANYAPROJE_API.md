# Deploy TaxiGo API → alanyaproje.com/taxigo

Hedef URL (uygulama bunu kullanır):

`https://alanyaproje.com/taxigo/v1/...`

Örnek: `POST https://alanyaproje.com/taxigo/v1/auth/firebase-verify`

## Sunucu klasör yapısı (LiteSpeed / cPanel)

```
public_html/
  taxigo/
    privacy.html          ← mevcut yasal sayfalar kalsın
    terms.html
    support.html
    ...
    api/                  ← Laravel buraya (veya alt domain)
      app/
      bootstrap/
      config/
      public/             ← document root DEĞİL; aşağıdaki index kullanılır
      ...
    v1 -> api/public      ← alternatif: symlink
```

### Önerilen basit yol

1. Laravel’i `public_html/taxigo/api/` altına yükleyin (`composer install --no-dev`).
2. `public_html/taxigo/api/public/.htaccess` içinde rewrite açık olsun.
3. `public_html/taxigo/v1` için cPanel’de **Alias** veya şu `.htaccess` (taxigo kökünde):

```apache
# public_html/taxigo/.htaccess
RewriteEngine On

# Keep existing legal HTML
RewriteRule ^(privacy|terms|support|delete-account|index|style).* - [L]

# API: /taxigo/v1/* → Laravel public
RewriteRule ^v1/(.*)$ api/public/index.php [L,QSA]
RewriteRule ^v1$ api/public/index.php [L,QSA]
```

4. `api/.env` örnek:

```
APP_URL=https://alanyaproje.com/taxigo
APP_ENV=production
APP_DEBUG=false
TAXIGO_FORCE_HTTPS=true
TAXIGO_DEMO_LOGIN=false
FIREBASE_PROJECT_ID=taxigo-e7b4b
FIREBASE_API_KEY=...
FIREBASE_CREDENTIALS=storage/app/firebase-service-account.json
```

5. `php artisan migrate --force` + `php artisan config:cache`

6. Doğrulama:

```bash
curl -X POST https://alanyaproje.com/taxigo/v1/auth/otp/request \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+905551112233","role":"passenger"}'
```

JSON dönmeli (HTML 404 değil).

## Not

Bu makineden FTP/cPanel erişimi yok; yasal HTML’i siz yüklemiştiniz.
API’yi yüklemek için FTP bilgisi veya cPanel File Manager ile `backend/` paketini atmanız gerekir.
