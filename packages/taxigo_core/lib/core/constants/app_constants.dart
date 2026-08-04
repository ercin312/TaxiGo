/// TaxiGo application-wide constants.
abstract final class AppConstants {
  static const String baseUrl = String.fromEnvironment(
    'TAXIGO_API_BASE_URL',
    defaultValue: 'https://api.taxigo.app/api/v1',
  );

  static const String appName = 'TaxiGo';
  static const String defaultLocale = 'tr';
  static const String currency = 'TRY';

  /// Same key as Android Maps SDK — used for Directions when backend is offline.
  static const String googleMapsApiKey = String.fromEnvironment(
    'TAXIGO_GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyD1QL3kylmRytiOVqKbMfXow4bssNjsDOE',
  );

  // SharedPreferences keys
  static const String localeKey = 'app_locale';
  static const String authTokenKey = 'auth_token';

  // Firebase Realtime Database paths
  static const String rtdbRidesPath = 'rides';
  static const String rtdbDriversPath = 'drivers';

  static String driverPath(int driverId) => '$rtdbDriversPath/$driverId';

  static String driverLocationPath(int driverId) =>
      '${driverPath(driverId)}/location';

  static String ridePath(int rideId) => '$rtdbRidesPath/$rideId';

  // Wallet limits
  static const double minTopUp = 5.0;
  static const double minWithdrawal = 20.0;

  // Ride matching
  static const double matchingRadiusKm = 5.0;
  static const int rideExpiryMinutes = 15;
}
