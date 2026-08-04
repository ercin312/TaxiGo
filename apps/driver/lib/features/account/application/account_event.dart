part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class AccountLoadRequested extends AccountEvent {
  const AccountLoadRequested();
}

class AccountUpdateProfile extends AccountEvent {
  const AccountUpdateProfile({
    this.name,
    this.email,
    this.phone,
  });

  final String? name;
  final String? email;
  final String? phone;

  @override
  List<Object?> get props => [name, email, phone];
}

class AccountLogoutRequested extends AccountEvent {
  const AccountLogoutRequested();
}
