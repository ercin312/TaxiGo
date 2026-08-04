import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

abstract class PassengerAuthEvent extends Equatable {
  const PassengerAuthEvent();

  @override
  List<Object?> get props => [];
}

class PassengerProfileSetupSubmitted extends PassengerAuthEvent {
  const PassengerProfileSetupSubmitted({
    required this.name,
    this.email,
  });

  final String name;
  final String? email;

  @override
  List<Object?> get props => [name, email];
}

abstract class PassengerAuthState extends Equatable {
  const PassengerAuthState();

  @override
  List<Object?> get props => [];
}

class PassengerAuthInitial extends PassengerAuthState {
  const PassengerAuthInitial();
}

class PassengerAuthLoading extends PassengerAuthState {
  const PassengerAuthLoading();
}

class PassengerAuthSuccess extends PassengerAuthState {
  const PassengerAuthSuccess(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

class PassengerAuthFailure extends PassengerAuthState {
  const PassengerAuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Passenger-specific auth flows (profile setup) on top of core [AuthBloc].
class PassengerAuthBloc extends Bloc<PassengerAuthEvent, PassengerAuthState> {
  PassengerAuthBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const PassengerAuthInitial()) {
    on<PassengerProfileSetupSubmitted>(_onProfileSetup);
  }

  final UserRepository _userRepository;

  Future<void> _onProfileSetup(
    PassengerProfileSetupSubmitted event,
    Emitter<PassengerAuthState> emit,
  ) async {
    emit(const PassengerAuthLoading());
    final result = await _userRepository.updateProfile(
      name: event.name,
      email: event.email,
    );
    result.fold(
      (error) => emit(PassengerAuthFailure(error)),
      (user) => emit(PassengerAuthSuccess(user)),
    );
  }
}
