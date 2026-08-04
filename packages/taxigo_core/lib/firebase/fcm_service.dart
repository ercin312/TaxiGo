import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../notifications/otp_inbox_service.dart';
import 'firebase_service.dart';

const _pendingOtpKey = 'taxigo_pending_otp_code';

/// Broadcasts incoming ride request IDs from FCM to driver UI.
class RideRequestInbox {
  RideRequestInbox._();
  static final RideRequestInbox instance = RideRequestInbox._();

  final _controller = StreamController<int>.broadcast();

  Stream<int> get stream => _controller.stream;

  void publish(int rideId) {
    if (!_controller.isClosed) {
      _controller.add(rideId);
    }
  }
}

class FcmService {
  FcmService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  SharedPreferences? _prefs;

  static const _ridesChannel = AndroidNotificationChannel(
    'taxigo_rides',
    'Ride Updates',
    description: 'Notifications for ride status and driver updates',
    importance: Importance.max,
    playSound: true,
  );

  static const _otpChannel = AndroidNotificationChannel(
    'taxigo_otp',
    'OTP Verification',
    description: 'Login verification codes',
    importance: Importance.max,
  );

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> bindPreferences(SharedPreferences prefs) async {
    _prefs = prefs;
    final pending = prefs.getString(_pendingOtpKey);
    if (pending != null && pending.length == 6) {
      OtpInboxService.instance.publish(pending);
      await prefs.remove(_pendingOtpKey);
    }
  }

  Future<void> initialize({
    void Function(RemoteMessage message)? onMessageOpened,
    void Function(RemoteMessage message)? onForegroundMessage,
  }) async {
    if (!FirebaseService.isInitialized) {
      if (kDebugMode) {
        debugPrint('FCM skipped: Firebase not configured');
      }
      return;
    }

    await _requestPermission();
    await _setupLocalNotifications();

    _fcmToken = await _messaging.getToken();

    FirebaseMessaging.onMessage.listen((message) {
      _handlePayload(message);
      onForegroundMessage?.call(message);
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handlePayload(message);
      onMessageOpened?.call(message);
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handlePayload(initial);
      onMessageOpened?.call(initial);
    }
  }

  void _handlePayload(RemoteMessage message) {
    final data = message.data;
    final type = data['type']?.toString();

    if (type == 'otp') {
      final code = data['code']?.toString();
      if (code != null) OtpInboxService.instance.publish(code);
      return;
    }

    if (type == 'ride_request') {
      final rideId = int.tryParse(data['ride_id']?.toString() ?? '');
      if (rideId != null) {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.heavyImpact();
        RideRequestInbox.instance.publish(rideId);
      }
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      debugPrint('FCM permission: ${settings.authorizationStatus}');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final android = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(_ridesChannel);
      await android?.createNotificationChannel(_otpChannel);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final isOtp = message.data['type'] == 'otp';
    final isRide = message.data['type'] == 'ride_request';
    final channelId = isOtp ? 'taxigo_otp' : 'taxigo_rides';
    final channelName = isOtp ? 'OTP Verification' : 'Ride Updates';

    final title = notification?.title ??
        (isRide
            ? 'Yeni yolculuk isteği'
            : (isOtp ? 'TaxiGo Verification' : 'TaxiGo'));
    final body = notification?.body ??
        (isRide
            ? (message.data['pickup_address']?.toString() ?? 'Yeni istek')
            : (isOtp ? 'Your login code: ${message.data['code']}' : ''));

    if (body.isEmpty && notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: isOtp
          ? 'Login verification codes'
          : 'Notifications for ride status and driver updates',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(presentSound: true);
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      details,
      payload: message.data['ride_id']?.toString() ??
          message.data['code']?.toString(),
    );
  }

  Future<String?> refreshToken() async {
    _fcmToken = await _messaging.getToken();
    return _fcmToken;
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final data = message.data;
  if (data['type'] == 'otp') {
    final code = data['code']?.toString();
    if (code == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingOtpKey, code.replaceAll(RegExp(r'\D'), ''));
  }
}
