@extends('legal.layout')

@section('title', 'Destek')
@section('heading', 'Destek')

@section('content')
<p>
    {{ $appName }} ile ilgili yardım, şikayet, yolculuk sorunları ve hesap işlemleri için
    bize ulaşın.
</p>

<h2>İletişim</h2>
<ul>
    <li>E-posta: <a href="mailto:{{ $supportEmail }}">{{ $supportEmail }}</a></li>
    <li>Uygulama içi: Hesap → Şikayetler / Destek</li>
</ul>

<h2>Yanıt süresi</h2>
<p>İş günlerinde genellikle 1–3 gün içinde dönüş yaparız.</p>

<h2>Faydalı bağlantılar</h2>
<ul>
    <li><a href="{{ route('legal.privacy') }}">Gizlilik Politikası</a></li>
    <li><a href="{{ route('legal.terms') }}">Kullanım Şartları</a></li>
    <li><a href="{{ route('legal.delete-account') }}">Hesap silme</a></li>
</ul>
@endsection
