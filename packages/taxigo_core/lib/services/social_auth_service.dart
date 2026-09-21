import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
    this.isFirebaseIdToken = true,
  });

  final SocialAuthProvider provider;
  final String idToken;
  final String uid;
  final String? email;
  final String? name;
  final String? avatar;
  final String? phone;

  /// False when Apple/Google native auth succeeded but Firebase Auth did not.
  final bool isFirebaseIdToken;
}

class SocialAuthCancelled implements Exception {
  @override
  String toString() => 'Sign-in was cancelled.';
}

class SocialAuthUnavailable implements Exception {
  SocialAuthUnavailable(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Google / Apple → Firebase Auth → ID token for API (or local session).
class SocialAuthService {
  SocialAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? _createGoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  static GoogleSignIn _createGoogleSignIn() {
    const iosClientId = String.fromEnvironment(
      'TAXIGO_GOOGLE_IOS_CLIENT_ID',
      defaultValue:
          '728811081033-2d1rvnk8f99aomspm0nbu3khon8v81p1.apps.googleusercontent.com',
    );
    const serverClientId = String.fromEnvironment(
      'TAXIGO_GOOGLE_SERVER_CLIENT_ID',
      defaultValue:
          '728811081033-qg42felr8cvkf5nqa37rim4p1b5dggmf.apps.googleusercontent.com',
    );
    return GoogleSignIn(
      scopes: const ['email', 'profile'],
      // clientId is iOS-only; Android uses google-services.json + SHA-1.
      clientId: !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
          ? (iosClientId.isEmpty ? null : iosClientId)
          : null,
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
    try {
      _ensureFirebase();

      final account = await _googleSignIn.signIn();
      if (account == null) throw SocialAuthCancelled();

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        // Native Google account selected — still allow local session.
        return SocialAuthResult(
          provider: SocialAuthProvider.google,
          idToken: 'google_${account.id}',
          uid: account.id,
          email: account.email,
          name: account.displayName ?? 'Google Traveler',
          avatar: account.photoUrl,
          isFirebaseIdToken: false,
        );
      }

      try {
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
      } on FirebaseAuthException {
        return SocialAuthResult(
          provider: SocialAuthProvider.google,
          idToken: idToken,
          uid: account.id,
          email: account.email,
          name: account.displayName ?? 'Google Traveler',
          avatar: account.photoUrl,
          isFirebaseIdToken: false,
        );
      }
    } on SocialAuthCancelled {
      rethrow;
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled' || e.code == 'ERROR_ABORTED_BY_USER') {
        throw SocialAuthCancelled();
      }
      throw SocialAuthUnavailable(
        e.message?.isNotEmpty == true
            ? e.message!
            : 'Google Sign-In failed (${e.code}).',
      );
    } catch (e) {
      if (e is SocialAuthUnavailable || e is SocialAuthCancelled) rethrow;
      throw SocialAuthUnavailable('Google Sign-In failed. Please try again.');
    }
  }

  Future<SocialAuthResult> signInWithApple() async {
    try {
      _ensureFirebase();

      final available = await SignInWithApple.isAvailable();
      if (!available) {
        throw SocialAuthUnavailable(
          'Sign in with Apple is not available on this device.',
        );
      }

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw SocialAuthUnavailable(
          'Apple did not return an identity token. Please try again.',
        );
      }

      final displayName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].whereType<String>().where((p) => p.trim().isNotEmpty).join(' ');

      try {
        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: idToken,
          rawNonce: rawNonce,
        );
        final userCred = await _auth.signInWithCredential(oauthCredential);
        return _fromFirebaseUser(
          userCred.user,
          provider: SocialAuthProvider.apple,
          fallbackName: displayName.isEmpty ? null : displayName,
          fallbackEmail: appleCredential.email,
        );
      } on FirebaseAuthException {
        return SocialAuthResult(
          provider: SocialAuthProvider.apple,
          idToken: idToken,
          uid: appleCredential.userIdentifier ?? idToken,
          email: appleCredential.email,
          name: displayName.isEmpty ? 'Apple Traveler' : displayName,
          isFirebaseIdToken: false,
        );
      }
    } on SocialAuthCancelled {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw SocialAuthCancelled();
      }
      throw SocialAuthUnavailable(
        e.message.isNotEmpty
            ? e.message
            : 'Sign in with Apple failed (${e.code}).',
      );
    } on PlatformException catch (e) {
      if (e.code == 'canceled' || e.code == 'ERROR_ABORTED_BY_USER') {
        throw SocialAuthCancelled();
      }
      throw SocialAuthUnavailable(
        e.message?.isNotEmpty == true
            ? e.message!
            : 'Sign in with Apple failed (${e.code}).',
      );
    } catch (e) {
      if (e is SocialAuthUnavailable || e is SocialAuthCancelled) rethrow;
      throw SocialAuthUnavailable(
        'Sign in with Apple failed. Please try again.',
      );
    }
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
        'Firebase is not ready. Please try phone login.',
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
      throw SocialAuthUnavailable('Firebase session was not created.');
    }

    final token = await user.getIdToken(true).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw SocialAuthUnavailable(
        'Could not get identity token. Please try again.',
      ),
    );
    if (token == null || token.isEmpty) {
      throw SocialAuthUnavailable('Could not get identity token.');
    }

    return SocialAuthResult(
      provider: provider,
      idToken: token,
      uid: user.uid,
      email: user.email ?? fallbackEmail,
      name: user.displayName ?? fallbackName,
      avatar: user.photoURL ?? fallbackAvatar,
      phone: user.phoneNumber,
      isFirebaseIdToken: true,
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
