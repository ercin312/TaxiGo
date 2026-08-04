part of 'driver_auth_bloc.dart';

sealed class DriverAuthEvent extends Equatable {
  const DriverAuthEvent();

  @override
  List<Object?> get props => [];
}

class DriverAuthCheckRequested extends DriverAuthEvent {
  const DriverAuthCheckRequested();
}

class DriverAuthPhoneSubmitted extends DriverAuthEvent {
  const DriverAuthPhoneSubmitted({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

class DriverAuthOtpSubmitted extends DriverAuthEvent {
  const DriverAuthOtpSubmitted({
    required this.verificationId,
    required this.smsCode,
  });

  final String verificationId;
  final String smsCode;

  @override
  List<Object?> get props => [verificationId, smsCode];
}

class DriverAuthResendOtp extends DriverAuthEvent {
  const DriverAuthResendOtp();
}

class DriverAuthLogoutRequested extends DriverAuthEvent {
  const DriverAuthLogoutRequested();
}
