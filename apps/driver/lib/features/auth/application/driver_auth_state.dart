part of 'driver_auth_bloc.dart';

sealed class DriverAuthState extends Equatable {
  const DriverAuthState();

  @override
  List<Object?> get props => [];
}

class DriverAuthInitial extends DriverAuthState {
  const DriverAuthInitial();
}

class DriverAuthLoading extends DriverAuthState {
  const DriverAuthLoading();
}

class DriverAuthUnauthenticated extends DriverAuthState {
  const DriverAuthUnauthenticated();
}

class DriverAuthOtpSent extends DriverAuthState {
  const DriverAuthOtpSent({
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

class DriverAuthAuthenticated extends DriverAuthState {
  const DriverAuthAuthenticated(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

class DriverAuthFailure extends DriverAuthState {
  const DriverAuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
