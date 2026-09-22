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
  String get otpInAppTitle => 'رمز التحقق الخاص بك';

  @override
  String get otpInAppHint => 'انقر على الرمز للتعبئة تلقائياً.';

  @override
  String get otpNotificationTitle => 'تحقق TaxiGo';

  @override
  String otpNotificationBody(String code) {
    return 'رمز الدخول: $code';
  }

  @override
  String get otpNotificationSent => 'تم إرسال رمز التحقق كإشعار.';

  @override
  String get offerYourFare => 'قدّم سعرك';

  @override
  String get recommendedFareMinimum => 'الحد الأدنى الموصى به';

  @override
  String get createRequest => 'إنشاء طلب';

  @override
  String get lookingForDrivers => 'البحث عن سائقين قريبين';

  @override
  String get availableDrivers => 'السائقون المتاحون';

  @override
  String get updateOffer => 'تحديث العرض';

  @override
  String get currentFare => 'السعر الحالي';

  @override
  String get offeredFare => 'السعر المعروض';

  @override
  String get acceptBid => 'قبول';

  @override
  String get rejectBid => 'رفض';

  @override
  String get counterBid => 'عرض مضاد';

  @override
  String get bidSubmitted => 'تم إرسال عرضك. بانتظار موافقة الراكب.';

  @override
  String get passengerOffer => 'عرض الراكب';

  @override
  String get noBidsYet => 'لا توجد عروض سائقين بعد. يمكنك زيادة عرضك.';

  @override
  String secondsLeft(int seconds) {
    return 'متبقي $secondsث';
  }

  @override
  String get locationUnavailableMapSelect =>
      'الموقع غير متاح — اختر على الخريطة';

  @override
  String get podgoricaMontenegro => 'بودغوريتسا، الجبل الأسود';

  @override
  String get saveAddress => 'حفظ العنوان';

  @override
  String get addressLabelHint => 'التسمية (المنزل، العمل...)';

  @override
  String get locating => 'جاري تحديد الموقع...';

  @override
  String get refreshLocation => 'تحديث الموقع';

  @override
  String get searchDestinationHintMe =>
      'ابحث في الجبل الأسود (مثل بودفا، كوتور...)';

  @override
  String get searchPickupHintMe => 'ابحث عن نقطة الالتقاط في الجبل الأسود...';

  @override
  String get tapMapDropoff => 'المس الخريطة: الوجهة';

  @override
  String get tapMapPickup => 'المس الخريطة: الالتقاط';

  @override
  String get drawingRoute => 'جاري رسم المسار…';

  @override
  String get taxiComing => 'سيارتكم في الطريق';

  @override
  String get tripInProgressShort => 'الرحلة جارية';

  @override
  String get matchedTaxiComing => 'التاكسي المتفق عليه في الطريق إليك';

  @override
  String get goingToDestination => 'في الطريق إلى الوجهة';

  @override
  String get taxiGeneric => 'تاكسي';

  @override
  String get driverGeneric => 'سائق';

  @override
  String get onlyYourTaxiOnMap => 'تاكسيك فقط على الخريطة';

  @override
  String get youAreHere => 'أنت هنا';

  @override
  String get pickupPoint => 'نقطة الالتقاط';

  @override
  String get yourTaxi => 'تاكسيك';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get vehicleMake => 'العلامة';

  @override
  String get vehicleMakeHint => 'مثال Toyota';

  @override
  String get vehicleModel => 'الطراز';

  @override
  String get vehicleModelHint => 'مثال Corolla';

  @override
  String get vehicleYear => 'سنة الطراز';

  @override
  String get vehicleYearHint => 'مثال 2020';

  @override
  String get vehicleColor => 'اللون';

  @override
  String get vehicleColorHint => 'مثال أبيض';

  @override
  String get vehiclePlate => 'اللوحة';

  @override
  String get vehiclePlateHint => 'مثال PG AB 01';

  @override
  String get returnToPassengerMode => 'العودة إلى وضع الراكب';

  @override
  String get withdrawalRequest => 'طلب سحب';

  @override
  String get balanceLabel => 'الرصيد';

  @override
  String get amount => 'المبلغ';

  @override
  String get bank => 'البنك';

  @override
  String get ibanAccount => 'IBAN / الحساب';

  @override
  String get accountHolder => 'صاحب الحساب';

  @override
  String get send => 'إرسال';

  @override
  String get withdrawalSubmitted => 'تم إرسال طلب السحب.';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get shareLinkCopied => 'تم نسخ رابط المشاركة';

  @override
  String get homeLabel => 'المنزل';

  @override
  String get savedLabel => 'محفوظ';

  @override
  String get dropoffShort => 'الوجهة';

  @override
  String get taxiComingToYou => 'سيارتكم في الطريق إليك';

  @override
  String get headingToDestination => 'في الطريق إلى الوجهة…';

  @override
  String get boardOnlyThisVehicle => 'اركب هذه السيارة فقط';

  @override
  String pickupWithAddress(String address) {
    return 'الالتقاط: $address';
  }

  @override
  String get vehicleInfoTitle => 'بيانات المركبة';

  @override
  String get vehicleInfoSubtitle =>
      'أدخل بيانات المركبة وارفع المستندات المطلوبة للتبديل إلى وضع التاكسي.';

  @override
  String fieldRequired(String field) {
    return '$field مطلوب';
  }

  @override
  String get validYearRequired => 'أدخل سنة صالحة';

  @override
  String get documentsUnderReviewHint =>
      'سيتم فتح وضع التاكسي بعد مراجعة مستنداتك. مطلوب موافقة المسؤول.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navHistory => 'السجل';

  @override
  String get navAccount => 'حسابي';

  @override
  String greetingMorning(String name) {
    return 'صباح الخير $name، هيا ننطلق!';
  }

  @override
  String greetingAfternoon(String name) {
    return 'مساء الخير $name، هيا ننطلق!';
  }

  @override
  String greetingEvening(String name) {
    return 'مساء الخير $name، هيا ننطلق!';
  }

  @override
  String greetingNight(String name) {
    return 'تصبح على خير $name، هيا ننطلق!';
  }

  @override
  String get favoriteLocations => 'الأماكن المفضلة';

  @override
  String get favoriteLocationsHint => 'Save important places for quick access';

  @override
  String get workLabel => 'العمل';

  @override
  String get othersLabel => 'أخرى';

  @override
  String get tapToAddAddress => 'Tap to add address';

  @override
  String get addMoreFavorites => 'Add more';

  @override
  String get favoritesTip =>
      'Tip: Save addresses you visit often for faster booking.';

  @override
  String get selectFromMap => 'اختر من الخريطة';

  @override
  String get searchPlace => 'Search place';

  @override
  String get searchRoute => 'Search route';

  @override
  String get arrivalAddress => 'عنوان الوجهة';

  @override
  String get productTaxi => 'تاكسي';

  @override
  String get productTransfer => 'نقل';

  @override
  String get vehicleVan => 'Van';

  @override
  String get addNote => 'Add note';

  @override
  String get coupon => 'Coupon';

  @override
  String get callTaxiGo => 'اطلب TaxiGo';

  @override
  String get scheduleRide => 'Schedule';

  @override
  String get discoverYourDriver => 'اكتشف سائقك';

  @override
  String get reservationDetails => 'Reservation details';

  @override
  String get tripDetails => 'Trip details';

  @override
  String get payInVehicle => 'Pay in vehicle';

  @override
  String get manageTrip => 'Manage trip';

  @override
  String get outOfServiceTitle => 'Your location is outside our service area';

  @override
  String get outOfServiceBody =>
      'Set a pickup point within Montenegro to continue.';

  @override
  String get historyCompleted => 'مكتملة';

  @override
  String get historyUpcoming => 'قادمة';

  @override
  String get historyCancelled => 'ملغاة';

  @override
  String get noUpcomingTrips => 'No upcoming trips';

  @override
  String get noUpcomingTripsHint => 'You have no scheduled trips.';

  @override
  String get createNewTrip => 'Create new trip';

  @override
  String get upcomingTip => 'Tip: Your scheduled trips will appear here.';

  @override
  String get noCompletedTrips => 'No completed trips yet';

  @override
  String get noCancelledTrips => 'No cancelled trips';

  @override
  String get accountSection => 'Your account';

  @override
  String get accountSectionHint => 'Manage profile and settings';

  @override
  String get activitySection => 'Activity';

  @override
  String get activitySectionHint => 'Track activity and history';

  @override
  String get settingsSection => 'Settings';

  @override
  String get settingsSectionHint => 'App preferences and profile options';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsHint => 'View your notifications';

  @override
  String get upcomingTrips => 'Upcoming';

  @override
  String get upcomingTripsHint => 'Your scheduled trips';

  @override
  String get tripHistoryHint => 'Your past trips';

  @override
  String get help => 'مساعدة';

  @override
  String totalTrips(int count) {
    return 'Total trips: $count';
  }

  @override
  String seatsCount(int count) {
    return '$count seats';
  }

  @override
  String etaMinutesShort(int minutes) {
    return '$minutes mins';
  }

  @override
  String get fareMayVary => 'Fare may vary with traffic.';

  @override
  String get noteHint => 'Note for driver';

  @override
  String get rideScheduled => 'Ride scheduled';

  @override
  String get swapLocations => 'Swap';

  @override
  String get recentDestinations => 'Recent destinations';

  @override
  String get noRecentDestinations => 'Recent places will appear here';

  @override
  String get searchResults => 'Search results';

  @override
  String minutesElapsed(int minutes) {
    return '$minutes min';
  }

  @override
  String get password => 'كلمة المرور';

  @override
  String get rolePassenger => 'راكب';

  @override
  String get roleDriver => 'سائق';

  @override
  String get continueWithGoogle => 'المتابعة مع Google';

  @override
  String topUpConfirm(String amount, String currency) {
    return 'شحن المحفظة بمبلغ $amount $currency؟';
  }

  @override
  String get topUpSuccess => 'تم شحن المحفظة بنجاح.';

  @override
  String get topUpHint =>
      'اختر المبلغ. تتم المعالجة عند تفعيل المشرف العام للشحن.';

  @override
  String get topUpDisabled => 'شحن المحفظة معطل حالياً.';

  @override
  String get withdrawDisabled => 'مدفوعات السائق معطلة حالياً.';

  @override
  String get withdrawCash => 'سحب';

  @override
  String get maskedCall => 'اتصال خاص';

  @override
  String get rideChat => 'رسالة';

  @override
  String get rideChatHint => 'رسالة قصيرة…';

  @override
  String get rideChatPrivacyHint => 'رسائل فقط — تبقى أرقام الهاتف خاصة.';

  @override
  String get maskedCallDialing => 'جارٍ الاتصال عبر رقم خاص…';

  @override
  String get maskedCallRequested => 'تم طلب اتصال خاص. تم إشعار الطرف الآخر.';

  @override
  String get chatTplWhereAreYou => 'أين أنت؟';

  @override
  String get chatTplImOutside => 'أنا في الخارج';

  @override
  String get chatTplAtTheDoor => 'عند الباب';

  @override
  String get chatTplLuggage => 'معي أمتعة';

  @override
  String get chatTplRunningLate => 'سأتأخر دقيقتين';

  @override
  String get chatTplCantFind => 'لا أجدك';

  @override
  String get chatTplOk => 'حسناً';

  @override
  String get chatTplOnMyWay => 'في الطريق';

  @override
  String get matchModeInstant => 'اطلب TaxiGo';

  @override
  String get matchModeBidding => 'عرض / مزايدة';

  @override
  String get matchModeInstantDesc =>
      'يُعيَّن أقرب سائق متاح تلقائياً بسعر ثابت.';

  @override
  String get matchModeBiddingDesc =>
      'يمكن للسائقين تقديم عروض مضادة. أنت تختار.';

  @override
  String get fixedPriceTransfer => 'سعر نقل ثابت';

  @override
  String get instantMatchHint =>
      'سعر ثابت · يُعيَّن أقرب سائق فوراً عند التوفر.';

  @override
  String get requestBids => 'اطلب عروضاً';

  @override
  String get yourOffer => 'عرضك';

  @override
  String get rideAgain => 'اطلب مجدداً';

  @override
  String get viewEReceipt => 'عرض الإيصال';

  @override
  String get eReceipt => 'إيصال إلكتروني';

  @override
  String get eReceiptBadge => 'إيصال';

  @override
  String get shareReceipt => 'مشاركة الإيصال';

  @override
  String get receiptCopied => 'تم نسخ الإيصال.';

  @override
  String get receiptExpenseHint =>
      'استخدم هذا الإيصال للفنادق أو رحلات العمل أو المصاريف.';

  @override
  String get tripReference => 'مرجع الرحلة';

  @override
  String get completedAt => 'اكتملت';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get discount => 'خصم';

  @override
  String get total => 'الإجمالي';

  @override
  String get taxId => 'الرقم الضريبي';
}
