part of 'account_bloc.dart';

sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  const AccountLoaded(this.user, {this.isSaving = false});

  final UserModel user;
  final bool isSaving;

  AccountLoaded copyWith({UserModel? user, bool? isSaving}) {
    return AccountLoaded(
      user ?? this.user,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [user, isSaving];
}

class AccountFailure extends AccountState {
  const AccountFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
