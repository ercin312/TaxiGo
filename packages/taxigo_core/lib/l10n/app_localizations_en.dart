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
}
