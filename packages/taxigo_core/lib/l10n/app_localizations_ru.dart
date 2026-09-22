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
  String get otpInAppTitle => 'Ваш код подтверждения';

  @override
  String get otpInAppHint => 'Нажмите код, чтобы заполнить автоматически.';

  @override
  String get otpNotificationTitle => 'Подтверждение TaxiGo';

  @override
  String otpNotificationBody(String code) {
    return 'Ваш код входа: $code';
  }

  @override
  String get otpNotificationSent => 'Код подтверждения отправлен уведомлением.';

  @override
  String get offerYourFare => 'Предложите цену';

  @override
  String get recommendedFareMinimum => 'Рекомендуемая минимальная цена';

  @override
  String get createRequest => 'Создать запрос';

  @override
  String get lookingForDrivers => 'Поиск водителей рядом';

  @override
  String get availableDrivers => 'Доступные водители';

  @override
  String get updateOffer => 'Обновить предложение';

  @override
  String get currentFare => 'Текущая цена';

  @override
  String get offeredFare => 'Предложенная цена';

  @override
  String get acceptBid => 'Принять';

  @override
  String get rejectBid => 'Отклонить';

  @override
  String get counterBid => 'Встречное предложение';

  @override
  String get bidSubmitted =>
      'Ваше предложение отправлено. Ожидается подтверждение пассажира.';

  @override
  String get passengerOffer => 'Предложение пассажира';

  @override
  String get noBidsYet =>
      'Пока нет предложений водителей. Вы можете увеличить свою цену.';

  @override
  String secondsLeft(int seconds) {
    return 'Осталось $secondsс';
  }

  @override
  String get locationUnavailableMapSelect =>
      'Местоположение недоступно — выберите на карте';

  @override
  String get podgoricaMontenegro => 'Подгорица, Черногория';

  @override
  String get saveAddress => 'Сохранить адрес';

  @override
  String get addressLabelHint => 'Метка (Дом, Работа...)';

  @override
  String get locating => 'Определение местоположения...';

  @override
  String get refreshLocation => 'Обновить местоположение';

  @override
  String get searchDestinationHintMe =>
      'Поиск в Черногории (напр. Будва, Котор...)';

  @override
  String get searchPickupHintMe => 'Поиск точки посадки в Черногории...';

  @override
  String get tapMapDropoff => 'Нажмите на карту: пункт назначения';

  @override
  String get tapMapPickup => 'Нажмите на карту: посадка';

  @override
  String get drawingRoute => 'Построение маршрута…';

  @override
  String get taxiComing => 'Ваше такси едет';

  @override
  String get tripInProgressShort => 'Поездка продолжается';

  @override
  String get matchedTaxiComing => 'Согласованное такси едет к вам';

  @override
  String get goingToDestination => 'Едете к пункту назначения';

  @override
  String get taxiGeneric => 'Такси';

  @override
  String get driverGeneric => 'Водитель';

  @override
  String get onlyYourTaxiOnMap => 'На карте только ваше такси';

  @override
  String get youAreHere => 'Вы здесь';

  @override
  String get pickupPoint => 'Точка посадки';

  @override
  String get yourTaxi => 'Ваше такси';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get vehicleMake => 'Марка';

  @override
  String get vehicleMakeHint => 'Напр. Toyota';

  @override
  String get vehicleModel => 'Модель';

  @override
  String get vehicleModelHint => 'Напр. Corolla';

  @override
  String get vehicleYear => 'Год модели';

  @override
  String get vehicleYearHint => 'Напр. 2020';

  @override
  String get vehicleColor => 'Цвет';

  @override
  String get vehicleColorHint => 'Напр. Белый';

  @override
  String get vehiclePlate => 'Номер';

  @override
  String get vehiclePlateHint => 'Напр. PG AB 01';

  @override
  String get returnToPassengerMode => 'Вернуться в режим пассажира';

  @override
  String get withdrawalRequest => 'Запрос на вывод';

  @override
  String get balanceLabel => 'Баланс';

  @override
  String get amount => 'Сумма';

  @override
  String get bank => 'Банк';

  @override
  String get ibanAccount => 'IBAN / Счёт';

  @override
  String get accountHolder => 'Владелец счёта';

  @override
  String get send => 'Отправить';

  @override
  String get withdrawalSubmitted => 'Запрос на вывод отправлен.';

  @override
  String get profileUpdated => 'Профиль обновлён';

  @override
  String get shareLinkCopied => 'Ссылка для обмена скопирована';

  @override
  String get homeLabel => 'Дом';

  @override
  String get savedLabel => 'Сохранено';

  @override
  String get dropoffShort => 'Назначение';

  @override
  String get taxiComingToYou => 'Ваше такси едет к вам';

  @override
  String get headingToDestination => 'Едете к пункту назначения…';

  @override
  String get boardOnlyThisVehicle => 'садитесь только в этот автомобиль';

  @override
  String pickupWithAddress(String address) {
    return 'Посадка: $address';
  }

  @override
  String get vehicleInfoTitle => 'Данные автомобиля';

  @override
  String get vehicleInfoSubtitle =>
      'Введите данные автомобиля и загрузите обязательные документы для режима такси.';

  @override
  String fieldRequired(String field) {
    return '$field обязательно';
  }

  @override
  String get validYearRequired => 'Введите корректный год';

  @override
  String get documentsUnderReviewHint =>
      'Режим такси откроется после проверки документов. Требуется одобрение администратора.';

  @override
  String get navHome => 'Главная';

  @override
  String get navHistory => 'История';

  @override
  String get navAccount => 'Аккаунт';

  @override
  String greetingMorning(String name) {
    return 'Доброе утро, $name, поехали!';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Добрый день, $name, поехали!';
  }

  @override
  String greetingEvening(String name) {
    return 'Добрый вечер, $name, поехали!';
  }

  @override
  String greetingNight(String name) {
    return 'Доброй ночи, $name, поехали!';
  }

  @override
  String get favoriteLocations => 'Избранные места';

  @override
  String get favoriteLocationsHint => 'Save important places for quick access';

  @override
  String get workLabel => 'Работа';

  @override
  String get othersLabel => 'Другие';

  @override
  String get tapToAddAddress => 'Tap to add address';

  @override
  String get addMoreFavorites => 'Add more';

  @override
  String get favoritesTip =>
      'Tip: Save addresses you visit often for faster booking.';

  @override
  String get selectFromMap => 'Выбрать на карте';

  @override
  String get searchPlace => 'Search place';

  @override
  String get searchRoute => 'Search route';

  @override
  String get arrivalAddress => 'Адрес назначения';

  @override
  String get productTaxi => 'Такси';

  @override
  String get productTransfer => 'Трансфер';

  @override
  String get vehicleVan => 'Van';

  @override
  String get addNote => 'Add note';

  @override
  String get coupon => 'Coupon';

  @override
  String get callTaxiGo => 'Вызвать TaxiGo';

  @override
  String get scheduleRide => 'Schedule';

  @override
  String get discoverYourDriver => 'Ищем водителя';

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
  String get historyCompleted => 'Завершено';

  @override
  String get historyUpcoming => 'Предстоящие';

  @override
  String get historyCancelled => 'Отменено';

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
  String get help => 'Помощь';

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
  String get password => 'Пароль';

  @override
  String get rolePassenger => 'Пассажир';

  @override
  String get roleDriver => 'Водитель';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String topUpConfirm(String amount, String currency) {
    return 'Пополнить кошелёк на $amount $currency?';
  }

  @override
  String get topUpSuccess => 'Кошелёк успешно пополнен.';

  @override
  String get topUpHint =>
      'Выберите сумму. Оплата доступна, когда Super Admin включит модуль.';

  @override
  String get topUpDisabled => 'Пополнение кошелька сейчас отключено.';

  @override
  String get withdrawDisabled => 'Выплаты водителям сейчас отключены.';

  @override
  String get withdrawCash => 'Вывести';

  @override
  String get maskedCall => 'Скрытый звонок';

  @override
  String get rideChat => 'Сообщение';

  @override
  String get rideChatHint => 'Короткое сообщение…';

  @override
  String get rideChatPrivacyHint =>
      'Только сообщения — номера остаются скрытыми.';

  @override
  String get maskedCallDialing => 'Соединение через скрытый номер…';

  @override
  String get maskedCallRequested =>
      'Запрос скрытого звонка отправлен. Другая сторона уведомлена.';

  @override
  String get chatTplWhereAreYou => 'Где вы?';

  @override
  String get chatTplImOutside => 'Я снаружи';

  @override
  String get chatTplAtTheDoor => 'У входа';

  @override
  String get chatTplLuggage => 'Есть багаж';

  @override
  String get chatTplRunningLate => 'Опоздаю на 2–3 мин';

  @override
  String get chatTplCantFind => 'Не могу найти';

  @override
  String get chatTplOk => 'Ок';

  @override
  String get chatTplOnMyWay => 'Уже еду';

  @override
  String get matchModeInstant => 'Вызвать TaxiGo';

  @override
  String get matchModeBidding => 'Ставка / Торг';

  @override
  String get matchModeInstantDesc =>
      'Ближайший свободный водитель назначается автоматически по фиксированной цене.';

  @override
  String get matchModeBiddingDesc =>
      'Водители могут предложить свою цену. Вы выбираете.';

  @override
  String get fixedPriceTransfer => 'Фиксированная цена трансфера';

  @override
  String get instantMatchHint =>
      'Фиксированная цена · ближайший водитель назначается сразу.';

  @override
  String get requestBids => 'Запросить ставки';

  @override
  String get yourOffer => 'Ваше предложение';

  @override
  String get rideAgain => 'Заказать снова';

  @override
  String get viewEReceipt => 'Электронный чек';

  @override
  String get eReceipt => 'Чек';

  @override
  String get eReceiptBadge => 'E-ЧЕК';

  @override
  String get shareReceipt => 'Поделиться чеком';

  @override
  String get receiptCopied => 'Чек скопирован.';

  @override
  String get receiptExpenseHint =>
      'Используйте этот чек для отеля, командировки или отчёта о расходах.';

  @override
  String get tripReference => 'Номер поездки';

  @override
  String get completedAt => 'Завершено';

  @override
  String get subtotal => 'Промежуточный итог';

  @override
  String get discount => 'Скидка';

  @override
  String get total => 'Итого';

  @override
  String get taxId => 'ИНН';
}
