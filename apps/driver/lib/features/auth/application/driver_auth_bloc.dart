import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

part 'driver_auth_event.dart';
part 'driver_auth_state.dart';

class DriverAuthBloc extends Bloc<DriverAuthEvent, DriverAuthState> {
  DriverAuthBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required FirebasePhoneAuth firebasePhoneAuth,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _firebasePhoneAuth = firebasePhoneAuth,
        super(const DriverAuthInitial()) {
    on<DriverAuthCheckRequested>(_onCheckRequested);
    on<DriverAuthPhoneSubmitted>(_onPhoneSubmitted);
    on<DriverAuthOtpSubmitted>(_onOtpSubmitted);
    on<DriverAuthResendOtp>(_onResendOtp);
    on<DriverAuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final FirebasePhoneAuth _firebasePhoneAuth;

  String? _verificationId;
  String? _phoneNumber;

  Future<void> _onCheckRequested(
    DriverAuthCheckRequested event,
    Emitter<DriverAuthState> emit,
  ) async {
    emit(const DriverAuthLoading());

    final token = await _authRepository.getStoredToken();
    if (token == null) {
      emit(const DriverAuthUnauthenticated());
      return;
    }

    final result = await _userRepository.getProfile();
    result.fold(
      (_) => emit(const DriverAuthUnauthenticated()),
      (user) => emit(DriverAuthAuthenticated(user)),
    );
  }

  Future<void> _onPhoneSubmitted(
    DriverAuthPhoneSubmitted event,
    Emitter<DriverAuthState> emit,
  ) async {
    emit(const DriverAuthLoading());
    _phoneNumber = event.phoneNumber;

    try {
      final verificationId =
          await _firebasePhoneAuth.sendOtp(event.phoneNumber);
      _verificationId = verificationId;
      emit(DriverAuthOtpSent(
        verificationId: verificationId,
        phoneNumber: event.phoneNumber,
      ));
    } catch (e) {
      emit(DriverAuthFailure(e.toString()));
    }
  }

  Future<void> _onOtpSubmitted(
    DriverAuthOtpSubmitted event,
    Emitter<DriverAuthState> emit,
  ) async {
    emit(const DriverAuthLoading());

    try {
      final verificationId = _verificationId ?? event.verificationId;
      final idToken = await _firebasePhoneAuth.verifyOtp(
        verificationId,
        event.smsCode,
      );

      final result = await _authRepository.verifyFirebaseToken(
        idToken: idToken,
        role: 'driver',
      );

      result.fold(
        (message) => emit(DriverAuthFailure(message)),
        (session) => emit(DriverAuthAuthenticated(session.user)),
      );
    } catch (e) {
      emit(DriverAuthFailure(e.toString()));
    }
  }

  Future<void> _onResendOtp(
    DriverAuthResendOtp event,
    Emitter<DriverAuthState> emit,
  ) async {
    if (_phoneNumber != null) {
      add(DriverAuthPhoneSubmitted(phoneNumber: _phoneNumber!));
    }
  }

  Future<void> _onLogoutRequested(
    DriverAuthLogoutRequested event,
    Emitter<DriverAuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const DriverAuthUnauthenticated());
  }
}
