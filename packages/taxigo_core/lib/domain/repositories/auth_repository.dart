import 'package:dartz/dartz.dart';

import '../../services/social_auth_service.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<Either<String, OtpRequestResult>> requestOtp({
    required String phone,
    String role = 'passenger',
  });

  Future<Either<String, AuthSession>> verifyOtp({
    required String phone,
    required String code,
    String? name,
    String role = 'passenger',
    String? fcmToken,
    String? deviceId,
    String? locale,
  });

  /// Instant local login — no backend / PC required.
  Future<Either<String, AuthSession>> localLogin({
    required String phone,
    String? name,
    String role = 'passenger',
    String? locale,
  });

  /// Alias used by UI — currently maps to [localLogin].
  Future<Either<String, AuthSession>> demoLogin({
    required String phone,
    String? name,
    String role = 'passenger',
    String? fcmToken,
    String? deviceId,
    String? locale,
  });

  Future<Either<String, AuthSession>> verifyFirebaseToken({
    required String idToken,
    String role = 'passenger',
    String? fcmToken,
    String? locale,
  });

  /// Google / Apple → Firebase → backend (local fallback if API down).
  Future<Either<String, AuthSession>> socialLogin({
    required SocialAuthProvider provider,
    String role = 'passenger',
    String? fcmToken,
    String? locale,
  });

  Future<Either<String, void>> logout();

  Future<String?> getStoredToken();

  Future<UserModel?> getStoredLocalUser();

  Future<void> saveLocalUser(UserModel user);

  bool isLocalToken(String? token);

  Future<void> saveToken(String token);

  Future<void> clearToken();

  bool get isAuthenticated;
}

class OtpRequestResult {
  const OtpRequestResult({
    required this.phone,
    required this.channel,
    required this.expiresIn,
    this.debugCode,
  });

  final String phone;
  final String channel;
  final int expiresIn;
  final String? debugCode;
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
    this.firebaseCustomToken,
    this.authMode,
  });

  final String token;
  final UserModel user;
  final String? firebaseCustomToken;
  final String? authMode;
}
