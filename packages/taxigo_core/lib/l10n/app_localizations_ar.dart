// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'TaxiGo';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get chooseYourLanguage => 'اختر لغتك';

  @override
  String get languageSubtitle => 'يمكنك تغيير ذلك لاحقاً في الإعدادات';

  @override
  String get continueButton => 'متابعة';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get ok => 'موافق';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get welcomeTitle => 'مرحباً بك في TaxiGo';

  @override
  String get welcomeSubtitle => 'رحلتك، طريقك';

  @override
  String get onboardingTitle1 => 'احجز رحلة فوراً';

  @override
  String get onboardingDesc1 => 'اعثر على السائقين القريبين وانطلق في دقائق';

  @override
  String get onboardingTitle2 => 'تتبع رحلتك مباشرة';

  @override
  String get onboardingDesc2 => 'شاهد السائق يقترب على الخريطة في الوقت الفعلي';

  @override
  String get onboardingTitle3 => 'آمن ومضمون';

  @override
  String get onboardingDesc3 => 'زر SOS ومشاركة الرحلة لراحة بالك';

  @override
  String get phoneLoginTitle => 'أدخل رقم هاتفك';

  @override
  String get phoneLoginSubtitle => 'سنرسل لك رمز التحقق';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get sendOtp => 'إرسال OTP';

  @override
  String get verifyOtpTitle => 'تحقق من OTP';

  @override
  String verifyOtpSubtitle(String phone) {
    return 'أدخل الرمز المكون من 6 أرقام المرسل إلى $phone';
  }

  @override
  String get otpCode => 'رمز OTP';

  @override
  String get verify => 'تحقق';

  @override
  String get resendOtp => 'إعادة إرسال OTP';

  @override
  String get profileSetupTitle => 'أكمل ملفك الشخصي';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get email => 'البريد الإلكتروني (اختياري)';

  @override
  String get homeTitle => 'إلى أين؟';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String nearbyDrivers(int count) {
    return '$count سائقين قريبين';
  }

  @override
  String get searchDestination => 'ابحث عن الوجهة';

  @override
  String get pickup => 'نقطة الانطلاق';

  @override
  String get dropoff => 'نقطة الوصول';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get fareEstimate => 'تقدير الأجرة';

  @override
  String get distance => 'المسافة';

  @override
  String get duration => 'المدة';

  @override
  String get vehicleType => 'نوع المركبة';

  @override
  String get vehicleStandard => 'عادي';

  @override
  String get vehicleComfort => 'مريح';

  @override
  String get vehiclePremium => 'فاخر';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get paymentCash => 'نقداً';

  @override
  String get paymentWallet => 'المحفظة';

  @override
  String get paymentCard => 'بطاقة';

  @override
  String get promoCode => 'رمز ترويجي';

  @override
  String get applyPromo => 'تطبيق';

  @override
  String get bookRide => 'احجز رحلة';

  @override
  String get rideStatusPending => 'جاري البحث عن سائق...';

  @override
  String get rideStatusDriverAssigned => 'تم تعيين السائق';

  @override
  String get rideStatusDriverArriving => 'السائق في الطريق';

  @override
  String get rideStatusDriverArrived => 'وصل السائق';

  @override
  String get rideStatusPassengerOnBoard => 'على متن المركبة';

  @override
  String get rideStatusInProgress => 'الرحلة جارية';

  @override
  String get rideStatusCompleted => 'اكتملت الرحلة';

  @override
  String get rideStatusCancelledPassenger => 'ألغيت بواسطتك';

  @override
  String get rideStatusCancelledDriver => 'ألغى السائق';

  @override
  String get rideStatusExpired => 'انتهت صلاحية الرحلة';

  @override
  String get cancelRide => 'إلغاء الرحلة';

  @override
  String get rateDriver => 'قيّم السائق';

  @override
  String get submitRating => 'إرسال التقييم';

  @override
  String get tripCompleted => 'اكتملت الرحلة';

  @override
  String get account => 'الحساب';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get editProfile => 'تعديل الملف';

  @override
  String get wallet => 'المحفظة';

  @override
  String get balance => 'الرصيد';

  @override
  String get topUp => 'شحن';

  @override
  String get transactions => 'المعاملات';

  @override
  String get tripHistory => 'سجل الرحلات';

  @override
  String get promos => 'الرموز الترويجية';

  @override
  String get complaints => 'الشكاوى';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get sos => 'SOS';

  @override
  String get sosConfirm => 'إرسال تنبيه طوارئ؟';

  @override
  String get sosSent => 'تم إرسال تنبيه الطوارئ';

  @override
  String get shareTrip => 'مشاركة الرحلة';

  @override
  String get shareTripMessage => 'تتبع رحلتي على TaxiGo';

  @override
  String get driverInfo => 'معلومات السائق';

  @override
  String get estimatedFare => 'الأجرة المقدرة';

  @override
  String get km => 'كم';

  @override
  String get minutes => 'د';

  @override
  String get noActiveRide => 'لا توجد رحلة نشطة';

  @override
  String get noTrips => 'لا توجد رحلات بعد';

  @override
  String get complaintSubject => 'الموضوع';

  @override
  String get complaintDescription => 'الوصف';

  @override
  String get submitComplaint => 'إرسال الشكوى';

  @override
  String get enterPromoCode => 'أدخل الرمز الترويجي';

  @override
  String get invalidPromo => 'رمز ترويجي غير صالح';

  @override
  String get promoApplied => 'تم تطبيق الرمز';

  @override
  String get appTitle => 'TaxiGo';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get loginWelcome => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجل الدخول برقم هاتفك';

  @override
  String get enterPhone => 'أدخل رقم الهاتف';

  @override
  String get verifyOtp => 'تحقق من OTP';

  @override
  String get confirm => 'تأكيد';

  @override
  String get edit => 'تعديل';

  @override
  String get language => 'اللغة';

  @override
  String get driverMode => 'وضع السائق';

  @override
  String get earnings => 'الأرباح';

  @override
  String get rideHistory => 'سجل الرحلات';

  @override
  String get rateRide => 'التقييمات';

  @override
  String get activeRide => 'رحلة نشطة';

  @override
  String get pickupLocation => 'موقع الالتقاط';

  @override
  String get dropoffLocation => 'موقع الوصول';

  @override
  String get mapTitle => 'الخريطة';

  @override
  String get driverArrived => 'وصلت';

  @override
  String get startTrip => 'بدء الرحلة';

  @override
  String get completeTrip => 'إنهاء الرحلة';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get pendingRides => 'طلب رحلة جديد';

  @override
  String get estimatedDistance => 'المسافة التقديرية';

  @override
  String get rejectRide => 'رفض';

  @override
  String get acceptRide => 'قبول';

  @override
  String get uploadDocument => 'رفع مستند';

  @override
  String get approvalPending => 'في انتظار الموافقة';

  @override
  String get approvalApproved => 'تمت الموافقة';

  @override
  String get approvalRejected => 'مرفوض';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get documentIdentity => 'وثيقة الهوية';

  @override
  String get documentLicense => 'رخصة القيادة';

  @override
  String get documentRegistration => 'تسجيل المركبة';

  @override
  String get documentVehiclePhoto => 'صورة المركبة';

  @override
  String get goOnline => 'اتصل';

  @override
  String get goOffline => 'انقطع';

  @override
  String get dailyEarnings => 'أرباح اليوم';

  @override
  String get weeklyEarnings => 'أرباح الأسبوع';

  @override
  String get onlineStatus => 'أنت متصل';

  @override
  String get offlineStatus => 'أنت غير متصل';

  @override
  String get becomeDriver => 'أريد أن أصبح سائقاً';

  @override
  String get switchToDriverMode => 'التبديل إلى وضع السائق';

  @override
  String get switchToPassengerMode => 'التبديل إلى وضع الراكب';

  @override
  String get driverApplicationPending => 'طلب السائق قيد المراجعة';

  @override
  String get driverApplicationRejected => 'تم رفض طلب السائق';

  @override
  String get viewApplicationStatus => 'عرض حالة الطلب';

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
