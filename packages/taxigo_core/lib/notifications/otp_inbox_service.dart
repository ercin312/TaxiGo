import 'dart:async';

/// Broadcasts OTP codes received via FCM push to active login screens.
class OtpInboxService {
  OtpInboxService._();

  static final OtpInboxService instance = OtpInboxService._();

  final _controller = StreamController<String>.broadcast();
  String? _lastCode;

  Stream<String> get otpStream => _controller.stream;

  String? get lastCode => _lastCode;

  void publish(String code) {
    final normalized = code.replaceAll(RegExp(r'\D'), '');
    if (normalized.length != 6) return;
    _lastCode = normalized;
    if (!_controller.isClosed) {
      _controller.add(normalized);
    }
  }

  void clear() {
    _lastCode = null;
  }
}
