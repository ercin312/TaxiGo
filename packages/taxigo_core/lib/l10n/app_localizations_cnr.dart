// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Montenegrin (`cnr`).
class AppLocalizationsCnr extends AppLocalizations {
  AppLocalizationsCnr([String locale = 'cnr']) : super(locale);

  @override
  String get appName => 'TaxiGo';

  @override
  String get selectLanguage => 'Izaberite jezik';

  @override
  String get chooseYourLanguage => 'Izaberite svoj jezik';

  @override
  String get languageSubtitle =>
      'Ovo možete kasnije promijeniti u podešavanjima';

  @override
  String get continueButton => 'Nastavi';

  @override
  String get skip => 'Preskoči';

  @override
  String get next => 'Dalje';

  @override
  String get getStarted => 'Započni';

  @override
  String get loading => 'Učitavanje...';

  @override
  String get error => 'Greška';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get cancel => 'Otkaži';

  @override
  String get save => 'Sačuvaj';

  @override
  String get ok => 'U redu';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Ne';

  @override
  String get welcomeTitle => 'Dobrodošli u TaxiGo';

  @override
  String get welcomeSubtitle => 'Vaša vožnja, na vaš način';

  @override
  String get onboardingTitle1 => 'Naručite vožnju odmah';

  @override
  String get onboardingDesc1 =>
      'Pronađite vozače u blizini i budite preuzeti za nekoliko minuta';

  @override
  String get onboardingTitle2 => 'Pratite vožnju uživo';

  @override
  String get onboardingDesc2 =>
      'Vidite kako vam se vozač približava na mapi u realnom vremenu';

  @override
  String get onboardingTitle3 => 'Bezbedno i pouzdano';

  @override
  String get onboardingDesc3 => 'SOS dugme i deljenje vožnje za vaš mir';

  @override
  String get phoneLoginTitle => 'Unesite broj telefona';

  @override
  String get phoneLoginSubtitle =>
      'Verifikacioni kod će se pojaviti u aplikaciji (bez SMS-a)';

  @override
  String get phoneNumber => 'Broj telefona';

  @override
  String get sendOtp => 'Pošalji kod';

  @override
  String get verifyOtpTitle => 'Potvrdite kod';

  @override
  String verifyOtpSubtitle(String phone) {
    return 'Unesite 6-cifreni kod prikazan u aplikaciji za $phone';
  }

  @override
  String get otpCode => 'Verifikacioni kod';

  @override
  String get verify => 'Potvrdi';

  @override
  String get resendOtp => 'Pošalji kod ponovo';

  @override
  String get profileSetupTitle => 'Dopunite profil';

  @override
  String get fullName => 'Ime i prezime';

  @override
  String get email => 'Email (opciono)';

  @override
  String get homeTitle => 'Kuda?';

  @override
  String get currentLocation => 'Trenutna lokacija';

  @override
  String nearbyDrivers(int count) {
    return '$count vozača u blizini';
  }

  @override
  String get searchDestination => 'Pretraži odredište';

  @override
  String get pickup => 'Preuzimanje';

  @override
  String get dropoff => 'Odredište';

  @override
  String get confirmBooking => 'Potvrdi rezervaciju';

  @override
  String get fareEstimate => 'Procjena cijene';

  @override
  String get distance => 'Udaljenost';

  @override
  String get duration => 'Trajanje';

  @override
  String get vehicleType => 'Tip vozila';

  @override
  String get vehicleStandard => 'Standard';

  @override
  String get vehicleComfort => 'Komfor';

  @override
  String get vehiclePremium => 'Premium';

  @override
  String get paymentMethod => 'Način plaćanja';

  @override
  String get paymentCash => 'Gotovina';

  @override
  String get paymentWallet => 'Novčanik';

  @override
  String get paymentCard => 'Kartica';

  @override
  String get promoCode => 'Promo kod';

  @override
  String get applyPromo => 'Primijeni';

  @override
  String get bookRide => 'Naruči vožnju';

  @override
  String get rideStatusPending => 'Traženje vozača...';

  @override
  String get rideStatusDriverAssigned => 'Vozač dodijeljen';

  @override
  String get rideStatusDriverArriving => 'Vozač je na putu';

  @override
  String get rideStatusDriverArrived => 'Vozač je stigao';

  @override
  String get rideStatusPassengerOnBoard => 'U vozilu';

  @override
  String get rideStatusInProgress => 'Vožnja u toku';

  @override
  String get rideStatusCompleted => 'Vožnja završena';

  @override
  String get rideStatusCancelledPassenger => 'Otkazano od vas';

  @override
  String get rideStatusCancelledDriver => 'Otkazano od vozača';

  @override
  String get rideStatusExpired => 'Vožnja istekla';

  @override
  String get cancelRide => 'Otkaži vožnju';

  @override
  String get rateDriver => 'Ocijenite vozača';

  @override
  String get submitRating => 'Pošalji ocjenu';

  @override
  String get tripCompleted => 'Vožnja završena';

  @override
  String get account => 'Nalog';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Uredi profil';

  @override
  String get wallet => 'Novčanik';

  @override
  String get balance => 'Stanje';

  @override
  String get topUp => 'Dopuni';

  @override
  String get transactions => 'Transakcije';

  @override
  String get tripHistory => 'Istorija vožnji';

  @override
  String get promos => 'Promo kodovi';

  @override
  String get complaints => 'Žalbe';

  @override
  String get settings => 'Podešavanja';

  @override
  String get logout => 'Odjava';

  @override
  String get sos => 'SOS';

  @override
  String get sosConfirm => 'Poslati hitni alarm?';

  @override
  String get sosSent => 'Hitni alarm poslat';

  @override
  String get shareTrip => 'Podijeli vožnju';

  @override
  String get shareTripMessage => 'Pratite moju TaxiGo vožnju';

  @override
  String get driverInfo => 'Informacije o vozaču';

  @override
  String get estimatedFare => 'Procijenjena cijena';

  @override
  String get km => 'km';

  @override
  String get minutes => 'min';

  @override
  String get noActiveRide => 'Nema aktivne vožnje';

  @override
  String get noTrips => 'Još nema vožnji';

  @override
  String get complaintSubject => 'Naslov';

  @override
  String get complaintDescription => 'Opis';

  @override
  String get submitComplaint => 'Pošalji žalbu';

  @override
  String get enterPromoCode => 'Unesite promo kod';

  @override
  String get invalidPromo => 'Nevažeći promo kod';

  @override
  String get promoApplied => 'Promo kod primijenjen';

  @override
  String get appTitle => 'TaxiGo';

  @override
  String get signIn => 'Prijava';

  @override
  String get signOut => 'Odjava';

  @override
  String get loginWelcome => 'Dobrodošli nazad';

  @override
  String get loginSubtitle => 'Prijavite se brojem telefona';

  @override
  String get enterPhone => 'Unesite broj telefona';

  @override
  String get verifyOtp => 'Potvrdi kod';

  @override
  String get confirm => 'Potvrdi';

  @override
  String get edit => 'Uredi';

  @override
  String get language => 'Jezik';

  @override
  String get driverMode => 'Režim vozača';

  @override
  String get earnings => 'Zarada';

  @override
  String get rideHistory => 'Istorija vožnji';

  @override
  String get rateRide => 'Ocjene';

  @override
  String get activeRide => 'Aktivna vožnja';

  @override
  String get pickupLocation => 'Lokacija preuzimanja';

  @override
  String get dropoffLocation => 'Lokacija odredišta';

  @override
  String get mapTitle => 'Mapa';

  @override
  String get driverArrived => 'Označi dolazak';

  @override
  String get startTrip => 'Započni vožnju';

  @override
  String get completeTrip => 'Završi vožnju';

  @override
  String get noResults => 'Nema rezultata';

  @override
  String get somethingWentWrong => 'Nešto nije u redu';

  @override
  String get pendingRides => 'Novi zahtjev za vožnju';

  @override
  String get estimatedDistance => 'Procijenjena udaljenost';

  @override
  String get rejectRide => 'Odbij';

  @override
  String get acceptRide => 'Prihvati';

  @override
  String get uploadDocument => 'Otpremi dokument';

  @override
  String get approvalPending => 'Čeka odobrenje';

  @override
  String get approvalApproved => 'Odobreno';

  @override
  String get approvalRejected => 'Odbijeno';

  @override
  String get tryAgain => 'Pokušaj ponovo';

  @override
  String get documentIdentity => 'Lični dokument';

  @override
  String get documentLicense => 'Vozačka dozvola';

  @override
  String get documentRegistration => 'Saobraćajna dozvola';

  @override
  String get documentVehiclePhoto => 'Fotografija vozila';

  @override
  String get goOnline => 'Uključi se';

  @override
  String get goOffline => 'Isključi se';

  @override
  String get dailyEarnings => 'Današnja zarada';

  @override
  String get weeklyEarnings => 'Sedmična zarada';

  @override
  String get onlineStatus => 'Na mreži ste';

  @override
  String get offlineStatus => 'Niste na mreži';

  @override
  String get becomeDriver => 'Želim da postanem vozač';

  @override
  String get switchToDriverMode => 'Pređi u režim vozača';

  @override
  String get switchToPassengerMode => 'Pređi u režim putnika';

  @override
  String get driverApplicationPending =>
      'Vaša prijava za vozača je na pregledu';

  @override
  String get driverApplicationRejected => 'Vaša prijava za vozača je odbijena';

  @override
  String get viewApplicationStatus => 'Pogledaj status prijave';

  @override
  String get otpInAppTitle => 'Vaš verifikacioni kod';

  @override
  String get otpInAppHint => 'Dodirnite kod da se automatski popuni.';

  @override
  String get otpNotificationTitle => 'TaxiGo verifikacija';

  @override
  String otpNotificationBody(String code) {
    return 'Vaš kod za prijavu: $code';
  }

  @override
  String get otpNotificationSent =>
      'Verifikacioni kod poslat kao obavještenje.';

  @override
  String get offerYourFare => 'Ponudite cijenu';

  @override
  String get recommendedFareMinimum => 'Preporučena minimalna cijena';

  @override
  String get createRequest => 'Kreiraj zahtjev';

  @override
  String get lookingForDrivers => 'Traženje vozača u blizini';

  @override
  String get availableDrivers => 'Dostupni vozači';

  @override
  String get updateOffer => 'Ažuriraj ponudu';

  @override
  String get currentFare => 'Trenutna cijena';

  @override
  String get offeredFare => 'Ponuđena cijena';

  @override
  String get acceptBid => 'Prihvati';

  @override
  String get rejectBid => 'Odbij';

  @override
  String get counterBid => 'Kontra ponuda';

  @override
  String get bidSubmitted =>
      'Vaša ponuda je poslata. Čeka se odobrenje putnika.';

  @override
  String get passengerOffer => 'Ponuda putnika';

  @override
  String get noBidsYet =>
      'Još nema ponuda vozača. Možete povećati svoju ponudu.';

  @override
  String secondsLeft(int seconds) {
    return 'Preostalo ${seconds}s';
  }

  @override
  String get locationUnavailableMapSelect =>
      'Lokacija nije dostupna — izaberite na mapi';

  @override
  String get podgoricaMontenegro => 'Podgorica, Crna Gora';

  @override
  String get saveAddress => 'Sačuvaj adresu';

  @override
  String get addressLabelHint => 'Oznaka (Kuća, Posao...)';

  @override
  String get locating => 'Lociranje...';

  @override
  String get refreshLocation => 'Osveži lokaciju';

  @override
  String get searchDestinationHintMe =>
      'Pretraži u Crnoj Gori (npr. Budva, Kotor...)';

  @override
  String get searchPickupHintMe => 'Pretraži preuzimanje u Crnoj Gori...';

  @override
  String get tapMapDropoff => 'Dodirnite mapu: odredište';

  @override
  String get tapMapPickup => 'Dodirnite mapu: preuzimanje';

  @override
  String get drawingRoute => 'Crtanje rute…';

  @override
  String get taxiComing => 'Vaš taksi stiže';

  @override
  String get tripInProgressShort => 'Vožnja u toku';

  @override
  String get matchedTaxiComing => 'Dogovoreni taksi vam stiže';

  @override
  String get goingToDestination => 'Idete ka odredištu';

  @override
  String get taxiGeneric => 'Taksi';

  @override
  String get driverGeneric => 'Vozač';

  @override
  String get onlyYourTaxiOnMap => 'Samo vaš taksi je na mapi';

  @override
  String get youAreHere => 'Vi ste ovdje';

  @override
  String get pickupPoint => 'Tačka preuzimanja';

  @override
  String get yourTaxi => 'Vaš taksi';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galerija';

  @override
  String get vehicleMake => 'Marka';

  @override
  String get vehicleMakeHint => 'Npr. Toyota';

  @override
  String get vehicleModel => 'Model';

  @override
  String get vehicleModelHint => 'Npr. Corolla';

  @override
  String get vehicleYear => 'Godina modela';

  @override
  String get vehicleYearHint => 'Npr. 2020';

  @override
  String get vehicleColor => 'Boja';

  @override
  String get vehicleColorHint => 'Npr. Bijela';

  @override
  String get vehiclePlate => 'Tablica';

  @override
  String get vehiclePlateHint => 'Npr. PG AB 01';

  @override
  String get returnToPassengerMode => 'Nazad u režim putnika';

  @override
  String get withdrawalRequest => 'Zahtjev za isplatu';

  @override
  String get balanceLabel => 'Stanje';

  @override
  String get amount => 'Iznos';

  @override
  String get bank => 'Banka';

  @override
  String get ibanAccount => 'IBAN / Račun';

  @override
  String get accountHolder => 'Vlasnik računa';

  @override
  String get send => 'Pošalji';

  @override
  String get withdrawalSubmitted => 'Zahtjev za isplatu poslat.';

  @override
  String get profileUpdated => 'Profil ažuriran';

  @override
  String get shareLinkCopied => 'Link za dijeljenje kopiran u clipboard';

  @override
  String get homeLabel => 'Kuća';

  @override
  String get savedLabel => 'Sačuvano';

  @override
  String get dropoffShort => 'Odredište';

  @override
  String get taxiComingToYou => 'Vaš taksi vam stiže';

  @override
  String get headingToDestination => 'Idete ka odredištu…';

  @override
  String get boardOnlyThisVehicle => 'uđite samo u ovo vozilo';

  @override
  String pickupWithAddress(String address) {
    return 'Preuzimanje: $address';
  }

  @override
  String get vehicleInfoTitle => 'Podaci o vozilu';

  @override
  String get vehicleInfoSubtitle =>
      'Unesite podatke o vozilu i otpremite obavezne dokumente da pređete u režim taksija.';

  @override
  String fieldRequired(String field) {
    return '$field je obavezno';
  }

  @override
  String get validYearRequired => 'Unesite važeću godinu';

  @override
  String get documentsUnderReviewHint =>
      'Režim taksija će se otvoriti nakon pregleda dokumenata. Potrebno je odobrenje administratora.';

  @override
  String get navHome => 'Početna';

  @override
  String get navHistory => 'Istorija';

  @override
  String get navAccount => 'Nalog';

  @override
  String greetingMorning(String name) {
    return 'Dobro jutro $name, krenimo!';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Dobar dan $name, krenimo!';
  }

  @override
  String greetingEvening(String name) {
    return 'Dobro veče $name, krenimo!';
  }

  @override
  String greetingNight(String name) {
    return 'Laku noć $name, krenimo!';
  }

  @override
  String get favoriteLocations => 'Omiljene lokacije';

  @override
  String get favoriteLocationsHint => 'Save important places for quick access';

  @override
  String get workLabel => 'Posao';

  @override
  String get othersLabel => 'Ostalo';

  @override
  String get tapToAddAddress => 'Tap to add address';

  @override
  String get addMoreFavorites => 'Add more';

  @override
  String get favoritesTip =>
      'Tip: Save addresses you visit often for faster booking.';

  @override
  String get selectFromMap => 'Izaberi sa mape';

  @override
  String get searchPlace => 'Search place';

  @override
  String get searchRoute => 'Search route';

  @override
  String get arrivalAddress => 'Adresa odredišta';

  @override
  String get productTaxi => 'Taksi';

  @override
  String get productTransfer => 'Transfer';

  @override
  String get vehicleVan => 'Van';

  @override
  String get addNote => 'Add note';

  @override
  String get coupon => 'Coupon';

  @override
  String get callTaxiGo => 'Pozovi TaxiGo';

  @override
  String get scheduleRide => 'Schedule';

  @override
  String get discoverYourDriver => 'Pronađite vozača';

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
  String get historyCompleted => 'Završeno';

  @override
  String get historyUpcoming => 'Predstojeće';

  @override
  String get historyCancelled => 'Otkazano';

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
  String get accountSection => 'Vaš nalog';

  @override
  String get accountSectionHint => 'Manage profile and settings';

  @override
  String get activitySection => 'Aktivnost';

  @override
  String get activitySectionHint => 'Track activity and history';

  @override
  String get settingsSection => 'Podešavanja';

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
  String get help => 'Pomoć';

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
  String get password => 'Lozinka';

  @override
  String get rolePassenger => 'Putnik';

  @override
  String get roleDriver => 'Vozač';

  @override
  String get continueWithGoogle => 'Nastavi sa Google';

  @override
  String topUpConfirm(String amount, String currency) {
    return 'Dopuniti novčanik sa $amount $currency?';
  }

  @override
  String get topUpSuccess => 'Novčanik je uspješno dopunjen.';

  @override
  String get topUpHint =>
      'Izaberite iznos. Plaćanje se obrađuje kada Super Admin omogući dopunu.';

  @override
  String get topUpDisabled => 'Dopuna novčanika je trenutno isključena.';

  @override
  String get withdrawDisabled => 'Isplate vozačima su trenutno isključene.';

  @override
  String get withdrawCash => 'Isplata';

  @override
  String get maskedCall => 'Privatni poziv';

  @override
  String get rideChat => 'Poruka';

  @override
  String get rideChatHint => 'Kratka poruka…';

  @override
  String get rideChatPrivacyHint =>
      'Brojevi ostaju privatni. Koristite brze odgovore ili kratku bilješku.';

  @override
  String get maskedCallDialing => 'Povezivanje preko privatnog broja…';

  @override
  String get maskedCallRequested =>
      'Privatni poziv zatražen. Druga strana je obaviještena.';

  @override
  String get chatTplWhereAreYou => 'Gdje si?';

  @override
  String get chatTplImOutside => 'Napolju sam';

  @override
  String get chatTplAtTheDoor => 'Kod ulaza';

  @override
  String get chatTplLuggage => 'Imam prtljag';

  @override
  String get chatTplRunningLate => 'Kasnim 2–3 min';

  @override
  String get chatTplCantFind => 'Ne mogu te naći';

  @override
  String get chatTplOk => 'U redu';

  @override
  String get chatTplOnMyWay => 'Na putu sam';

  @override
  String get matchModeInstant => 'Pozovi TaxiGo';

  @override
  String get matchModeBidding => 'Ponuda / Licitacija';

  @override
  String get matchModeInstantDesc =>
      'Najbliži slobodni vozač se automatski dodjeljuje po fiksnoj cijeni.';

  @override
  String get matchModeBiddingDesc =>
      'Vozači mogu dati kontra-ponudu. Vi birate.';

  @override
  String get fixedPriceTransfer => 'Fiksna cijena transfera';

  @override
  String get instantMatchHint =>
      'Fiksna cijena · najbliži vozač se dodjeljuje odmah kad je dostupan.';

  @override
  String get requestBids => 'Zatraži ponude';

  @override
  String get yourOffer => 'Vaša ponuda';

  @override
  String get rideAgain => 'Ponovo naruči';

  @override
  String get viewEReceipt => 'Pogledaj e-račun';

  @override
  String get eReceipt => 'E-račun';

  @override
  String get eReceiptBadge => 'E-RAČUN';

  @override
  String get shareReceipt => 'Podijeli račun';

  @override
  String get receiptCopied => 'Račun je kopiran.';

  @override
  String get receiptExpenseHint =>
      'Koristite ovaj e-račun za hotel, poslovno putovanje ili troškove.';

  @override
  String get tripReference => 'Referenca vožnje';

  @override
  String get completedAt => 'Završeno';

  @override
  String get subtotal => 'Međuzbir';

  @override
  String get discount => 'Popust';

  @override
  String get total => 'Ukupno';

  @override
  String get taxId => 'PIB';
}
