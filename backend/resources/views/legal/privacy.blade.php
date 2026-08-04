@extends('legal.layout')

@section('title', 'Gizlilik Politikası')
@section('heading', 'Gizlilik Politikası')

@section('content')
<p class="meta">Son güncelleme: {{ $updatedAt }}</p>

<p>
    Bu Gizlilik Politikası, {{ $appName }} mobil uygulamasını (“Uygulama”) kullandığınızda
    hangi verileri topladığımızı, nasıl kullandığımızı ve haklarınızı açıklar.
    Uygulamayı kullanarak bu politikayı kabul etmiş sayılırsınız.
</p>

<h2>1. Topladığımız veriler</h2>
<ul>
    <li><strong>Hesap bilgileri:</strong> ad, telefon, e-posta (giriş / profil).</li>
    <li><strong>Konum:</strong> yakındaki taksileri göstermek, yolculuk eşleştirmek ve takip için (izin verdiğinizde).</li>
    <li><strong>Yolculuk verileri:</strong> alış/varış, ücret, durum, tarih.</li>
    <li><strong>Ödeme / cüzdan:</strong> işlem kayıtları (kart verileri ödeme sağlayıcısında tutulur; bizde saklanmaz).</li>
    <li><strong>Sürücü KYC:</strong> kimlik, ehliyet, ruhsat, araç fotoğrafı (sürücü onayı için).</li>
    <li><strong>Cihaz / teknik:</strong> cihaz modeli, uygulama sürümü, çökme günlükleri, bildirim token’ı.</li>
    <li><strong>Sosyal giriş:</strong> Google / Apple ile girişte sağlayıcının paylaştığı kimlik bilgileri.</li>
</ul>

<h2>2. Verileri nasıl kullanırız</h2>
<ul>
    <li>Yolculuk talebi, eşleştirme ve canlı takip</li>
    <li>Hesap doğrulama, sürücü onayı ve güvenlik</li>
    <li>Ödeme, iade ve müşteri desteği</li>
    <li>Yasal yükümlülükler ve dolandırıcılık önleme</li>
    <li>Ürün iyileştirme (anonim / toplu istatistikler)</li>
</ul>

<h2>3. Paylaşım</h2>
<p>
    Verilerinizi satmayız. Yalnızca hizmet için gerekli üçüncü taraflarla paylaşırız:
    harita / konum sağlayıcıları, ödeme altyapısı, bulut barındırma (ör. Firebase),
    yasal zorunluluk halinde yetkili merciler.
</p>

<h2>4. Saklama süresi</h2>
<p>
    Hesap aktif olduğu sürece ve yasal saklama süreleri boyunca tutarız.
    Hesap silme talebinden sonra makul süre içinde siler veya anonimleştiririz
    (yasal zorunluluklar saklıdır).
</p>

<h2>5. Haklarınız</h2>
<ul>
    <li>Verilerinize erişim ve düzeltme</li>
    <li>Hesap / veri silme talebi</li>
    <li>Konum ve bildirim izinlerini cihaz ayarlarından kapatma</li>
</ul>
<p>
    Hesap silme: Uygulama içi hesap ayarları veya
    <a href="{{ route('legal.delete-account') }}">hesap silme sayfası</a>.
    Destek: <a href="mailto:{{ $supportEmail }}">{{ $supportEmail }}</a>
</p>

<h2>6. Çocuklar</h2>
<p>{{ $appName }} 13 yaşın altındaki çocuklara yönelik değildir.</p>

<h2>7. İletişim</h2>
<p>
    Gizlilik soruları için: <a href="mailto:{{ $supportEmail }}">{{ $supportEmail }}</a>
</p>
@endsection
