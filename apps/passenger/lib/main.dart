import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxigo_core/taxigo_core.dart';

import 'firebase_options.dart';
import 'app/app.dart';
import 'di/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep startup minimal so the first Flutter frame is never blocked by
  // push-permission / FCM token work (can look like a blank page on iPad).
  await FirebaseService.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupPassengerLocator();

  if (FirebaseService.isInitialized) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  runApp(const TaxiGoApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initPushServices();
  });
}

Future<void> _initPushServices() async {
  try {
    await passengerGetIt<LocalNotificationService>().initialize();

    final fcm = passengerGetIt<FcmService>();
    await fcm.bindPreferences(passengerGetIt<SharedPreferences>());

    if (!FirebaseService.isInitialized) return;

    await fcm.initialize();
    await passengerGetIt<DeviceRegistrationService>().register();
    fcm.onTokenRefresh.listen((_) {
      passengerGetIt<DeviceRegistrationService>().register();
    });
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('Push init skipped: $e');
      debugPrint('$stack');
    }
  }
}
