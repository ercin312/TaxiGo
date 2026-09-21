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

  @override
  String get locationUnavailableMapSelect =>
      'Konum alınamadı — haritadan seçin';

  @override
  String get podgoricaMontenegro => 'Podgorica, Karadağ';

  @override
  String get saveAddress => 'Adresi kaydet';

  @override
  String get addressLabelHint => 'Etiket (Ev, İş...)';

  @override
  String get locating => 'Konum alınıyor...';

  @override
  String get refreshLocation => 'Konumu yenile';

  @override
  String get searchDestinationHintMe => 'Karadağ’da ara (örn. Budva, Kotor...)';

  @override
  String get searchPickupHintMe => 'Karadağ’da alış noktası ara...';

  @override
  String get tapMapDropoff => 'Haritaya dokun: varış';

  @override
  String get tapMapPickup => 'Haritaya dokun: alış';

  @override
  String get drawingRoute => 'Yol tarifi çiziliyor…';

  @override
  String get taxiComing => 'Taksiniz geliyor';

  @override
  String get tripInProgressShort => 'Sürüş devam ediyor';

  @override
  String get matchedTaxiComing => 'Anlaştığın taksi sana geliyor';

  @override
  String get goingToDestination => 'Varışa gidiyorsunuz';

  @override
  String get taxiGeneric => 'Taksi';

  @override
  String get driverGeneric => 'Sürücü';

  @override
  String get onlyYourTaxiOnMap => 'Sadece senin taksin haritada';

  @override
  String get youAreHere => 'Sen buradasın';

  @override
  String get pickupPoint => 'Biniş noktası';

  @override
  String get yourTaxi => 'Senin taksin';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeri';

  @override
  String get vehicleMake => 'Marka';

  @override
  String get vehicleMakeHint => 'Örn. Toyota';

  @override
  String get vehicleModel => 'Model';

  @override
  String get vehicleModelHint => 'Örn. Corolla';

  @override
  String get vehicleYear => 'Model yılı';

  @override
  String get vehicleYearHint => 'Örn. 2020';

  @override
  String get vehicleColor => 'Renk';

  @override
  String get vehicleColorHint => 'Örn. Beyaz';

  @override
  String get vehiclePlate => 'Plaka';

  @override
  String get vehiclePlateHint => 'Örn. PG AB 01';

  @override
  String get returnToPassengerMode => 'Yolcu moduna dön';

  @override
  String get withdrawalRequest => 'Para çekme talebi';

  @override
  String get balanceLabel => 'Bakiye';

  @override
  String get amount => 'Tutar';

  @override
  String get bank => 'Banka';

  @override
  String get ibanAccount => 'IBAN / Hesap';

  @override
  String get accountHolder => 'Hesap sahibi';

  @override
  String get send => 'Gönder';

  @override
  String get withdrawalSubmitted => 'Para çekme talebi gönderildi.';

  @override
  String get profileUpdated => 'Profil güncellendi';

  @override
  String get shareLinkCopied => 'Paylaşım linki panoya kopyalandı';

  @override
  String get homeLabel => 'Ev';

  @override
  String get savedLabel => 'Kayıtlı';

  @override
  String get dropoffShort => 'Varış';

  @override
  String get taxiComingToYou => 'Taksiniz sana geliyor';

  @override
  String get headingToDestination => 'Varış noktasına gidiliyor…';

  @override
  String get boardOnlyThisVehicle => 'sadece bu araca bin';

  @override
  String pickupWithAddress(String address) {
    return 'Biniş: $address';
  }

  @override
  String get vehicleInfoTitle => 'Araç bilgileri';

  @override
  String get vehicleInfoSubtitle =>
      'Taksi moduna geçmek için araç bilgilerini ve zorunlu belgeleri yükleyin.';

  @override
  String fieldRequired(String field) {
    return '$field gerekli';
  }

  @override
  String get validYearRequired => 'Geçerli bir yıl girin';

  @override
  String get documentsUnderReviewHint =>
      'Belgeleriniz incelendikten sonra taksi modu açılacak. Onay için admin paneli gerekir.';

  @override
  String get navHome => 'Ev';

  @override
  String get navHistory => 'Geçmiş';

  @override
  String get navAccount => 'Hesabım';

  @override
  String greetingMorning(String name) {
    return 'Günaydın $name, hadi yola çıkalım!';
  }

  @override
  String greetingAfternoon(String name) {
    return 'İyi günler $name, hadi yola çıkalım!';
  }

  @override
  String greetingEvening(String name) {
    return 'İyi akşamlar $name, hadi yola çıkalım!';
  }

  @override
  String greetingNight(String name) {
    return 'İyi geceler $name, hadi yola çıkalım!';
  }

  @override
  String get favoriteLocations => 'Favori konumlar';

  @override
  String get favoriteLocationsHint =>
      'Önemli yerlerinizi hızlı erişim için kaydedin';

  @override
  String get workLabel => 'İş';

  @override
  String get othersLabel => 'Diğerleri';

  @override
  String get tapToAddAddress => 'Adres eklemek için dokunun';

  @override
  String get addMoreFavorites => 'Daha fazla ekle';

  @override
  String get favoritesTip =>
      'İpucu: Sık gittiğiniz adresleri kaydedin, daha hızlı yolculuk çağırın.';

  @override
  String get selectFromMap => 'Haritadan seç';

  @override
  String get searchPlace => 'Yer ara';

  @override
  String get searchRoute => 'Rota ara';

  @override
  String get arrivalAddress => 'Varış adresi';

  @override
  String get productTaxi => 'Taksi';

  @override
  String get productTransfer => 'Transfer';

  @override
  String get vehicleVan => 'Van';

  @override
  String get addNote => 'Not ekle';

  @override
  String get coupon => 'Kupon';

  @override
  String get callTaxiGo => 'TaxiGo çağır';

  @override
  String get scheduleRide => 'Planla';

  @override
  String get discoverYourDriver => 'Sürücünüzü keşfedin';

  @override
  String get reservationDetails => 'Rezervasyon detayları';

  @override
  String get tripDetails => 'Yolculuk detayları';

  @override
  String get payInVehicle => 'Araç içerisinde';

  @override
  String get manageTrip => 'Yolculuğu yönet';

  @override
  String get outOfServiceTitle => 'Konumunuz şu an hizmet alanımızda değil';

  @override
  String get outOfServiceBody =>
      'Devam etmek için Karadağ sınırları içinde bir alma noktası seçin.';

  @override
  String get historyCompleted => 'Tamamlandı';

  @override
  String get historyUpcoming => 'Yaklaşan';

  @override
  String get historyCancelled => 'İptal edildi';

  @override
  String get noUpcomingTrips => 'Yaklaşan yolculuk yok';

  @override
  String get noUpcomingTripsHint => 'Yaklaşan yolculuğunuz yok.';

  @override
  String get createNewTrip => 'Yeni yolculuk oluştur';

  @override
  String get upcomingTip => 'İpucu: Planlı yolculuklarınız burada görünecek.';

  @override
  String get noCompletedTrips => 'Henüz tamamlanan yolculuk yok';

  @override
  String get noCancelledTrips => 'İptal edilen yolculuk yok';

  @override
  String get accountSection => 'Hesabınız';

  @override
  String get accountSectionHint => 'Profilinizi ve ayarlarınızı yönetin';

  @override
  String get activitySection => 'Aktivite';

  @override
  String get activitySectionHint => 'Aktivitenizi ve geçmişinizi takip edin';

  @override
  String get settingsSection => 'Ayarlar';

  @override
  String get settingsSectionHint => 'Uygulama tercihleri ve profil seçenekleri';

  @override
  String get personalInfo => 'Kişisel bilgiler';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notificationsHint => 'Bildirimlerinizi görüntüleyin';

  @override
  String get upcomingTrips => 'Yaklaşan';

  @override
  String get upcomingTripsHint => 'Planlanmış yolculuklarınız';

  @override
  String get tripHistoryHint => 'Geçmiş yolculuklarınız';

  @override
  String get help => 'Yardım';

  @override
  String totalTrips(int count) {
    return 'Toplam yolculuk: $count';
  }

  @override
  String seatsCount(int count) {
    return '$count koltuk';
  }

  @override
  String etaMinutesShort(int minutes) {
    return '$minutes dk';
  }

  @override
  String get fareMayVary =>
      'Ücret trafik yoğunluğuna göre değişkenlik gösterebilir.';

  @override
  String get noteHint => 'Sürücüye not';

  @override
  String get rideScheduled => 'Yolculuk planlandı';

  @override
  String get swapLocations => 'Değiştir';

  @override
  String get recentDestinations => 'Son varışlar';

  @override
  String get noRecentDestinations => 'Son yerler burada görünecek';

  @override
  String get searchResults => 'Arama sonucu';

  @override
  String minutesElapsed(int minutes) {
    return '$minutes dak';
  }

  @override
  String get password => 'Şifre';

  @override
  String get rolePassenger => 'Yolcu';

  @override
  String get roleDriver => 'Sürücü';

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String topUpConfirm(String amount, String currency) {
    return 'Cüzdanınıza $amount $currency yüklensin mi?';
  }

  @override
  String get topUpSuccess => 'Cüzdan başarıyla yüklendi.';

  @override
  String get topUpHint =>
      'Tutar seçin. Süper admin yükleme modülünü açtığında ödeme güvenli işlenir.';

  @override
  String get topUpDisabled =>
      'Cüzdan yükleme şu an kapalı. Süper adminin Cüzdan Yükleme modülünü açması gerekir.';

  @override
  String get withdrawDisabled =>
      'Sürücü ödemeleri şu an kapalı. Süper adminin Sürücü Ödeme modülünü açması gerekir.';

  @override
  String get withdrawCash => 'Para çek';

  @override
  String get maskedCall => 'Gizli arama';

  @override
  String get rideChat => 'Mesaj';

  @override
  String get rideChatHint => 'Kısa mesaj…';

  @override
  String get rideChatPrivacyHint =>
      'Numaralar gizli kalır. Hızlı yanıt veya kısa not kullanın.';

  @override
  String get maskedCallDialing => 'Gizli numara ile bağlanılıyor…';

  @override
  String get maskedCallRequested =>
      'Gizli arama isteği gönderildi. Karşı taraf bilgilendirildi.';

  @override
  String get chatTplWhereAreYou => 'Neredesin?';

  @override
  String get chatTplImOutside => 'Dışarıdayım';

  @override
  String get chatTplAtTheDoor => 'Kapıdayım';

  @override
  String get chatTplLuggage => 'Bagajım var';

  @override
  String get chatTplRunningLate => '2–3 dk gecikeceğim';

  @override
  String get chatTplCantFind => 'Seni bulamıyorum';

  @override
  String get chatTplOk => 'Tamam';

  @override
  String get chatTplOnMyWay => 'Yoldayım';

  @override
  String get matchModeInstant => 'TaxiGo Çağır';

  @override
  String get matchModeBidding => 'Teklif / Açık artırma';

  @override
  String get matchModeInstantDesc =>
      'En yakın müsait sürücü sabit fiyatla otomatik eşleşir.';

  @override
  String get matchModeBiddingDesc =>
      'Sürücüler teklifinize karşı teklif verebilir. Beğendiğinizi seçersiniz.';

  @override
  String get fixedPriceTransfer => 'Sabit transfer ücreti';

  @override
  String get instantMatchHint =>
      'Sabit ücret · müsaitse en yakın sürücü anında atanır.';

  @override
  String get requestBids => 'Teklif iste';

  @override
  String get yourOffer => 'Teklifiniz';

  @override
  String get rideAgain => 'Tekrar çağır';

  @override
  String get viewEReceipt => 'E-fişi gör';

  @override
  String get eReceipt => 'E-fiş';

  @override
  String get eReceiptBadge => 'E-FİŞ';

  @override
  String get shareReceipt => 'Fişi paylaş';

  @override
  String get receiptCopied => 'Fiş panoya kopyalandı.';

  @override
  String get receiptExpenseHint =>
      'Bu e-fişi otel, iş seyahati veya masraf bildirimi için kullanın.';

  @override
  String get tripReference => 'Yolculuk referansı';

  @override
  String get completedAt => 'Tamamlandı';

  @override
  String get subtotal => 'Ara toplam';

  @override
  String get discount => 'İndirim';

  @override
  String get total => 'Toplam';

  @override
  String get taxId => 'Vergi no';
}
