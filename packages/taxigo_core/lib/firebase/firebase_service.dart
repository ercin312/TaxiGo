import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase for TaxiGo apps.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Call once at app startup before using any Firebase services.
  /// Fails gracefully when google-services.json / FirebaseOptions are missing.
  static Future<void> initialize({
    FirebaseOptions? options,
    String? name,
  }) async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        return;
      }

      if (options != null) {
        await Firebase.initializeApp(options: options, name: name);
      } else {
        await Firebase.initializeApp(name: name);
      }
      _initialized = true;
    } catch (e, stack) {
      _initialized = false;
      if (kDebugMode) {
        debugPrint('Firebase init skipped: $e');
        debugPrint('$stack');
      }
    }
  }

  /// Signs into Firebase Auth with a custom token from the Laravel API
  /// so RTDB security rules (`auth.uid`) can authorize location writes.
  static Future<void> signInWithCustomToken(String? customToken) async {
    if (customToken == null || customToken.isEmpty || !_initialized) return;

    try {
      await FirebaseAuth.instance.signInWithCustomToken(customToken);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase custom token sign-in failed: $e');
      }
    }
  }

  static Future<void> signOut() async {
    if (!_initialized) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }
}
