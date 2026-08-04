import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const AccountInitial()) {
    on<AccountLoadRequested>(_onLoadRequested);
    on<AccountUpdateProfile>(_onUpdateProfile);
    on<AccountLogoutRequested>(_onLogoutRequested);
  }

  final UserRepository _userRepository;

  Future<void> _onLoadRequested(
    AccountLoadRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());

    final result = await _userRepository.getProfile();

    result.fold(
      (message) => emit(AccountFailure(message)),
      (user) => emit(AccountLoaded(user)),
    );
  }

  Future<void> _onUpdateProfile(
    AccountUpdateProfile event,
    Emitter<AccountState> emit,
  ) async {
    final current = state;
    if (current is! AccountLoaded) return;

    emit(current.copyWith(isSaving: true));

    final result = await _userRepository.updateProfile(
      name: event.name,
      email: event.email,
    );

    result.fold(
      (message) => emit(AccountFailure(message)),
      (user) => emit(AccountLoaded(user)),
    );
  }

  Future<void> _onLogoutRequested(
    AccountLogoutRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
  }
}
