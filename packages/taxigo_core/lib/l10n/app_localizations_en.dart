// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TaxiGo';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get chooseYourLanguage => 'Choose your language';

  @override
  String get languageSubtitle => 'You can change this later in settings';

  @override
  String get continueButton => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get welcomeTitle => 'Welcome to TaxiGo';

  @override
  String get welcomeSubtitle => 'Your ride, your way';

  @override
  String get onboardingTitle1 => 'Book a ride instantly';

  @override
  String get onboardingDesc1 =>
      'Find nearby drivers and get picked up in minutes';

  @override
  String get onboardingTitle2 => 'Track your trip live';

  @override
  String get onboardingDesc2 =>
      'See your driver approach in real-time on the map';

  @override
  String get onboardingTitle3 => 'Safe and secure';

  @override
  String get onboardingDesc3 =>
      'SOS button and trip sharing for your peace of mind';

  @override
  String get phoneLoginTitle => 'Enter your phone number';

  @override
  String get phoneLoginSubtitle =>
      'A verification code will appear in the app (no SMS)';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verifyOtpTitle => 'Verify OTP';

  @override
  String verifyOtpSubtitle(String phone) {
    return 'Enter the 6-digit code shown in the app for $phone';
  }

  @override
  String get otpCode => 'OTP Code';

  @override
  String get verify => 'Verify';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get profileSetupTitle => 'Complete your profile';

  @override
  String get fullName => 'Full name';

  @override
  String get email => 'Email (optional)';

  @override
  String get homeTitle => 'Where to?';

  @override
  String get currentLocation => 'Current location';

  @override
  String nearbyDrivers(int count) {
    return '$count drivers nearby';
  }

  @override
  String get searchDestination => 'Search destination';

  @override
  String get pickup => 'Pickup';

  @override
  String get dropoff => 'Drop-off';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get fareEstimate => 'Fare Estimate';

  @override
  String get distance => 'Distance';

  @override
  String get duration => 'Duration';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get vehicleStandard => 'Standard';

  @override
  String get vehicleComfort => 'Comfort';

  @override
  String get vehiclePremium => 'Premium';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentWallet => 'Wallet';

  @override
  String get paymentCard => 'Card';

  @override
  String get promoCode => 'Promo code';

  @override
  String get applyPromo => 'Apply';

  @override
  String get bookRide => 'Book Ride';

  @override
  String get rideStatusPending => 'Searching for driver...';

  @override
  String get rideStatusDriverAssigned => 'Driver assigned';

  @override
  String get rideStatusDriverArriving => 'Driver is on the way';

  @override
  String get rideStatusDriverArrived => 'Driver has arrived';

  @override
  String get rideStatusPassengerOnBoard => 'On board';

  @override
  String get rideStatusInProgress => 'Trip in progress';

  @override
  String get rideStatusCompleted => 'Trip completed';

  @override
  String get rideStatusCancelledPassenger => 'Cancelled by you';

  @override
  String get rideStatusCancelledDriver => 'Cancelled by driver';

  @override
  String get rideStatusExpired => 'Ride expired';

  @override
  String get cancelRide => 'Cancel Ride';

  @override
  String get rateDriver => 'Rate your driver';

  @override
  String get submitRating => 'Submit Rating';

  @override
  String get tripCompleted => 'Trip Completed';

  @override
  String get account => 'Account';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get wallet => 'Wallet';

  @override
  String get balance => 'Balance';

  @override
  String get topUp => 'Top Up';

  @override
  String get transactions => 'Transactions';

  @override
  String get tripHistory => 'Trip History';

  @override
  String get promos => 'Promo Codes';

  @override
  String get complaints => 'Complaints';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get sos => 'SOS';

  @override
  String get sosConfirm => 'Send emergency alert?';

  @override
  String get sosSent => 'Emergency alert sent';

  @override
  String get shareTrip => 'Share Trip';

  @override
  String get shareTripMessage => 'Track my TaxiGo trip';

  @override
  String get driverInfo => 'Driver Info';

  @override
  String get estimatedFare => 'Estimated fare';

  @override
  String get km => 'km';

  @override
  String get minutes => 'min';

  @override
  String get noActiveRide => 'No active ride';

  @override
  String get noTrips => 'No trips yet';

  @override
  String get complaintSubject => 'Subject';

  @override
  String get complaintDescription => 'Description';

  @override
  String get submitComplaint => 'Submit Complaint';

  @override
  String get enterPromoCode => 'Enter promo code';

  @override
  String get invalidPromo => 'Invalid promo code';

  @override
  String get promoApplied => 'Promo applied';

  @override
  String get appTitle => 'TaxiGo';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get loginWelcome => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in with your phone number';

  @override
  String get enterPhone => 'Enter phone number';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get confirm => 'Confirm';

  @override
  String get edit => 'Edit';

  @override
  String get language => 'Language';

  @override
  String get driverMode => 'Driver Mode';

  @override
  String get earnings => 'Earnings';

  @override
  String get rideHistory => 'Ride History';

  @override
  String get rateRide => 'Ratings';

  @override
  String get activeRide => 'Active Ride';

  @override
  String get pickupLocation => 'Pickup location';

  @override
  String get dropoffLocation => 'Drop-off location';

  @override
  String get mapTitle => 'Map';

  @override
  String get driverArrived => 'Mark Arrived';

  @override
  String get startTrip => 'Start Trip';

  @override
  String get completeTrip => 'Complete Trip';

  @override
  String get noResults => 'No results';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get pendingRides => 'New ride request';

  @override
  String get estimatedDistance => 'Estimated distance';

  @override
  String get rejectRide => 'Reject';

  @override
  String get acceptRide => 'Accept';

  @override
  String get uploadDocument => 'Upload document';

  @override
  String get approvalPending => 'Pending approval';

  @override
  String get approvalApproved => 'Approved';

  @override
  String get approvalRejected => 'Rejected';

  @override
  String get tryAgain => 'Try again';

  @override
  String get documentIdentity => 'Identity document';

  @override
  String get documentLicense => 'Driver license';

  @override
  String get documentRegistration => 'Vehicle registration';

  @override
  String get documentVehiclePhoto => 'Vehicle photo';

  @override
  String get goOnline => 'Go Online';

  @override
  String get goOffline => 'Go Offline';

  @override
  String get dailyEarnings => 'Today\'s earnings';

  @override
  String get weeklyEarnings => 'This week\'s earnings';

  @override
  String get onlineStatus => 'You are online';

  @override
  String get offlineStatus => 'You are offline';

  @override
  String get becomeDriver => 'I want to become a driver';

  @override
  String get switchToDriverMode => 'Switch to driver mode';

  @override
  String get switchToPassengerMode => 'Switch to passenger mode';

  @override
  String get driverApplicationPending =>
      'Your driver application is under review';

  @override
  String get driverApplicationRejected =>
      'Your driver application was rejected';

  @override
  String get viewApplicationStatus => 'View application status';

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

  @override
  String get locationUnavailableMapSelect =>
      'Location unavailable — select on the map';

  @override
  String get podgoricaMontenegro => 'Podgorica, Montenegro';

  @override
  String get saveAddress => 'Save address';

  @override
  String get addressLabelHint => 'Label (Home, Work...)';

  @override
  String get locating => 'Getting location...';

  @override
  String get refreshLocation => 'Refresh location';

  @override
  String get searchDestinationHintMe =>
      'Search in Montenegro (e.g. Budva, Kotor...)';

  @override
  String get searchPickupHintMe => 'Search pickup in Montenegro...';

  @override
  String get tapMapDropoff => 'Tap map: drop-off';

  @override
  String get tapMapPickup => 'Tap map: pickup';

  @override
  String get drawingRoute => 'Drawing route…';

  @override
  String get taxiComing => 'Your taxi is coming';

  @override
  String get tripInProgressShort => 'Trip in progress';

  @override
  String get matchedTaxiComing => 'Your matched taxi is coming to you';

  @override
  String get goingToDestination => 'Going to destination';

  @override
  String get taxiGeneric => 'Taxi';

  @override
  String get driverGeneric => 'Driver';

  @override
  String get onlyYourTaxiOnMap => 'Only your taxi is on the map';

  @override
  String get youAreHere => 'You are here';

  @override
  String get pickupPoint => 'Pickup point';

  @override
  String get yourTaxi => 'Your taxi';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get vehicleMake => 'Make';

  @override
  String get vehicleMakeHint => 'e.g. Toyota';

  @override
  String get vehicleModel => 'Model';

  @override
  String get vehicleModelHint => 'e.g. Corolla';

  @override
  String get vehicleYear => 'Model year';

  @override
  String get vehicleYearHint => 'e.g. 2020';

  @override
  String get vehicleColor => 'Color';

  @override
  String get vehicleColorHint => 'e.g. White';

  @override
  String get vehiclePlate => 'Plate';

  @override
  String get vehiclePlateHint => 'e.g. PG AB 01';

  @override
  String get returnToPassengerMode => 'Return to passenger mode';

  @override
  String get withdrawalRequest => 'Withdrawal request';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get amount => 'Amount';

  @override
  String get bank => 'Bank';

  @override
  String get ibanAccount => 'IBAN / Account';

  @override
  String get accountHolder => 'Account holder';

  @override
  String get send => 'Send';

  @override
  String get withdrawalSubmitted => 'Withdrawal request submitted.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get shareLinkCopied => 'Share link copied to clipboard';

  @override
  String get homeLabel => 'Home';

  @override
  String get savedLabel => 'Saved';

  @override
  String get dropoffShort => 'Drop-off';

  @override
  String get taxiComingToYou => 'Your taxi is coming to you';

  @override
  String get headingToDestination => 'Heading to destination…';

  @override
  String get boardOnlyThisVehicle => 'Board only this vehicle';

  @override
  String pickupWithAddress(String address) {
    return 'Pickup: $address';
  }

  @override
  String get vehicleInfoTitle => 'Vehicle details';

  @override
  String get vehicleInfoSubtitle =>
      'Enter vehicle details and upload required documents to switch to taxi mode.';

  @override
  String fieldRequired(String field) {
    return '$field is required';
  }

  @override
  String get validYearRequired => 'Enter a valid year';

  @override
  String get documentsUnderReviewHint =>
      'Taxi mode will open after your documents are reviewed. Admin approval is required.';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navAccount => 'Account';

  @override
  String greetingMorning(String name) {
    return 'Good morning $name, let\'s hit the road!';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon $name, let\'s hit the road!';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening $name, let\'s hit the road!';
  }

  @override
  String greetingNight(String name) {
    return 'Good night $name, let\'s hit the road!';
  }

  @override
  String get favoriteLocations => 'Favorite locations';

  @override
  String get favoriteLocationsHint => 'Save important places for quick access';

  @override
  String get workLabel => 'Work';

  @override
  String get othersLabel => 'Others';

  @override
  String get tapToAddAddress => 'Tap to add address';

  @override
  String get addMoreFavorites => 'Add more';

  @override
  String get favoritesTip =>
      'Tip: Save addresses you visit often for faster booking.';

  @override
  String get selectFromMap => 'Select from map';

  @override
  String get searchPlace => 'Search place';

  @override
  String get searchRoute => 'Search route';

  @override
  String get arrivalAddress => 'Destination address';

  @override
  String get productTaxi => 'Taxi';

  @override
  String get productTransfer => 'Transfer';

  @override
  String get vehicleVan => 'Van';

  @override
  String get addNote => 'Add note';

  @override
  String get coupon => 'Coupon';

  @override
  String get callTaxiGo => 'Call TaxiGo';

  @override
  String get scheduleRide => 'Schedule';

  @override
  String get discoverYourDriver => 'Discover your driver';

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
  String get historyCompleted => 'Completed';

  @override
  String get historyUpcoming => 'Upcoming';

  @override
  String get historyCancelled => 'Cancelled';

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
  String get help => 'Help';

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
  String get password => 'Password';

  @override
  String get rolePassenger => 'Passenger';

  @override
  String get roleDriver => 'Driver';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String topUpConfirm(String amount, String currency) {
    return 'Pay $amount $currency to top up your wallet?';
  }

  @override
  String get topUpSuccess => 'Wallet topped up successfully.';

  @override
  String get topUpHint =>
      'Choose an amount. Payment is processed securely when Super Admin enables top-up.';

  @override
  String get topUpDisabled =>
      'Wallet top-up is currently disabled. Ask Super Admin to enable the Wallet Top-Up module.';

  @override
  String get withdrawDisabled =>
      'Driver payouts are currently disabled. Ask Super Admin to enable Driver Payouts.';

  @override
  String get withdrawCash => 'Withdraw';

  @override
  String get maskedCall => 'Private call';

  @override
  String get rideChat => 'Message';

  @override
  String get rideChatHint => 'Short message…';

  @override
  String get rideChatPrivacyHint => 'Chat only — phone numbers stay private.';

  @override
  String get maskedCallDialing => 'Connecting via private number…';

  @override
  String get maskedCallRequested =>
      'Private call requested. The other party was notified.';

  @override
  String get chatTplWhereAreYou => 'Where are you?';

  @override
  String get chatTplImOutside => 'I\'m outside';

  @override
  String get chatTplAtTheDoor => 'At the door';

  @override
  String get chatTplLuggage => 'I have luggage';

  @override
  String get chatTplRunningLate => '2–3 min late';

  @override
  String get chatTplCantFind => 'Can\'t find you';

  @override
  String get chatTplOk => 'OK';

  @override
  String get chatTplOnMyWay => 'On my way';

  @override
  String get matchModeInstant => 'TaxiGo Call';

  @override
  String get matchModeBidding => 'Offer / Bids';

  @override
  String get matchModeInstantDesc =>
      'Nearest available driver is matched automatically at a fixed price.';

  @override
  String get matchModeBiddingDesc =>
      'Drivers can counter your offer. You pick the bid you like.';

  @override
  String get fixedPriceTransfer => 'Fixed transfer price';

  @override
  String get instantMatchHint =>
      'Fixed fare · nearest driver assigned instantly when available.';

  @override
  String get requestBids => 'Request bids';

  @override
  String get yourOffer => 'Your offer';

  @override
  String get rideAgain => 'Ride again';

  @override
  String get viewEReceipt => 'View e-receipt';

  @override
  String get eReceipt => 'E-receipt';

  @override
  String get eReceiptBadge => 'E-RECEIPT';

  @override
  String get shareReceipt => 'Share receipt';

  @override
  String get receiptCopied => 'Receipt copied to clipboard.';

  @override
  String get receiptExpenseHint =>
      'Use this e-receipt for hotels, business travel, or expense reports.';

  @override
  String get tripReference => 'Trip reference';

  @override
  String get completedAt => 'Completed';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get taxId => 'Tax ID';
}
