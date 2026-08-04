import 'package:get_it/get_it.dart';
import 'package:taxigo_core/taxigo_core.dart' as core;

import '../features/account/application/account_bloc.dart';
import '../features/active_ride/application/active_ride_bloc.dart';
import '../features/auth/application/driver_auth_bloc.dart';
import '../features/earnings/application/earnings_bloc.dart';
import '../features/history/application/history_bloc.dart';
import '../features/home/application/driver_home_bloc.dart';
import '../features/kyc/application/kyc_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  await core.setupLocator();

  getIt
    ..registerFactory(
      () => DriverAuthBloc(
        authRepository: getIt<core.AuthRepository>(),
        userRepository: getIt<core.UserRepository>(),
        firebasePhoneAuth: getIt<core.FirebasePhoneAuth>(),
      ),
    )
    ..registerFactory(
      () => KycBloc(driverRepository: getIt<core.DriverRepository>()),
    )
    ..registerFactory(
      () => DriverHomeBloc(
        driverRepository: getIt<core.DriverRepository>(),
        rtdbService: getIt<core.RtdbService>(),
      ),
    )
    ..registerFactory(
      () => ActiveRideBloc(
        driverRepository: getIt<core.DriverRepository>(),
        rtdbService: getIt<core.RtdbService>(),
      ),
    )
    ..registerFactory(
      () => EarningsBloc(
        driverRepository: getIt<core.DriverRepository>(),
        walletRepository: getIt<core.WalletRepository>(),
      ),
    )
    ..registerFactory(
      () => HistoryBloc(driverRepository: getIt<core.DriverRepository>()),
    )
    ..registerFactory(
      () => AccountBloc(userRepository: getIt<core.UserRepository>()),
    );
}
