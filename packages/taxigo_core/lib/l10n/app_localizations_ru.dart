// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'TaxiGo';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get chooseYourLanguage => 'Выберите ваш язык';

  @override
  String get languageSubtitle => 'Вы можете изменить это позже в настройках';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get getStarted => 'Начать';

  @override
  String get loading => 'Загрузка...';

  @override
  String get error => 'Ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get welcomeTitle => 'Добро пожаловать в TaxiGo';

  @override
  String get welcomeSubtitle => 'Ваша поездка, ваш путь';

  @override
  String get onboardingTitle1 => 'Закажите по neз instantly';

  @override
  String get onboardingDesc1 =>
      'Найдите ближайших водителей и отправляйтесь за минуты';

  @override
  String get onboardingTitle2 => 'Отслеживайте поездку в реальном времени';

  @override
  String get onboardingDesc2 => 'Смотрите, как водитель приближается на карте';

  @override
  String get onboardingTitle3 => 'Безопасно и надежно';

  @override
  String get onboardingDesc3 =>
      'Кнопка SOS и обмен поездкой для вашего спокойствия';

  @override
  String get phoneLoginTitle => 'Введите номер телефона';

  @override
  String get phoneLoginSubtitle => 'Мы отправим вам код подтверждения';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get sendOtp => 'Отправить OTP';

  @override
  String get verifyOtpTitle => 'Подтвердите OTP';

  @override
  String verifyOtpSubtitle(String phone) {
    return 'Введите 6-значный код, отправленный на $phone';
  }

  @override
  String get otpCode => 'Код OTP';

  @override
  String get verify => 'Подтвердить';

  @override
  String get resendOtp => 'Отправить OTP повторно';

  @override
  String get profileSetupTitle => 'Заполните профиль';

  @override
  String get fullName => 'Полное имя';

  @override
  String get email => 'Email (необязательно)';

  @override
  String get homeTitle => 'Куда?';

  @override
  String get currentLocation => 'Текущее местоположение';

  @override
  String nearbyDrivers(int count) {
    return '$count водителей рядом';
  }

  @override
  String get searchDestination => 'Поиск пункта назначения';

  @override
  String get pickup => 'Посадка';

  @override
  String get dropoff => 'Высадка';

  @override
  String get confirmBooking => 'Подтвердить заказ';

  @override
  String get fareEstimate => 'Оценка стоимости';

  @override
  String get distance => 'Расстояние';

  @override
  String get duration => 'Длительность';

  @override
  String get vehicleType => 'Тип автомобиля';

  @override
  String get vehicleStandard => 'Стандарт';

  @override
  String get vehicleComfort => 'Комфорт';

  @override
  String get vehiclePremium => 'Премиум';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get paymentCash => 'Наличные';

  @override
  String get paymentWallet => 'Кошелек';

  @override
  String get paymentCard => 'Карта';

  @override
  String get promoCode => 'Промокод';

  @override
  String get applyPromo => 'Применить';

  @override
  String get bookRide => 'Заказать поездку';

  @override
  String get rideStatusPending => 'Поиск водителя...';

  @override
  String get rideStatusDriverAssigned => 'Водитель назначен';

  @override
  String get rideStatusDriverArriving => 'Водитель в пути';

  @override
  String get rideStatusDriverArrived => 'Водитель прибыл';

  @override
  String get rideStatusPassengerOnBoard => 'В машине';

  @override
  String get rideStatusInProgress => 'Поездка продолжается';

  @override
  String get rideStatusCompleted => 'Поездка завершена';

  @override
  String get rideStatusCancelledPassenger => 'Отменено вами';

  @override
  String get rideStatusCancelledDriver => 'Отменено водителем';

  @override
  String get rideStatusExpired => 'Время истекло';

  @override
  String get cancelRide => 'Отменить поездку';

  @override
  String get rateDriver => 'Оцените водителя';

  @override
  String get submitRating => 'Отправить оценку';

  @override
  String get tripCompleted => 'Поездка завершена';

  @override
  String get account => 'Аккаунт';

  @override
  String get profile => 'Профиль';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get wallet => 'Кошелек';

  @override
  String get balance => 'Баланс';

  @override
  String get topUp => 'Пополнить';

  @override
  String get transactions => 'Транзакции';

  @override
  String get tripHistory => 'История поездок';

  @override
  String get promos => 'Промокоды';

  @override
  String get complaints => 'Жалобы';

  @override
  String get settings => 'Настройки';

  @override
  String get logout => 'Выйти';

  @override
  String get sos => 'SOS';

  @override
  String get sosConfirm => 'Отправить сигнал SOS?';

  @override
  String get sosSent => 'Сигнал SOS отправлен';

  @override
  String get shareTrip => 'Поделиться поездкой';

  @override
  String get shareTripMessage => 'Отслеживайте мою поездку TaxiGo';

  @override
  String get driverInfo => 'Информация о водителе';

  @override
  String get estimatedFare => 'Примерная стоимость';

  @override
  String get km => 'км';

  @override
  String get minutes => 'мин';

  @override
  String get noActiveRide => 'Нет активной поездки';

  @override
  String get noTrips => 'Пока нет поездок';

  @override
  String get complaintSubject => 'Тема';

  @override
  String get complaintDescription => 'Описание';

  @override
  String get submitComplaint => 'Отправить жалобу';

  @override
  String get enterPromoCode => 'Введите промокод';

  @override
  String get invalidPromo => 'Неверный промокод';

  @override
  String get promoApplied => 'Промокод применен';

  @override
  String get appTitle => 'TaxiGo';

  @override
  String get signIn => 'Войти';

  @override
  String get signOut => 'Выйти';

  @override
  String get loginWelcome => 'С возвращением';

  @override
  String get loginSubtitle => 'Войдите с номером телефона';

  @override
  String get enterPhone => 'Введите номер телефона';

  @override
  String get verifyOtp => 'Подтвердить OTP';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get edit => 'Изменить';

  @override
  String get language => 'Язык';

  @override
  String get driverMode => 'Режим водителя';

  @override
  String get earnings => 'Заработок';

  @override
  String get rideHistory => 'История поездок';

  @override
  String get rateRide => 'Рейтинг';

  @override
  String get activeRide => 'Активная поездка';

  @override
  String get pickupLocation => 'Место посадки';

  @override
  String get dropoffLocation => 'Место назначения';

  @override
  String get mapTitle => 'Карта';

  @override
  String get driverArrived => 'Прибыл';

  @override
  String get startTrip => 'Начать поездку';

  @override
  String get completeTrip => 'Завершить поездку';

  @override
  String get noResults => 'Нет результатов';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get pendingRides => 'Новый запрос';

  @override
  String get estimatedDistance => 'Расстояние';

  @override
  String get rejectRide => 'Отклонить';

  @override
  String get acceptRide => 'Принять';

  @override
  String get uploadDocument => 'Загрузить документ';

  @override
  String get approvalPending => 'Ожидает одобрения';

  @override
  String get approvalApproved => 'Одобрено';

  @override
  String get approvalRejected => 'Отклонено';

  @override
  String get tryAgain => 'Повторить';

  @override
  String get documentIdentity => 'Удостоверение личности';

  @override
  String get documentLicense => 'Водительские права';

  @override
  String get documentRegistration => 'Регистрация ТС';

  @override
  String get documentVehiclePhoto => 'Фото автомобиля';

  @override
  String get goOnline => 'Выйти на линию';

  @override
  String get goOffline => 'Уйти с линии';

  @override
  String get dailyEarnings => 'Заработок за сегодня';

  @override
  String get weeklyEarnings => 'Заработок за неделю';

  @override
  String get onlineStatus => 'Вы на линии';

  @override
  String get offlineStatus => 'Вы не на линии';

  @override
  String get becomeDriver => 'Хочу стать водителем';

  @override
  String get switchToDriverMode => 'Режим водителя';

  @override
  String get switchToPassengerMode => 'Режим пассажира';

  @override
  String get driverApplicationPending => 'Заявка водителя на рассмотрении';

  @override
  String get driverApplicationRejected => 'Заявка водителя отклонена';

  @override
  String get viewApplicationStatus => 'Статус заявки';

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
