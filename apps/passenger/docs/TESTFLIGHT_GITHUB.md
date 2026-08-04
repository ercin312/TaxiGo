# TestFlight — GitHub Actions

Evet: **GitHub üzerinden TestFlight’a yükleme** pipeline’ı hazır.  
Windows’tan IPA çıkmaz; Actions **macOS runner** kullanır.

## Önkoşullar

1. Projeyi GitHub’a push edin (şu an klasörde `.git` yoksa önce `git init` + remote).
2. App Store Connect’te uygulama: Bundle ID `com.erhancinar.taxigo`.
3. **App Store Connect API Key** oluşturun.

### API Key oluşturma

1. [App Store Connect → Users and Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api)
2. **Generate API Key** → Access: **App Manager** veya **Admin**
3. `.p8` dosyasını indirin (bir kez gösterilir)
4. Not edin:
   - **Key ID**
   - **Issuer ID**

## GitHub Secrets

Repo → **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Değer |
|--------|--------|
| `APP_STORE_CONNECT_KEY_ID` | Key ID (ör. `AB12CD34EF`) |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID (UUID) |
| `APP_STORE_CONNECT_API_KEY` | `.p8` dosyasının **tüm metni** (`-----BEGIN PRIVATE KEY-----` …) |

Opsiyonel Variables:

| Variable | Örnek |
|----------|--------|
| `TAXIGO_API_BASE_URL` | `https://api.taxigo.app/api/v1` |

## Çalıştırma

1. GitHub → **Actions** → **iOS TestFlight**
2. **Run workflow**
3. Bittiğinde App Store Connect → TestFlight’ta build görünür (işleme 5–30 dk sürebilir)
4. Internal Testing grubuna ekleyip test edin

Workflow dosyası: `.github/workflows/ios-testflight.yml`

## İlk seferde sık hatalar

| Hata | Çözüm |
|------|--------|
| No signing certificate | Apple Developer’da Team `2J6MSH6HG8` için Certificates; Xcode automatic signing + API key yetkisi |
| Bundle ID mismatch | App Store Connect app = `com.erhancinar.taxigo` |
| Privacy Policy missing | App bilgilerine `/privacy` ve `/support` URL’lerini ekleyin |
| altool auth failed | Key ID / Issuer ID / p8 içeriğini kontrol edin |

## Not

- Her run `github.run_number` ile build number artırır.
- macOS Actions dakikaları ücretli olabilir (private repo / kota).
- Public repo’da ücretsiz kota sınırlıdır.
