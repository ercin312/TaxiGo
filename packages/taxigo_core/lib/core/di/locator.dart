import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_config.dart';
import '../../data/network/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../../data/repositories/ride_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/driver_repository.dart';
import '../../domain/repositories/ride_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../features/auth/application/auth_bloc.dart';
import '../../features/language/application/language_bloc.dart';
import '../../firebase/fcm_service.dart';
import '../../firebase/rtdb_service.dart';
import '../../notifications/local_notification_service.dart';
import '../../services/device_registration_service.dart';
import '../../services/feature_modules_service.dart';
import '../../services/maps_service.dart';
import '../../services/saved_address_service.dart';

final GetIt locator = GetIt.instance;

/// Registers all TaxiGo core dependencies.
Future<void> setupLocator({String? baseUrl}) async {
  if (locator.isRegistered<SharedPreferences>()) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  final resolvedBaseUrl =
      ApiConfig.normalizeUrl(await ApiConfig.resolveBaseUrl(prefs));

  locator.registerLazySingleton<ApiClient>(
    () => ApiClient(prefs: prefs, baseUrl: resolvedBaseUrl),
  );

  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(locator<ApiClient>(), prefs),
  );
  locator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(locator<ApiClient>(), locator<AuthRepository>()),
  );
  locator.registerLazySingleton<RideRepository>(
    () => RideRepositoryImpl(locator<ApiClient>(), locator<AuthRepository>()),
  );
  locator.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(locator<ApiClient>(), locator<AuthRepository>()),
  );
  locator.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(locator<ApiClient>(), locator<AuthRepository>()),
  );

  locator.registerLazySingleton<RtdbService>(() => RtdbService());
  locator.registerLazySingleton<FcmService>(() => FcmService());
  locator.registerLazySingleton<DeviceRegistrationService>(
    () => DeviceRegistrationService(
      apiClient: locator<ApiClient>(),
      fcmService: locator<FcmService>(),
      prefs: prefs,
    ),
  );
  locator.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(),
  );
  locator.registerLazySingleton<MapsService>(
    () => MapsService(locator<ApiClient>()),
  );
  locator.registerLazySingleton<SavedAddressService>(
    () => SavedAddressService(prefs),
  );
  locator.registerLazySingleton<FeatureModulesService>(
    () => FeatureModulesService(locator<ApiClient>()),
  );

  locator.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: locator<AuthRepository>(),
      userRepository: locator<UserRepository>(),
      deviceRegistrationService: locator<DeviceRegistrationService>(),
    ),
  );
  locator.registerFactory<LanguageBloc>(
    () => LanguageBloc(prefs: prefs),
  );
}

/// Resets all registrations (useful in tests).
Future<void> resetLocator() async {
  await locator.reset();
}
