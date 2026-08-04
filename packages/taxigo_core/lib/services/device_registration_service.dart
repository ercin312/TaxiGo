import 'dart:io';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/network/api_client.dart';
import '../data/network/api_endpoints.dart';
import '../firebase/fcm_service.dart';

/// Registers device FCM token with the backend before and during login.
class DeviceRegistrationService {
  DeviceRegistrationService({
    required ApiClient apiClient,
    required FcmService fcmService,
    required SharedPreferences prefs,
  })  : _apiClient = apiClient,
        _fcmService = fcmService,
        _prefs = prefs;

  static const _deviceIdKey = 'taxigo_device_id';

  final ApiClient _apiClient;
  final FcmService _fcmService;
  final SharedPreferences _prefs;

  Future<String> getDeviceId() async {
    final existing = _prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final id =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999999)}';
    await _prefs.setString(_deviceIdKey, id);
    return id;
  }

  Future<void> register({String? phone}) async {
    final token = await _fcmService.refreshToken();
    if (token == null || token.isEmpty) return;

    final deviceId = await getDeviceId();

    try {
      await _apiClient.post(
        ApiEndpoints.deviceRegister,
        data: {
          'device_id': deviceId,
          'fcm_token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
    } catch (_) {
      // Non-fatal: OTP request also sends token.
    }
  }

  Future<Map<String, String?>> registrationPayload({String? phone}) async {
    final token = await _fcmService.refreshToken();
    final deviceId = await getDeviceId();

    return {
      'fcm_token': token,
      'device_id': deviceId,
      'platform': Platform.isIOS ? 'ios' : 'android',
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };
  }
}
