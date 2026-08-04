import '../data/network/api_client.dart';
import '../data/network/api_endpoints.dart';
import '../data/network/api_exception.dart';

/// Client-side cache of Super Admin feature modules (`GET /modules`).
class FeatureModulesService {
  FeatureModulesService(this._apiClient);

  final ApiClient _apiClient;

  Map<String, bool> _flags = const {};
  DateTime? _fetchedAt;

  Map<String, bool> get flags => _flags;

  bool enabled(String key, {bool fallback = true}) =>
      _flags[key] ?? fallback;

  bool get otpLogin => enabled('otp_login', fallback: false);
  bool get demoLogin => enabled('demo_login', fallback: true);
  bool get directionsFare => enabled('directions_fare');
  bool get placesAutocomplete => enabled('places_autocomplete');
  bool get rideSettlement => enabled('ride_settlement');
  bool get withdrawals => enabled('withdrawals');
  bool get rtdbSync => enabled('rtdb_sync');
  bool get fcmDispatch => enabled('fcm_dispatch');
  bool get sosAlerts => enabled('sos_alerts');
  bool get shareTrip => enabled('share_trip');
  bool get bidding => enabled('bidding');
  bool get cardPayments => enabled('card_payments');

  Future<Map<String, bool>> refresh({bool force = false}) async {
    if (!force &&
        _fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < const Duration(minutes: 2) &&
        _flags.isNotEmpty) {
      return _flags;
    }

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.modules,
      );
      final raw = response.data?['modules'];
      if (raw is Map) {
        _flags = raw.map(
          (key, value) => MapEntry(
            key.toString(),
            value == true || value == 1 || value == '1',
          ),
        );
      }
      _fetchedAt = DateTime.now();
    } on ApiException {
      // Keep last known / empty flags; UI falls back to enabled.
    } catch (_) {}

    return _flags;
  }
}
