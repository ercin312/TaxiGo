@extends('legal.layout')

@section('title', 'Hesap silme')
@section('heading', 'Hesap silme talebi')

@section('content')
<p>
    Apple App Store ve Google Play gereksinimleri uyarınca hesap silme talebinde bulunabilirsiniz.
</p>

<h2>Uygulama içinden</h2>
<ol>
    <li>{{ $appName }} uygulamasını açın ve giriş yapın.</li>
    <li>Hesap / Profil bölümüne gidin.</li>
    <li>Hesabı sil / Hesabı kapat seçeneğini kullanın (varsa).</li>
</ol>

<h2>E-posta ile</h2>
<p>
    Kayıtlı telefon veya e-posta adresinizle şu adrese yazın:<br>
    <a href="mailto:{{ $supportEmail }}?subject=Hesap%20Silme%20Talebi">{{ $supportEmail }}</a>
</p>
<p>Konu: <strong>Hesap Silme Talebi</strong>. Kimliğinizi doğrulayacak bilgileri ekleyin.</p>

<h2>Ne silinir?</h2>
<ul>
    <li>Profil ve giriş bilgileri</li>
    <li>Uygulama içi tercihler</li>
    <li>Silme sonrası erişilemeyen yolculuk geçmişi (yasal saklama süreleri saklıdır)</li>
</ul>

<p class="meta">
    Talebiniz işlendikten sonra hesabınız kapatılır. Yasal zorunluluk nedeniyle bazı kayıtlar
    sınırlı süre saklanabilir.
</p>
@endsection
