import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../data/network/api_client.dart';
import '../data/network/api_endpoints.dart';
import '../data/network/api_exception.dart';

/// Client-side cache of Super Admin feature modules (`GET /modules`)
/// plus local overrides written by the in-app admin panel.
class FeatureModulesService {
  FeatureModulesService(this._apiClient, [this._prefs]);

  final ApiClient _apiClient;
  final SharedPreferences? _prefs;

  static const _overrideKey = 'taxigo_module_overrides_v1';

  Map<String, bool> _flags = const {};
  Map<String, bool> _overrides = {};
  DateTime? _fetchedAt;

  Map<String, bool> get flags => Map.unmodifiable({..._flags, ..._overrides});

  Future<void> hydrateOverrides() async {
    final raw = _prefs?.getString(_overrideKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _overrides = decoded.map(
          (k, v) => MapEntry(
            k.toString(),
            v == true || v == 1 || v == '1',
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> setOverride(String key, bool enabled) async {
    _overrides[key] = enabled;
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(_overrideKey, jsonEncode(_overrides));
    }
  }

  Future<void> clearOverrides() async {
    _overrides = {};
    await _prefs?.remove(_overrideKey);
  }

  bool enabled(String key, {bool fallback = true}) {
    if (_overrides.containsKey(key)) return _overrides[key]!;
    return _flags[key] ?? fallback;
  }

  /// Compile-time demo OR Super Admin “Demo” module toggle.
  bool get demoActive =>
      AppConstants.allowDemoMode || enabled('demo_login', fallback: false);

  bool get otpLogin => enabled('otp_login', fallback: true);
  bool get demoLogin => enabled('demo_login', fallback: false);
  bool get directionsFare => enabled('directions_fare');
  bool get placesAutocomplete => enabled('places_autocomplete');
  bool get rideSettlement => enabled('ride_settlement');
  bool get withdrawals => enabled('withdrawals', fallback: false);
  bool get walletTopUp => enabled('wallet_topup', fallback: false);
  bool get rtdbSync => enabled('rtdb_sync');
  bool get fcmDispatch => enabled('fcm_dispatch');
  bool get sosAlerts => enabled('sos_alerts');
  bool get shareTrip => enabled('share_trip');
  bool get rideComms => enabled('ride_comms', fallback: true);
  bool get rideReceipts => enabled('ride_receipts', fallback: true);
  bool get bidding => enabled('bidding');
  bool get cardPayments => enabled('card_payments', fallback: false);

  Future<Map<String, bool>> refresh({bool force = false}) async {
    await hydrateOverrides();
    if (!force &&
        _fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < const Duration(minutes: 2) &&
        _flags.isNotEmpty) {
      return flags;
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

    return flags;
  }
}
