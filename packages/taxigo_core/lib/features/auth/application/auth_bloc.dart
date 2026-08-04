import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/models/user_model.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../firebase/firebase_service.dart';
import '../../../services/device_registration_service.dart';
import '../../../services/local_demo_store.dart';
import '../../../services/social_auth_service.dart';

// Events

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthOtpRequested extends AuthEvent {
  const AuthOtpRequested({
    required this.phoneNumber,
    this.name,
    this.role = 'passenger',
  });

  final String phoneNumber;
  final String? name;
  final String role;

  @override
  List<Object?> get props => [phoneNumber, name, role];
}

class AuthOtpVerifyRequested extends AuthEvent {
  const AuthOtpVerifyRequested({
    required this.phoneNumber,
    required this.code,
    this.name,
    this.role = 'passenger',
  });

  final String phoneNumber;
  final String code;
  final String? name;
  final String role;

  @override
  List<Object?> get props => [phoneNumber, code, name, role];
}

class AuthDemoLoginRequested extends AuthEvent {
  const AuthDemoLoginRequested({
    required this.phoneNumber,
    this.name,
    this.role = 'passenger',
  });

  final String phoneNumber;
  final String? name;
  final String role;

  @override
  List<Object?> get props => [phoneNumber, name, role];
}

class AuthSocialLoginRequested extends AuthEvent {
  const AuthSocialLoginRequested({
    required this.provider,
    this.role = 'passenger',
  });

  final SocialAuthProvider provider;
  final String role;

  @override
  List<Object?> get props => [provider, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

// State

enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
    this.phoneNumber,
    this.name,
    this.otpChannel,
    this.otpDebugCode,
    this.otpExpiresIn,
  });

  final AuthStatus status;
  final UserModel? user;
  final String? token;
  final String? errorMessage;
  final String? phoneNumber;
  final String? name;
  final String? otpChannel;
  final String? otpDebugCode;
  final int? otpExpiresIn;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? token,
    String? errorMessage,
    String? phoneNumber,
    String? name,
    String? otpChannel,
    String? otpDebugCode,
    int? otpExpiresIn,
    bool clearError = false,
    bool clearUser = false,
    bool clearToken = false,
    bool clearOtpDebug = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      token: clearToken ? null : (token ?? this.token),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      otpChannel: otpChannel ?? this.otpChannel,
      otpDebugCode: clearOtpDebug ? null : (otpDebugCode ?? this.otpDebugCode),
      otpExpiresIn: otpExpiresIn ?? this.otpExpiresIn,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        token,
        errorMessage,
        phoneNumber,
        name,
        otpChannel,
        otpDebugCode,
        otpExpiresIn,
      ];
}

// Bloc

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required DeviceRegistrationService deviceRegistrationService,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _deviceRegistrationService = deviceRegistrationService,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerify);
    on<AuthDemoLoginRequested>(_onDemoLogin);
    on<AuthSocialLoginRequested>(_onSocialLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final DeviceRegistrationService _deviceRegistrationService;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final token = await _authRepository.getStoredToken();
    if (token == null || token.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      ));
      return;
    }

    if (_authRepository.isLocalToken(token)) {
      final localUser = await _authRepository.getStoredLocalUser();
      if (localUser == null) {
        await _authRepository.clearToken();
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        ));
        return;
      }
      final phone = localUser.phone;
      if (phone != null && phone.isNotEmpty) {
        final demo = LocalDemoStore.findByPhone(phone);
        if (demo != null) {
          LocalDemoStore.instance.applyDemoAccount(demo);
        }
      }
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        user: localUser,
      ));
      return;
    }

    final profile = await _userRepository.getProfile();
    await profile.fold(
      (error) async {
        await _authRepository.clearToken();
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        ));
      },
      (user) async => emit(state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        user: user,
      )),
    );
  }

  Future<void> _onOtpRequested(
    AuthOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      phoneNumber: event.phoneNumber,
      name: event.name,
      clearOtpDebug: true,
    ));

    final result = await _authRepository.requestOtp(
      phone: event.phoneNumber,
      role: event.role,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: error,
      )),
      (otp) => emit(state.copyWith(
        status: AuthStatus.otpSent,
        phoneNumber: otp.phone,
        otpChannel: otp.channel,
        otpDebugCode: otp.debugCode,
        otpExpiresIn: otp.expiresIn,
      )),
    );
  }

  Future<void> _onOtpVerify(
    AuthOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      phoneNumber: event.phoneNumber,
    ));

    final payload = await _deviceRegistrationService.registrationPayload(
      phone: event.phoneNumber,
    );
    await _deviceRegistrationService.register(phone: event.phoneNumber);

    final result = await _authRepository.verifyOtp(
      phone: event.phoneNumber,
      code: event.code,
      name: event.name ?? state.name,
      role: event.role,
      fcmToken: payload['fcm_token'],
      deviceId: payload['device_id'],
    );

    await result.fold(
      (error) async => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: error,
      )),
      (session) async {
        await FirebaseService.signInWithCustomToken(session.firebaseCustomToken);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: session.user,
          token: session.token,
          clearOtpDebug: true,
        ));
      },
    );
  }

  Future<void> _onDemoLogin(
    AuthDemoLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      phoneNumber: event.phoneNumber,
    ));

    final demo = LocalDemoStore.findByPhone(event.phoneNumber);
    if (demo != null) {
      LocalDemoStore.instance.applyDemoAccount(demo);
    } else {
      LocalDemoStore.instance.clearDemoSession();
    }

    // Instant device-local session — never waits on network / FCM / PC.
    final result = await _authRepository.localLogin(
      phone: event.phoneNumber,
      name: event.name,
      role: event.role,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: error,
      )),
      (session) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: session.user,
        token: session.token,
      )),
    );
  }

  Future<void> _onSocialLogin(
    AuthSocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    LocalDemoStore.instance.clearDemoSession();

    final payload = await _deviceRegistrationService.registrationPayload();
    final result = await _authRepository.socialLogin(
      provider: event.provider,
      role: event.role,
      fcmToken: payload['fcm_token'],
    );

    await result.fold(
      (error) async => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: error,
      )),
      (session) async {
        await FirebaseService.signInWithCustomToken(session.firebaseCustomToken);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: session.user,
          token: session.token,
        ));
      },
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    LocalDemoStore.instance.clearDemoSession();
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    await _authRepository.logout();
    await FirebaseService.signOut();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      clearToken: true,
      clearOtpDebug: true,
    ));
  }
}
