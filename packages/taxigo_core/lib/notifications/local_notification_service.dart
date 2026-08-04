import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Device notifications for TaxiGo (OTP delivery, ride updates).
class LocalNotificationService {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _otpChannel = AndroidNotificationChannel(
    'taxigo_otp',
    'Doğrulama Kodları',
    description: 'TaxiGo giriş doğrulama kodları',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(_otpChannel);
      await android?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  Future<void> showOtpCode(
    String code, {
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'taxigo_otp',
      'Doğrulama Kodları',
      channelDescription: 'TaxiGo giriş doğrulama kodları',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'TaxiGo doğrulama kodu',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      code.hashCode,
      title,
      body,
      details,
      payload: code,
    );
  }
}
