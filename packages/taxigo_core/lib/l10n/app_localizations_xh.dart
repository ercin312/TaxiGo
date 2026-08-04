// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Xhosa (`xh`).
class AppLocalizationsXh extends AppLocalizations {
  AppLocalizationsXh([String locale = 'xh']) : super(locale);

  @override
  String get appName => 'TaxiGo';

  @override
  String get selectLanguage => 'Dil seçin';

  @override
  String get chooseYourLanguage => 'Dilinizi seçin';

  @override
  String get languageSubtitle => 'Bunu sonra parametrlərdə dəyişə bilərsiniz';

  @override
  String get continueButton => 'Davam et';

  @override
  String get skip => 'Keç';

  @override
  String get next => 'Növbəti';

  @override
  String get getStarted => 'Başla';

  @override
  String get loading => 'Yüklənir...';

  @override
  String get error => 'Xəta';

  @override
  String get retry => 'Təkrar cəhd et';

  @override
  String get cancel => 'Ləğv et';

  @override
  String get save => 'Saxla';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Bəli';

  @override
  String get no => 'Xeyr';

  @override
  String get welcomeTitle => 'TaxiGo-ya xoş gəlmisiniz';

  @override
  String get welcomeSubtitle => 'Sizin səfəriniz, sizin yolunuz';

  @override
  String get onboardingTitle1 => 'Dərhal səfər sifariş edin';

  @override
  String get onboardingDesc1 =>
      'Yaxınlıqdakı sürücüləri tapın və dəqiqələr ərzində götürülməyə hazır olun';

  @override
  String get onboardingTitle2 => 'Səfərinizi canlı izləyin';

  @override
  String get onboardingDesc2 =>
      'Sürücünüzün xəritədə real vaxtda yaxınlaşmasını görün';

  @override
  String get onboardingTitle3 => 'Təhlükəsiz və etibarlı';

  @override
  String get onboardingDesc3 => 'SOS düyməsi və səfər paylaşımı ilə rahat olun';

  @override
  String get phoneLoginTitle => 'Telefon nömrənizi daxil edin';

  @override
  String get phoneLoginSubtitle => 'Sizə doğrulama kodu göndərəcəyik';

  @override
  String get phoneNumber => 'Telefon nömrəsi';

  @override
  String get sendOtp => 'OTP göndər';

  @override
  String get verifyOtpTitle => 'OTP-ni doğrula';

  @override
  String verifyOtpSubtitle(String phone) {
    return '$phone nömrəsinə göndərilən 6 rəqəmli kodu daxil edin';
  }

  @override
  String get otpCode => 'OTP kodu';

  @override
  String get verify => 'Doğrula';

  @override
  String get resendOtp => 'OTP-ni yenidən göndər';

  @override
  String get profileSetupTitle => 'Profilinizi tamamlayın';

  @override
  String get fullName => 'Ad soyad';

  @override
  String get email => 'E-poçt (istəyə bağlı)';

  @override
  String get homeTitle => 'Haraya?';

  @override
  String get currentLocation => 'Cari yer';

  @override
  String nearbyDrivers(int count) {
    return 'Yaxınlıqda $count sürücü';
  }

  @override
  String get searchDestination => 'Təyinat yerini axtar';

  @override
  String get pickup => 'Götürmə';

  @override
  String get dropoff => 'Endirmə';

  @override
  String get confirmBooking => 'Sifarişi təsdiqlə';

  @override
  String get fareEstimate => 'Qiymət təxmini';

  @override
  String get distance => 'Məsafə';

  @override
  String get duration => 'Müddət';

  @override
  String get vehicleType => 'Nəqliyyat növü';

  @override
  String get vehicleStandard => 'Standart';

  @override
  String get vehicleComfort => 'Komfort';

  @override
  String get vehiclePremium => 'Premium';

  @override
  String get paymentMethod => 'Ödəniş üsulu';

  @override
  String get paymentCash => 'Nağd';

  @override
  String get paymentWallet => 'Pul kisəsi';

  @override
  String get paymentCard => 'Kart';

  @override
  String get promoCode => 'Promo kod';

  @override
  String get applyPromo => 'Tətbiq et';

  @override
  String get bookRide => 'Səfər sifariş et';

  @override
  String get rideStatusPending => 'Sürücü axtarılır...';

  @override
  String get rideStatusDriverAssigned => 'Sürücü təyin edildi';

  @override
  String get rideStatusDriverArriving => 'Sürücü yoldadır';

  @override
  String get rideStatusDriverArrived => 'Sürücü çatdı';

  @override
  String get rideStatusPassengerOnBoard => 'Avtobusda';

  @override
  String get rideStatusInProgress => 'Səfər davam edir';

  @override
  String get rideStatusCompleted => 'Səfər tamamlandı';

  @override
  String get rideStatusCancelledPassenger => 'Siz ləğv etdiniz';

  @override
  String get rideStatusCancelledDriver => 'Sürücü ləğv etdi';

  @override
  String get rideStatusExpired => 'Səfər vaxtı bitdi';

  @override
  String get cancelRide => 'Səfəri ləğv et';

  @override
  String get rateDriver => 'Sürücünüzü qiymətləndirin';

  @override
  String get submitRating => 'Qiymətləndirməni göndər';

  @override
  String get tripCompleted => 'Səfər tamamlandı';

  @override
  String get account => 'Hesab';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Profili redaktə et';

  @override
  String get wallet => 'Pul kisəsi';

  @override
  String get balance => 'Balans';

  @override
  String get topUp => 'Artır';

  @override
  String get transactions => 'Əməliyyatlar';

  @override
  String get tripHistory => 'Səfər tarixi';

  @override
  String get promos => 'Promo kodlar';

  @override
  String get complaints => 'Şikayətlər';

  @override
  String get settings => 'Parametrlər';

  @override
  String get logout => 'Çıxış';

  @override
  String get sos => 'SOS';

  @override
  String get sosConfirm => 'Təcili yardım siqnalı göndərilsin?';

  @override
  String get sosSent => 'Təcili yardım siqnalı göndərildi';

  @override
  String get shareTrip => 'Səfəri paylaş';

  @override
  String get shareTripMessage => 'TaxiGo səfərimi izlə';

  @override
  String get driverInfo => 'Sürücü məlumatı';

  @override
  String get estimatedFare => 'Təxmini qiymət';

  @override
  String get km => 'km';

  @override
  String get minutes => 'dəq';

  @override
  String get noActiveRide => 'Aktiv səfər yoxdur';

  @override
  String get noTrips => 'Hələ səfər yoxdur';

  @override
  String get complaintSubject => 'Mövzu';

  @override
  String get complaintDescription => 'Təsvir';

  @override
  String get submitComplaint => 'Şikayət göndər';

  @override
  String get enterPromoCode => 'Promo kod daxil edin';

  @override
  String get invalidPromo => 'Yanlış promo kod';

  @override
  String get promoApplied => 'Promo tətbiq edildi';

  @override
  String get appTitle => 'TaxiGo';

  @override
  String get signIn => 'Daxil ol';

  @override
  String get signOut => 'Çıxış';

  @override
  String get loginWelcome => 'Xoş gəlmisiniz';

  @override
  String get loginSubtitle => 'Telefon nömrənizlə daxil olun';

  @override
  String get enterPhone => 'Telefon nömrəsi daxil edin';

  @override
  String get verifyOtp => 'OTP təsdiqlə';

  @override
  String get confirm => 'Təsdiqlə';

  @override
  String get edit => 'Redaktə et';

  @override
  String get language => 'Dil';

  @override
  String get driverMode => 'Sürücü rejimi';

  @override
  String get earnings => 'Qazanc';

  @override
  String get rideHistory => 'Səfər tarixçəsi';

  @override
  String get rateRide => 'Reytinq';

  @override
  String get activeRide => 'Aktiv səfər';

  @override
  String get pickupLocation => 'Götürmə yeri';

  @override
  String get dropoffLocation => 'Təyinat yeri';

  @override
  String get mapTitle => 'Xəritə';

  @override
  String get driverArrived => 'Çatdım';

  @override
  String get startTrip => 'Səfəri başlat';

  @override
  String get completeTrip => 'Səfəri bitir';

  @override
  String get noResults => 'Nəticə yoxdur';

  @override
  String get somethingWentWrong => 'Xəta baş verdi';

  @override
  String get pendingRides => 'Yeni səfər sorğusu';

  @override
  String get estimatedDistance => 'Təxmini məsafə';

  @override
  String get rejectRide => 'Rədd et';

  @override
  String get acceptRide => 'Qəbul et';

  @override
  String get uploadDocument => 'Sənəd yüklə';

  @override
  String get approvalPending => 'Təsdiq gözlənilir';

  @override
  String get approvalApproved => 'Təsdiqləndi';

  @override
  String get approvalRejected => 'Rədd edildi';

  @override
  String get tryAgain => 'Yenidən cəhd et';

  @override
  String get documentIdentity => 'Şəxsiyyət vəsiqəsi';

  @override
  String get documentLicense => 'Sürücülük vəsiqəsi';

  @override
  String get documentRegistration => 'Nəqliyyat qeydiyyatı';

  @override
  String get documentVehiclePhoto => 'Avtomobil şəkli';

  @override
  String get goOnline => 'Onlayn ol';

  @override
  String get goOffline => 'Oflayn ol';

  @override
  String get dailyEarnings => 'Bugünkü qazanc';

  @override
  String get weeklyEarnings => 'Həftəlik qazanc';

  @override
  String get onlineStatus => 'Onlaynsınız';

  @override
  String get offlineStatus => 'Oflaynsınız';

  @override
  String get becomeDriver => 'Sürücü olmaq istəyirəm';

  @override
  String get switchToDriverMode => 'Sürücü rejiminə keç';

  @override
  String get switchToPassengerMode => 'Sərnişin rejiminə keç';

  @override
  String get driverApplicationPending => 'Sürücü müraciətiniz yoxlanılır';

  @override
  String get driverApplicationRejected => 'Sürücü müraciətiniz rədd edildi';

  @override
  String get viewApplicationStatus => 'Müraciət statusuna bax';

  @override
  String get otpInAppTitle => 'Your verification code';

  @override
  String get otpInAppHint => 'Tap the code to fill automatically.';

  @override
  String get otpNotificationTitle => 'TaxiGo Verification';

  @override
  String otpNotificationBody(String code) {
    return 'Your login code: $code';
  }

  @override
  String get otpNotificationSent => 'Verification code sent as a notification.';

  @override
  String get offerYourFare => 'Offer Your Fare';

  @override
  String get recommendedFareMinimum => 'Recommended minimum fare';

  @override
  String get createRequest => 'Create Request';

  @override
  String get lookingForDrivers => 'Looking for nearby drivers';

  @override
  String get availableDrivers => 'Available drivers';

  @override
  String get updateOffer => 'Update Offer';

  @override
  String get currentFare => 'Current fare';

  @override
  String get offeredFare => 'Offered fare';

  @override
  String get acceptBid => 'Accept';

  @override
  String get rejectBid => 'Reject';

  @override
  String get counterBid => 'Counter Offer';

  @override
  String get bidSubmitted =>
      'Your bid was sent. Waiting for passenger approval.';

  @override
  String get passengerOffer => 'Passenger offer';

  @override
  String get noBidsYet => 'No driver bids yet. You can increase your offer.';

  @override
  String secondsLeft(int seconds) {
    return '${seconds}s left';
  }
}
