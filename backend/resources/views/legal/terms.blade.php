@extends('legal.layout')

@section('title', 'Kullanım Şartları')
@section('heading', 'Kullanım Şartları')

@section('content')
<p class="meta">Son güncelleme: {{ $updatedAt }}</p>

<p>
    {{ $appName }} uygulamasını kullanarak bu şartları kabul edersiniz.
    Kabul etmiyorsanız uygulamayı kullanmayın.
</p>

<h2>1. Hizmet</h2>
<p>
    {{ $appName }}, yolcular ile sürücüleri bir araya getiren bir mobil ulaşım platformudur.
    Taşıma hizmetini sürücüler sağlar; {{ $appName }} aracı bir teknoloji platformudur.
</p>

<h2>2. Hesap</h2>
<ul>
    <li>Doğru bilgi vermekle yükümlüsünüz.</li>
    <li>Hesap güvenliğinden siz sorumlusunuz.</li>
    <li>18 yaşından küçükler yasal vasi onayı olmadan sürücü olarak kayıt olamaz.</li>
</ul>

<h2>3. Yolcu ve sürücü kuralları</h2>
<ul>
    <li>Yasalara, trafik kurallarına ve saygılı iletişime uyun.</li>
    <li>Sahte belge, kötüye kullanım veya dolandırıcılık yasaktır.</li>
    <li>Sürücüler onaylanmadan çevrimiçi olamaz; belgeler doğrulanabilir.</li>
</ul>

<h2>4. Ücretler</h2>
<p>
    Tahmini ücret bilgilendirme amaçlıdır. Nihai ücret mesafe, süre, tarife ve kampanyalara göre değişebilir.
    Ödeme yöntemleri uygulamada gösterilir.
</p>

<h2>5. İptal ve sorumluluk</h2>
<p>
    İptal politikası uygulamadaki güncel kurallara tabidir.
    {{ $appName }}, sürücülerin eylemlerinden, gecikmelerden veya üçüncü taraf hizmet kesintilerinden
    kaynaklanan dolaylı zararlardan sorumlu tutulamaz; yasal zorunluluklar saklıdır.
</p>

<h2>6. Fikri mülkiyet</h2>
<p>Uygulama, marka ve içerik {{ $appName }}’a aittir. İzinsiz kopyalama yasaktır.</p>

<h2>7. Değişiklikler</h2>
<p>Şartları güncelleyebiliriz. Önemli değişikliklerde uygulamada veya e-posta ile bilgilendiririz.</p>

<h2>8. İletişim</h2>
<p><a href="mailto:{{ $supportEmail }}">{{ $supportEmail }}</a></p>
@endsection
