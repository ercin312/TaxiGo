import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../firebase/firebase_service.dart';

enum SocialAuthProvider { google, apple }

class SocialAuthResult {
  const SocialAuthResult({
    required this.provider,
    required this.idToken,
    required this.uid,
    this.email,
    this.name,
    this.avatar,
    this.phone,
  });

  final SocialAuthProvider provider;
  final String idToken;
  final String uid;
  final String? email;
  final String? name;
  final String? avatar;
  final String? phone;
}

class SocialAuthCancelled implements Exception {
  @override
  String toString() => 'Giriş iptal edildi.';
}

class SocialAuthUnavailable implements Exception {
  SocialAuthUnavailable(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Google / Apple → Firebase Auth → ID token for Laravel (or local session).
class SocialAuthService {
  SocialAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? _createGoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// Optional overrides (CI / local):
  /// `--dart-define=TAXIGO_GOOGLE_IOS_CLIENT_ID=...`
  /// `--dart-define=TAXIGO_GOOGLE_SERVER_CLIENT_ID=...` (Web client ID)
  static GoogleSignIn _createGoogleSignIn() {
    const iosClientId = String.fromEnvironment('TAXIGO_GOOGLE_IOS_CLIENT_ID');
    const serverClientId =
        String.fromEnvironment('TAXIGO_GOOGLE_SERVER_CLIENT_ID');
    return GoogleSignIn(
      scopes: const ['email', 'profile'],
      clientId: iosClientId.isEmpty ? null : iosClientId,
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
  }

  Future<SocialAuthResult> signIn(SocialAuthProvider provider) {
    return switch (provider) {
      SocialAuthProvider.google => signInWithGoogle(),
      SocialAuthProvider.apple => signInWithApple(),
    };
  }

  Future<SocialAuthResult> signInWithGoogle() async {
    _ensureFirebase();

    final account = await _googleSignIn.signIn();
    if (account == null) throw SocialAuthCancelled();

    final googleAuth = await account.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw SocialAuthUnavailable(
        'Google kimlik jetonu alınamadı. Firebase Console’da '
        'Google Sign-In’i açın ve Android SHA-1 ekleyin.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    return _fromFirebaseUser(
      userCred.user,
      provider: SocialAuthProvider.google,
      fallbackName: account.displayName,
      fallbackEmail: account.email,
      fallbackAvatar: account.photoUrl,
    );
  }

  Future<SocialAuthResult> signInWithApple() async {
    _ensureFirebase();

    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS)) {
      throw SocialAuthUnavailable(
        'Sign in with Apple is only available on iOS / macOS.',
      );
    }

    final available = await SignInWithApple.isAvailable();
    if (!available) {
      throw SocialAuthUnavailable(
        'Sign in with Apple is not available on this device.',
      );
    }

    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    try {
      final apple = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      ).timeout(
        const Duration(seconds: 120),
        onTimeout: () => throw SocialAuthUnavailable(
          'Sign in with Apple timed out. Please try again.',
        ),
      );

      final identityToken = apple.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw SocialAuthUnavailable(
          'Apple identity token was missing. Please try again.',
        );
      }

      // Do NOT pass authorizationCode as accessToken — Firebase rejects it.
      final oauth = OAuthProvider('apple.com').credential(
        idToken: identityToken,
        rawNonce: rawNonce,
      );

      final userCred = await _auth.signInWithCredential(oauth).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw SocialAuthUnavailable(
          'Could not create Apple session. Check your connection.',
        ),
      );
      final fullName = [
        apple.givenName,
        apple.familyName,
      ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');

      // Persist Apple name on first login (Firebase only gets it once).
      if (fullName.isNotEmpty &&
          (userCred.user?.displayName == null ||
              userCred.user!.displayName!.trim().isEmpty)) {
        try {
          await userCred.user?.updateDisplayName(fullName);
        } catch (_) {}
      }

      return _fromFirebaseUser(
        userCred.user,
        provider: SocialAuthProvider.apple,
        fallbackName: fullName.isEmpty ? null : fullName,
        fallbackEmail: apple.email,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw SocialAuthCancelled();
      }
      throw SocialAuthUnavailable(
        e.message.isNotEmpty
            ? e.message
            : 'Sign in with Apple failed (${e.code.name}).',
      );
    } on FirebaseAuthException catch (e) {
      throw SocialAuthUnavailable(_mapFirebaseAuthError(e));
    }
  }

  static String _mapFirebaseAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'operation-not-allowed' =>
        'Apple Sign-In is not enabled in Firebase Authentication.',
      'invalid-credential' || 'invalid-id-token' =>
        'Apple credentials were rejected. Please try again.',
      'network-request-failed' =>
        'Network error during Apple Sign-In. Please try again.',
      'user-disabled' => 'This account has been disabled.',
      _ => e.message?.isNotEmpty == true
          ? e.message!
          : 'Apple Sign-In failed (${e.code}).',
    };
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  void _ensureFirebase() {
    if (!FirebaseService.isInitialized) {
      throw SocialAuthUnavailable(
        'Firebase hazır değil. google-services.json / GoogleService-Info.plist '
        'kontrol edin.',
      );
    }
  }

  Future<SocialAuthResult> _fromFirebaseUser(
    User? user, {
    required SocialAuthProvider provider,
    String? fallbackName,
    String? fallbackEmail,
    String? fallbackAvatar,
  }) async {
    if (user == null) {
      throw SocialAuthUnavailable('Firebase oturumu oluşturulamadı.');
    }

    final token = await user.getIdToken(true).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw SocialAuthUnavailable(
        'Kimlik jetonu alınamadı. Tekrar deneyin.',
      ),
    );
    if (token == null || token.isEmpty) {
      throw SocialAuthUnavailable('Kimlik jetonu alınamadı.');
    }

    return SocialAuthResult(
      provider: provider,
      idToken: token,
      uid: user.uid,
      email: user.email ?? fallbackEmail,
      name: user.displayName ?? fallbackName,
      avatar: user.photoURL ?? fallbackAvatar,
      phone: user.phoneNumber,
    );
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
