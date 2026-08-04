import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper around Firebase phone authentication.
class FirebasePhoneAuth {
  FirebasePhoneAuth({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  String? _verificationId;
  int? _resendToken;

  String? get verificationId => _verificationId;

  /// Sends an OTP to [phoneNumber] in E.164 format (e.g. +905551234567).
  Future<String> sendOtp(String phoneNumber, {bool forceResending = false}) async {
    final holder = _CompleterHolder<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResending ? _resendToken : null,
      verificationCompleted: (credential) async {
        final result = await _auth.signInWithCredential(credential);
        final token = await result.user?.getIdToken();
        if (token != null) holder.complete(token);
      },
      verificationFailed: (e) =>
          holder.completeError(e.message ?? 'Verification failed'),
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        holder.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );

    return holder.future;
  }

  /// Verifies the OTP [smsCode] and returns the Firebase ID token.
  Future<String> verifyOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null) {
      throw StateError('Failed to obtain Firebase ID token');
    }
    return idToken;
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

class _CompleterHolder<T> {
  final _completer = Completer<T>();

  Future<T> get future => _completer.future;

  void complete(T value) {
    if (!_completer.isCompleted) _completer.complete(value);
  }

  void completeError(Object error) {
    if (!_completer.isCompleted) _completer.completeError(error);
  }
}
