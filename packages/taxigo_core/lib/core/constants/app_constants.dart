import 'dart:math' as math;

/// TaxiGo application-wide constants.
abstract final class AppConstants {
  static const String baseUrl = String.fromEnvironment(
    'TAXIGO_API_BASE_URL',
    defaultValue: 'https://alanyaproje.com/taxigo/v1',
  );

  /// Offline demo / fake fleet / auto-match. Store builds must keep this false.
  static const bool allowDemoMode = bool.fromEnvironment(
    'TAXIGO_ALLOW_DEMO',
    defaultValue: false,
  );

  static const String appName = 'TaxiGo';
  static const String defaultLocale = 'tr';
  static const String currency = 'EUR';

  /// Operating region: Montenegro (Crna Gora).
  static const String serviceCountryCode = 'me';
  static const String serviceCountryName = 'Montenegro';

  /// Default map center — Podgorica.
  static const double defaultLatitude = 42.4304;
  static const double defaultLongitude = 19.2594;
  static const double defaultMapZoom = 12;

  /// Bias radius for Places autocomplete (~covers Montenegro).
  static const int placesSearchRadiusMeters = 150000;

  /// Service-area radius from Podgorica center (~covers Montenegro).
  static const double serviceAreaRadiusKm = 160;

  /// Quick-jump airports inside the service area.
  static const double podgoricaAirportLat = 42.3594;
  static const double podgoricaAirportLng = 19.2519;
  static const String podgoricaAirportLabel = 'Podgorica Airport (TGD)';

  static const double tivatAirportLat = 42.4047;
  static const double tivatAirportLng = 18.7233;
  static const String tivatAirportLabel = 'Tivat Airport (TIV)';

  /// Haversine distance in km.
  static double distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earth = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earth * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static bool isInsideServiceArea(double lat, double lng) {
    return distanceKm(
          lat,
          lng,
          defaultLatitude,
          defaultLongitude,
        ) <=
        serviceAreaRadiusKm;
  }

  static double _toRad(double deg) => deg * math.pi / 180;

  /// Same key as Android Maps SDK — used for Directions / Places when backend is offline.
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
