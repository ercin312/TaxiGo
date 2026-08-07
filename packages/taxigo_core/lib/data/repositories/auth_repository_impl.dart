import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../services/social_auth_service.dart';
import '../mappers/model_mappers.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._apiClient,
    this._prefs, {
    SocialAuthService? socialAuth,
  }) : _socialAuth = socialAuth ?? SocialAuthService();

  static const _localUserKey = 'taxigo_local_user';
  static const _localTokenPrefix = 'local_';

  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  final SocialAuthService _socialAuth;
  String? _cachedToken;

  @override
  bool get isAuthenticated => _cachedToken != null && _cachedToken!.isNotEmpty;

  @override
  Future<Either<String, OtpRequestResult>> requestOtp({
    required String phone,
    String role = 'passenger',
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.requestOtp,
        data: {
          'phone': phone,
          'role': role,
        },
      );
      final data = response.data;
      if (data == null) return const Left('Empty response from server');

      return Right(
        OtpRequestResult(
          phone: data['phone']?.toString() ?? phone,
          channel: data['channel']?.toString() ?? 'unknown',
          expiresIn: int.tryParse('${data['expires_in']}') ?? 300,
          debugCode: data['debug_code']?.toString(),
        ),
      );
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AuthSession>> verifyOtp({
    required String phone,
    required String code,
    String? name,
    String role = 'passenger',
    String? fcmToken,
    String? deviceId,
    String? locale,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phone,
          'code': code,
          if (name != null && name.isNotEmpty) 'name': name,
          'role': role,
          if (fcmToken != null) 'fcm_token': fcmToken,
          if (deviceId != null) 'device_id': deviceId,
          if (locale != null) 'locale': locale,
        },
      );
      return await _parseAuthResponse(response.data);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AuthSession>> demoLogin({
    required String phone,
    String? name,
    String role = 'passenger',
    String? fcmToken,
    String? deviceId,
    String? locale,
  }) {
    if (!AppConstants.allowDemoMode) {
      return Future.value(
        const Left('Demo giriş kapalı. Lütfen OTP veya sosyal giriş kullanın.'),
      );
    }
    return localLogin(phone: phone, name: name, role: role, locale: locale);
  }

  @override
  Future<Either<String, AuthSession>> localLogin({
    required String phone,
    String? name,
    String role = 'passenger',
    String? locale,
  }) async {
    if (!AppConstants.allowDemoMode) {
      return const Left(
        'Çevrimdışı giriş kapalı. Sunucuya bağlanıp OTP ile giriş yapın.',
      );
    }
    final normalizedPhone = phone.trim();
    final displayName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : 'Yolcu';
    final id = _stableId(normalizedPhone);
    final user = UserModel(
      id: id,
      name: displayName,
      phone: normalizedPhone,
      role: role,
      locale: locale ?? AppConstants.defaultLocale,
      isActive: true,
    );
    final token =
        '$_localTokenPrefix$id}_${DateTime.now().millisecondsSinceEpoch}';

    await saveToken(token);
    await saveLocalUser(user);

    return Right(
      AuthSession(
        token: token,
        user: user,
        authMode: 'local',
      ),
    );
  }

  @override
  Future<UserModel?> getStoredLocalUser() async {
    final raw = _prefs.getString(_localUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;
      return ModelMappers.userFromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLocalUser(UserModel user) async {
    await _prefs.setString(
      _localUserKey,
      jsonEncode({
        'id': user.id,
        'name': user.name,
        'phone': user.phone,
        'email': user.email,
        'role': user.role,
        'locale': user.locale,
        'avatar': user.avatar,
        'is_active': user.isActive,
      }),
    );
  }

  @override
  bool isLocalToken(String? token) =>
      token != null && token.startsWith(_localTokenPrefix);

  @override
  Future<Either<String, AuthSession>> verifyFirebaseToken({
    required String idToken,
    String role = 'passenger',
    String? fcmToken,
    String? locale,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.firebaseVerify,
        data: {
          'id_token': idToken,
          'role': role,
          if (fcmToken != null) 'fcm_token': fcmToken,
          if (locale != null) 'locale': locale,
        },
      );
      return await _parseAuthResponse(response.data);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AuthSession>> socialLogin({
    required SocialAuthProvider provider,
    String role = 'passenger',
    String? fcmToken,
    String? locale,
  }) async {
    try {
      final social = await _socialAuth.signIn(provider);

      final remote = await verifyFirebaseToken(
        idToken: social.idToken,
        role: role,
        fcmToken: fcmToken,
        locale: locale,
      );

      return await remote.fold(
        (error) async {
          if (!AppConstants.allowDemoMode) {
            return Left(error);
          }
          return _localSessionFromSocial(social, role: role, locale: locale);
        },
        (session) async => Right(session),
      );
    } on SocialAuthCancelled {
      return const Left('Giriş iptal edildi.');
    } on SocialAuthUnavailable catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, AuthSession>> _localSessionFromSocial(
    SocialAuthResult social, {
    required String role,
    String? locale,
  }) async {
    final email = social.email?.trim();
    final name = (social.name != null && social.name!.trim().isNotEmpty)
        ? social.name!.trim()
        : (email != null && email.contains('@')
            ? email.split('@').first
            : 'TaxiGo kullanıcı');
    final identity = email ?? social.uid;
    final id = _stableId('social_${social.provider.name}_$identity');

    final user = UserModel(
      id: id,
      name: name,
      email: email,
      phone: social.phone,
      role: role,
      locale: locale ?? AppConstants.defaultLocale,
      avatar: social.avatar,
      isActive: true,
    );
    final token =
        '$_localTokenPrefix${id}_${DateTime.now().millisecondsSinceEpoch}';

    await saveToken(token);
    await saveLocalUser(user);

    return Right(
      AuthSession(
        token: token,
        user: user,
        authMode: 'social_${social.provider.name}_local',
      ),
    );
  }

  Future<Either<String, AuthSession>> _parseAuthResponse(
    Map<String, dynamic>? data,
  ) async {
    if (data == null) {
      return const Left('Empty response from server');
    }

    final token = data['token']?.toString();
    final userJson = data['user'] as Map<String, dynamic>?;
    if (token == null || userJson == null) {
      return const Left('Invalid auth response');
    }

    await saveToken(token);
    await _prefs.remove(_localUserKey);
    return Right(
      AuthSession(
        token: token,
        user: ModelMappers.userFromJson(userJson),
        firebaseCustomToken: data['firebase_custom_token']?.toString(),
        authMode: data['auth_mode']?.toString(),
      ),
    );
  }

  @override
  Future<Either<String, void>> logout() async {
    final token = await getStoredToken();
    if (!isLocalToken(token)) {
      try {
        await _apiClient.post(ApiEndpoints.logout);
      } catch (_) {
        // Ignore network errors on logout.
      }
    }
    await _socialAuth.signOut();
    await clearToken();
    return const Right(null);
  }

  @override
  Future<String?> getStoredToken() => _apiClient.getAuthToken();

  @override
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _apiClient.setAuthToken(token);
  }

  @override
  Future<void> clearToken() async {
    _cachedToken = null;
    await _apiClient.setAuthToken(null);
    await _prefs.remove(_localUserKey);
  }

  int _stableId(String phone) {
    var hash = 0;
    for (final code in phone.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }
}
