// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'TaxiGo';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get chooseYourLanguage => 'Dilinizi seçin';

  @override
  String get languageSubtitle =>
      'Bunu daha sonra ayarlardan değiştirebilirsiniz';

  @override
  String get continueButton => 'Devam';

  @override
  String get skip => 'Atla';

  @override
  String get next => 'İleri';

  @override
  String get getStarted => 'Başla';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get error => 'Hata';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get ok => 'Tamam';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get welcomeTitle => 'TaxiGo\'ya Hoş Geldiniz';

  @override
  String get welcomeSubtitle => 'Yolculuğunuz, sizin yolunuz';

  @override
  String get onboardingTitle1 => 'Anında yolculuk rezervasyonu';

  @override
  String get onboardingDesc1 =>
      'Yakındaki sürücüleri bulun ve dakikalar içinde alının';

  @override
  String get onboardingTitle2 => 'Yolculuğunuzu canlı takip edin';

  @override
  String get onboardingDesc2 =>
      'Sürücünüzün haritada gerçek zamanlı yaklaşmasını görün';

  @override
  String get onboardingTitle3 => 'Güvenli ve emniyetli';

  @override
  String get onboardingDesc3 =>
      'SOS butonu ve yolculuk paylaşımı ile içiniz rahat olsun';

  @override
  String get phoneLoginTitle => 'Telefon numaranızı girin';

  @override
  String get phoneLoginSubtitle =>
      'Doğrulama kodu uygulama içinde gösterilir (SMS gönderilmez)';

  @override
  String get phoneNumber => 'Telefon numarası';

  @override
  String get sendOtp => 'OTP Gönder';

  @override
  String get verifyOtpTitle => 'OTP Doğrula';

  @override
  String verifyOtpSubtitle(String phone) {
    return '$phone için uygulamada gösterilen 6 haneli kodu girin';
  }

  @override
  String get otpCode => 'OTP Kodu';

  @override
  String get verify => 'Doğrula';

  @override
  String get resendOtp => 'OTP Tekrar Gönder';

  @override
  String get profileSetupTitle => 'Profilinizi tamamlayın';

  @override
  String get fullName => 'Ad soyad';

  @override
  String get email => 'E-posta (isteğe bağlı)';

  @override
  String get homeTitle => 'Nereye?';

  @override
  String get currentLocation => 'Mevcut konum';

  @override
  String nearbyDrivers(int count) {
    return 'Yakında $count sürücü';
  }

  @override
  String get searchDestination => 'Varış noktası ara';

  @override
  String get pickup => 'Alış';

  @override
  String get dropoff => 'Varış';

  @override
  String get confirmBooking => 'Rezervasyonu Onayla';

  @override
  String get fareEstimate => 'Ücret Tahmini';

  @override
  String get distance => 'Mesafe';

  @override
  String get duration => 'Süre';

  @override
  String get vehicleType => 'Araç Tipi';

  @override
  String get vehicleStandard => 'Standart';

  @override
  String get vehicleComfort => 'Konfor';

  @override
  String get vehiclePremium => 'Premium';

  @override
  String get paymentMethod => 'Ödeme Yöntemi';

  @override
  String get paymentCash => 'Nakit';

  @override
  String get paymentWallet => 'Cüzdan';

  @override
  String get paymentCard => 'Kart';

  @override
  String get promoCode => 'Promosyon kodu';

  @override
  String get applyPromo => 'Uygula';

  @override
  String get bookRide => 'Yolculuk Rezerve Et';

  @override
  String get rideStatusPending => 'Sürücü aranıyor...';

  @override
  String get rideStatusDriverAssigned => 'Sürücü atandı';

  @override
  String get rideStatusDriverArriving => 'Sürücü yolda';

  @override
  String get rideStatusDriverArrived => 'Sürücü geldi';

  @override
  String get rideStatusPassengerOnBoard => 'Araçta';

  @override
  String get rideStatusInProgress => 'Yolculuk devam ediyor';

  @override
  String get rideStatusCompleted => 'Yolculuk tamamlandı';

  @override
  String get rideStatusCancelledPassenger => 'Siz iptal ettiniz';

  @override
  String get rideStatusCancelledDriver => 'Sürücü iptal etti';

  @override
  String get rideStatusExpired => 'Yolculuk süresi doldu';

  @override
  String get cancelRide => 'Yolculuğu İptal Et';

  @override
  String get rateDriver => 'Sürücünüzü değerlendirin';

  @override
  String get submitRating => 'Değerlendirmeyi Gönder';

  @override
  String get tripCompleted => 'Yolculuk Tamamlandı';

  @override
  String get account => 'Hesap';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get wallet => 'Cüzdan';

  @override
  String get balance => 'Bakiye';

  @override
  String get topUp => 'Yükle';

  @override
  String get transactions => 'İşlemler';

  @override
  String get tripHistory => 'Yolculuk Geçmişi';

  @override
  String get promos => 'Promosyon Kodları';

  @override
  String get complaints => 'Şikayetler';

  @override
  String get settings => 'Ayarlar';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get sos => 'SOS';

  @override
  String get sosConfirm => 'Acil durum uyarısı gönderilsin mi?';

  @override
  String get sosSent => 'Acil durum uyarısı gönderildi';

  @override
  String get shareTrip => 'Yolculuğu Paylaş';

  @override
  String get shareTripMessage => 'TaxiGo yolculuğumu takip et';

  @override
  String get driverInfo => 'Sürücü Bilgisi';

  @override
  String get estimatedFare => 'Tahmini ücret';

  @override
  String get km => 'km';

  @override
  String get minutes => 'dk';

  @override
  String get noActiveRide => 'Aktif yolculuk yok';

  @override
  String get noTrips => 'Henüz yolculuk yok';

  @override
  String get complaintSubject => 'Konu';

  @override
  String get complaintDescription => 'Açıklama';

  @override
  String get submitComplaint => 'Şikayet Gönder';

  @override
  String get enterPromoCode => 'Promosyon kodu girin';

  @override
  String get invalidPromo => 'Geçersiz promosyon kodu';

  @override
  String get promoApplied => 'Promosyon uygulandı';

  @override
  String get appTitle => 'TaxiGo';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get loginWelcome => 'Tekrar hoş geldiniz';

  @override
  String get loginSubtitle => 'Telefon numaranızla giriş yapın';

  @override
  String get enterPhone => 'Telefon numarası girin';

  @override
  String get verifyOtp => 'OTP Doğrula';

  @override
  String get confirm => 'Onayla';

  @override
  String get edit => 'Düzenle';

  @override
  String get language => 'Dil';

  @override
  String get driverMode => 'Sürücü Modu';

  @override
  String get earnings => 'Kazançlar';

  @override
  String get rideHistory => 'Yolculuk Geçmişi';

  @override
  String get rateRide => 'Puanlar';

  @override
  String get activeRide => 'Aktif Yolculuk';

  @override
  String get pickupLocation => 'Alış noktası';

  @override
  String get dropoffLocation => 'Varış noktası';

  @override
  String get mapTitle => 'Harita';

  @override
  String get driverArrived => 'Vardım';

  @override
  String get startTrip => 'Yolculuğu Başlat';

  @override
  String get completeTrip => 'Yolculuğu Bitir';

  @override
  String get noResults => 'Sonuç yok';

  @override
  String get somethingWentWrong => 'Bir şeyler yanlış gitti';

  @override
  String get pendingRides => 'Yeni yolculuk isteği';

  @override
  String get estimatedDistance => 'Tahmini mesafe';

  @override
  String get rejectRide => 'Reddet';

  @override
  String get acceptRide => 'Kabul Et';

  @override
  String get uploadDocument => 'Belge yükle';

  @override
  String get approvalPending => 'Onay bekleniyor';

  @override
  String get approvalApproved => 'Onaylandı';

  @override
  String get approvalRejected => 'Reddedildi';

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String get documentIdentity => 'Kimlik belgesi';

  @override
  String get documentLicense => 'Ehliyet';

  @override
  String get documentRegistration => 'Ruhsat';

  @override
  String get documentVehiclePhoto => 'Araç fotoğrafı';

  @override
  String get goOnline => 'Çevrimiçi Ol';

  @override
  String get goOffline => 'Çevrimdışı Ol';

  @override
  String get dailyEarnings => 'Bugünkü kazanç';

  @override
  String get weeklyEarnings => 'Bu haftaki kazanç';

  @override
  String get onlineStatus => 'Çevrimiçisiniz';

  @override
  String get offlineStatus => 'Çevrimdışısınız';

  @override
  String get becomeDriver => 'Şoför olmak istiyorum';

  @override
  String get switchToDriverMode => 'Sürücü moduna geç';

  @override
  String get switchToPassengerMode => 'Yolcu moduna geç';

  @override
  String get driverApplicationPending => 'Sürücü başvurunuz inceleniyor';

  @override
  String get driverApplicationRejected => 'Sürücü başvurunuz reddedildi';

  @override
  String get viewApplicationStatus => 'Başvuru durumunu görüntüle';

  @override
  String get otpInAppTitle => 'Doğrulama kodunuz';

  @override
  String get otpInAppHint => 'Koda dokunarak otomatik doldurun.';

  @override
  String get otpNotificationTitle => 'TaxiGo Doğrulama';

  @override
  String otpNotificationBody(String code) {
    return 'Giriş kodunuz: $code';
  }

  @override
  String get otpNotificationSent =>
      'Doğrulama kodu bildirim olarak gönderildi.';

  @override
  String get offerYourFare => 'Ücretinizi Teklif Edin';

  @override
  String get recommendedFareMinimum => 'Önerilen minimum ücret';

  @override
  String get createRequest => 'Talep Oluştur';

  @override
  String get lookingForDrivers => 'Yakındaki sürücüler aranıyor';

  @override
  String get availableDrivers => 'Müsait sürücüler';

  @override
  String get updateOffer => 'Teklifi Güncelle';

  @override
  String get currentFare => 'Güncel ücret';

  @override
  String get offeredFare => 'Teklif edilen ücret';

  @override
  String get acceptBid => 'Kabul Et';

  @override
  String get rejectBid => 'Reddet';

  @override
  String get counterBid => 'Karşı Teklif';

  @override
  String get bidSubmitted => 'Teklifiniz gönderildi. Yolcu onayı bekleniyor.';

  @override
  String get passengerOffer => 'Yolcu teklifi';

  @override
  String get noBidsYet =>
      'Henüz sürücü teklifi yok. Teklifinizi artırabilirsiniz.';

  @override
  String secondsLeft(int seconds) {
    return '$seconds sn kaldı';
  }
}
