import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_xh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
    Locale('xh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'TaxiGo'**
  String get appName;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in settings'**
  String get languageSubtitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TaxiGo'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your ride, your way'**
  String get welcomeSubtitle;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Book a ride instantly'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Find nearby drivers and get picked up in minutes'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track your trip live'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'See your driver approach in real-time on the map'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Safe and secure'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'SOS button and trip sharing for your peace of mind'**
  String get onboardingDesc3;

  /// No description provided for @phoneLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneLoginTitle;

  /// No description provided for @phoneLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A verification code will appear in the app (no SMS)'**
  String get phoneLoginSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpTitle;

  /// No description provided for @verifyOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code shown in the app for {phone}'**
  String verifyOtpSubtitle(String phone);

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get profileSetupTitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get email;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get homeTitle;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @nearbyDrivers.
  ///
  /// In en, this message translates to:
  /// **'{count} drivers nearby'**
  String nearbyDrivers(int count);

  /// No description provided for @searchDestination.
  ///
  /// In en, this message translates to:
  /// **'Search destination'**
  String get searchDestination;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @dropoff.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get dropoff;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @fareEstimate.
  ///
  /// In en, this message translates to:
  /// **'Fare Estimate'**
  String get fareEstimate;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @vehicleStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get vehicleStandard;

  /// No description provided for @vehicleComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get vehicleComfort;

  /// No description provided for @vehiclePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get vehiclePremium;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get paymentWallet;

  /// No description provided for @paymentCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentCard;

  /// No description provided for @promoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get promoCode;

  /// No description provided for @applyPromo.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyPromo;

  /// No description provided for @bookRide.
  ///
  /// In en, this message translates to:
  /// **'Book Ride'**
  String get bookRide;

  /// No description provided for @rideStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Searching for driver...'**
  String get rideStatusPending;

  /// No description provided for @rideStatusDriverAssigned.
  ///
  /// In en, this message translates to:
  /// **'Driver assigned'**
  String get rideStatusDriverAssigned;

  /// No description provided for @rideStatusDriverArriving.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the way'**
  String get rideStatusDriverArriving;

  /// No description provided for @rideStatusDriverArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get rideStatusDriverArrived;

  /// No description provided for @rideStatusPassengerOnBoard.
  ///
  /// In en, this message translates to:
  /// **'On board'**
  String get rideStatusPassengerOnBoard;

  /// No description provided for @rideStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get rideStatusInProgress;

  /// No description provided for @rideStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get rideStatusCompleted;

  /// No description provided for @rideStatusCancelledPassenger.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by you'**
  String get rideStatusCancelledPassenger;

  /// No description provided for @rideStatusCancelledDriver.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by driver'**
  String get rideStatusCancelledDriver;

  /// No description provided for @rideStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Ride expired'**
  String get rideStatusExpired;

  /// No description provided for @cancelRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancelRide;

  /// No description provided for @rateDriver.
  ///
  /// In en, this message translates to:
  /// **'Rate your driver'**
  String get rateDriver;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRating;

  /// No description provided for @tripCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed'**
  String get tripCompleted;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @tripHistory.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get tripHistory;

  /// No description provided for @promos.
  ///
  /// In en, this message translates to:
  /// **'Promo Codes'**
  String get promos;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @sosConfirm.
  ///
  /// In en, this message translates to:
  /// **'Send emergency alert?'**
  String get sosConfirm;

  /// No description provided for @sosSent.
  ///
  /// In en, this message translates to:
  /// **'Emergency alert sent'**
  String get sosSent;

  /// No description provided for @shareTrip.
  ///
  /// In en, this message translates to:
  /// **'Share Trip'**
  String get shareTrip;

  /// No description provided for @shareTripMessage.
  ///
  /// In en, this message translates to:
  /// **'Track my TaxiGo trip'**
  String get shareTripMessage;

  /// No description provided for @driverInfo.
  ///
  /// In en, this message translates to:
  /// **'Driver Info'**
  String get driverInfo;

  /// No description provided for @estimatedFare.
  ///
  /// In en, this message translates to:
  /// **'Estimated fare'**
  String get estimatedFare;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @noActiveRide.
  ///
  /// In en, this message translates to:
  /// **'No active ride'**
  String get noActiveRide;

  /// No description provided for @noTrips.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get noTrips;

  /// No description provided for @complaintSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get complaintSubject;

  /// No description provided for @complaintDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get complaintDescription;

  /// No description provided for @submitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get submitComplaint;

  /// No description provided for @enterPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Enter promo code'**
  String get enterPromoCode;

  /// No description provided for @invalidPromo.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo code'**
  String get invalidPromo;

  /// No description provided for @promoApplied.
  ///
  /// In en, this message translates to:
  /// **'Promo applied'**
  String get promoApplied;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TaxiGo'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone number'**
  String get loginSubtitle;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhone;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @driverMode.
  ///
  /// In en, this message translates to:
  /// **'Driver Mode'**
  String get driverMode;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @rideHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get rideHistory;

  /// No description provided for @rateRide.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get rateRide;

  /// No description provided for @activeRide.
  ///
  /// In en, this message translates to:
  /// **'Active Ride'**
  String get activeRide;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get pickupLocation;

  /// No description provided for @dropoffLocation.
  ///
  /// In en, this message translates to:
  /// **'Drop-off location'**
  String get dropoffLocation;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @driverArrived.
  ///
  /// In en, this message translates to:
  /// **'Mark Arrived'**
  String get driverArrived;

  /// No description provided for @startTrip.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get startTrip;

  /// No description provided for @completeTrip.
  ///
  /// In en, this message translates to:
  /// **'Complete Trip'**
  String get completeTrip;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @pendingRides.
  ///
  /// In en, this message translates to:
  /// **'New ride request'**
  String get pendingRides;

  /// No description provided for @estimatedDistance.
  ///
  /// In en, this message translates to:
  /// **'Estimated distance'**
  String get estimatedDistance;

  /// No description provided for @rejectRide.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectRide;

  /// No description provided for @acceptRide.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptRide;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload document'**
  String get uploadDocument;

  /// No description provided for @approvalPending.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get approvalPending;

  /// No description provided for @approvalApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvalApproved;

  /// No description provided for @approvalRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get approvalRejected;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @documentIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity document'**
  String get documentIdentity;

  /// No description provided for @documentLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver license'**
  String get documentLicense;

  /// No description provided for @documentRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration'**
  String get documentRegistration;

  /// No description provided for @documentVehiclePhoto.
  ///
  /// In en, this message translates to:
  /// **'Vehicle photo'**
  String get documentVehiclePhoto;

  /// No description provided for @goOnline.
  ///
  /// In en, this message translates to:
  /// **'Go Online'**
  String get goOnline;

  /// No description provided for @goOffline.
  ///
  /// In en, this message translates to:
  /// **'Go Offline'**
  String get goOffline;

  /// No description provided for @dailyEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s earnings'**
  String get dailyEarnings;

  /// No description provided for @weeklyEarnings.
  ///
  /// In en, this message translates to:
  /// **'This week\'s earnings'**
  String get weeklyEarnings;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'You are online'**
  String get onlineStatus;

  /// No description provided for @offlineStatus.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get offlineStatus;

  /// No description provided for @becomeDriver.
  ///
  /// In en, this message translates to:
  /// **'I want to become a driver'**
  String get becomeDriver;

  /// No description provided for @switchToDriverMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to driver mode'**
  String get switchToDriverMode;

  /// No description provided for @switchToPassengerMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to passenger mode'**
  String get switchToPassengerMode;

  /// No description provided for @driverApplicationPending.
  ///
  /// In en, this message translates to:
  /// **'Your driver application is under review'**
  String get driverApplicationPending;

  /// No description provided for @driverApplicationRejected.
  ///
  /// In en, this message translates to:
  /// **'Your driver application was rejected'**
  String get driverApplicationRejected;

  /// No description provided for @viewApplicationStatus.
  ///
  /// In en, this message translates to:
  /// **'View application status'**
  String get viewApplicationStatus;

  /// No description provided for @otpInAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Your verification code'**
  String get otpInAppTitle;

  /// No description provided for @otpInAppHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the code to fill automatically.'**
  String get otpInAppHint;

  /// No description provided for @otpNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'TaxiGo Verification'**
  String get otpNotificationTitle;

  /// No description provided for @otpNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your login code: {code}'**
  String otpNotificationBody(String code);

  /// No description provided for @otpNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent as a notification.'**
  String get otpNotificationSent;

  /// No description provided for @offerYourFare.
  ///
  /// In en, this message translates to:
  /// **'Offer Your Fare'**
  String get offerYourFare;

  /// No description provided for @recommendedFareMinimum.
  ///
  /// In en, this message translates to:
  /// **'Recommended minimum fare'**
  String get recommendedFareMinimum;

  /// No description provided for @createRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get createRequest;

  /// No description provided for @lookingForDrivers.
  ///
  /// In en, this message translates to:
  /// **'Looking for nearby drivers'**
  String get lookingForDrivers;

  /// No description provided for @availableDrivers.
  ///
  /// In en, this message translates to:
  /// **'Available drivers'**
  String get availableDrivers;

  /// No description provided for @updateOffer.
  ///
  /// In en, this message translates to:
  /// **'Update Offer'**
  String get updateOffer;

  /// No description provided for @currentFare.
  ///
  /// In en, this message translates to:
  /// **'Current fare'**
  String get currentFare;

  /// No description provided for @offeredFare.
  ///
  /// In en, this message translates to:
  /// **'Offered fare'**
  String get offeredFare;

  /// No description provided for @acceptBid.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptBid;

  /// No description provided for @rejectBid.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectBid;

  /// No description provided for @counterBid.
  ///
  /// In en, this message translates to:
  /// **'Counter Offer'**
  String get counterBid;

  /// No description provided for @bidSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your bid was sent. Waiting for passenger approval.'**
  String get bidSubmitted;

  /// No description provided for @passengerOffer.
  ///
  /// In en, this message translates to:
  /// **'Passenger offer'**
  String get passengerOffer;

  /// No description provided for @noBidsYet.
  ///
  /// In en, this message translates to:
  /// **'No driver bids yet. You can increase your offer.'**
  String get noBidsYet;

  /// No description provided for @secondsLeft.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s left'**
  String secondsLeft(int seconds);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ru', 'tr', 'xh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'xh':
      return AppLocalizationsXh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
