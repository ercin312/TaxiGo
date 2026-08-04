import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../features/app_mode/application/app_mode_cubit.dart';
import '../features/active_ride/application/active_ride_bloc.dart';
import '../features/bidding/application/bidding_bloc.dart';
import '../features/booking/application/booking_bloc.dart';
import '../features/driver_home/application/driver_home_bloc.dart';
import '../features/driver_history/application/history_bloc.dart';
import '../features/driver_profile/application/driver_profile_cubit.dart';
import '../features/earnings/application/earnings_bloc.dart';
import '../features/home/application/home_bloc.dart';
import '../features/kyc/application/kyc_bloc.dart';
import '../features/ride/application/ride_bloc.dart';

final GetIt passengerGetIt = GetIt.instance;

Future<void> setupPassengerLocator() async {
  await setupLocator();

  if (passengerGetIt.isRegistered<HomeBloc>()) return;

  final prefs = passengerGetIt<SharedPreferences>();

  passengerGetIt
    ..registerLazySingleton(() => AppModeCubit(prefs))
    ..registerLazySingleton(
      () => DriverProfileCubit(
        driverRepository: passengerGetIt<DriverRepository>(),
      ),
    )
    ..registerFactory<HomeBloc>(
      () => HomeBloc(
        rideRepository: passengerGetIt<RideRepository>(),
        mapsService: passengerGetIt<MapsService>(),
      ),
    )
    ..registerFactory<BookingBloc>(
      () => BookingBloc(rideRepository: passengerGetIt<RideRepository>()),
    )
    ..registerFactory<BiddingBloc>(
      () => BiddingBloc(rideRepository: passengerGetIt<RideRepository>()),
    )
    ..registerFactory<RideBloc>(
      () => RideBloc(
        rideRepository: passengerGetIt<RideRepository>(),
        rtdbService: passengerGetIt<RtdbService>(),
      ),
    )
    ..registerFactory(
      () => KycBloc(driverRepository: passengerGetIt<DriverRepository>()),
    )
    ..registerFactory(
      () => DriverHomeBloc(
        driverRepository: passengerGetIt<DriverRepository>(),
        rtdbService: passengerGetIt<RtdbService>(),
      ),
    )
    ..registerFactory(
      () => ActiveRideBloc(
        driverRepository: passengerGetIt<DriverRepository>(),
        rtdbService: passengerGetIt<RtdbService>(),
      ),
    )
    ..registerFactory(
      () => EarningsBloc(
        driverRepository: passengerGetIt<DriverRepository>(),
        walletRepository: passengerGetIt<WalletRepository>(),
      ),
    )
    ..registerFactory(
      () => HistoryBloc(driverRepository: passengerGetIt<DriverRepository>()),
    );
}
