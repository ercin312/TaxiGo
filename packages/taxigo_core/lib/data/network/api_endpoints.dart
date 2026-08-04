/// REST API endpoint paths for the TaxiGo backend.
abstract final class ApiEndpoints {
  // Auth
  static const String requestOtp = '/auth/otp/request';
  static const String verifyOtp = '/auth/otp/verify';
  static const String demoLogin = '/auth/demo-login';
  static const String deviceRegister = '/devices/register';
  static const String firebaseVerify = '/auth/firebase-verify';
  static const String logout = '/auth/logout';

  // User
  static const String user = '/user';
  static const String userLocale = '/user/locale';

  // Driver
  static const String driverRegister = '/driver/register';
  static const String driverProfile = '/driver/profile';
  static const String driverDocuments = '/driver/documents';
  static const String driverOnline = '/driver/online';
  static const String driverOffline = '/driver/offline';
  static const String driverLocation = '/driver/location';

  // Rides (passenger)
  static const String ridesEta = '/rides/eta';
  static const String rides = '/rides';
  static const String ridesActive = '/rides/active';
  static const String ridesHistory = '/rides/history';

  static String ride(int id) => '/rides/$id';
  static String rideCancel(int id) => '/rides/$id/cancel';
  static String rideRate(int id) => '/rides/$id/rate';
  static String rideShare(int id) => '/rides/$id/share';
  static String rideBids(int id) => '/rides/$id/bids';
  static String rideOffer(int id) => '/rides/$id/offer';
  static String rideBidAccept(int rideId, int bidId) =>
      '/rides/$rideId/bids/$bidId/accept';
  static String rideBidReject(int rideId, int bidId) =>
      '/rides/$rideId/bids/$bidId/reject';

  // Rides (driver)
  static const String driverRidesPending = '/driver/rides/pending';
  static const String driverRidesActive = '/driver/rides/active';
  static const String driverRidesHistory = '/driver/rides/history';

  static String driverRideAccept(int id) => '/driver/rides/$id/accept';
  static String driverRideBid(int id) => '/driver/rides/$id/bid';
  static String driverRideReject(int id) => '/driver/rides/$id/reject';
  static String driverRideArrived(int id) => '/driver/rides/$id/arrived';
  static String driverRideStart(int id) => '/driver/rides/$id/start';
  static String driverRideComplete(int id) => '/driver/rides/$id/complete';
  static String driverRideCancel(int id) => '/driver/rides/$id/cancel';

  // Wallet
  static const String wallet = '/wallet';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletTopUp = '/wallet/top-up';
  static const String walletWithdrawals = '/wallet/withdrawals';

  // Maps
  static const String mapsDirections = '/maps/directions';
  static const String mapsPlaces = '/maps/places';
  static const String mapsPlaceDetails = '/maps/place-details';

  // Modules (super-admin toggles, public read)
  static const String modules = '/modules';

  // Promo
  static const String promoValidate = '/promo/validate';

  // Complaints
  static const String complaints = '/complaints';

  static String complaint(int id) => '/complaints/$id';

  // Safety
  static const String safetySos = '/safety/sos';
}
