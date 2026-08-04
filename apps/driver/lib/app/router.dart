import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart' as core;

import '../di/locator.dart';
import '../features/account/presentation/pages/account_page.dart';
import '../features/account/presentation/pages/profile_edit_page.dart';
import '../features/active_ride/application/active_ride_bloc.dart';
import '../features/active_ride/presentation/pages/active_ride_page.dart';
import '../features/auth/application/driver_auth_bloc.dart';
import '../features/auth/presentation/pages/otp_verify_page.dart';
import '../features/auth/presentation/pages/phone_login_page.dart';
import '../features/earnings/application/earnings_bloc.dart';
import '../features/earnings/presentation/pages/earnings_page.dart';
import '../features/history/application/history_bloc.dart';
import '../features/history/presentation/pages/ratings_page.dart';
import '../features/history/presentation/pages/ride_history_page.dart';
import '../features/home/application/driver_home_bloc.dart';
import '../features/home/presentation/pages/driver_home_page.dart';
import '../features/kyc/application/kyc_bloc.dart';
import '../features/kyc/presentation/pages/driver_registration_page.dart';
import '../features/kyc/presentation/pages/pending_approval_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const PhoneLoginPage(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return OtpVerifyPage(
          verificationId: extra['verificationId'] ?? '',
          phoneNumber: extra['phoneNumber'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => BlocProvider.value(
        value: context.read<KycBloc>(),
        child: const DriverRegistrationPage(),
      ),
    ),
    GoRoute(
      path: '/pending',
      builder: (context, state) => BlocProvider.value(
        value: context.read<KycBloc>()..add(const KycCheckStatus()),
        child: const PendingApprovalPage(),
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<DriverHomeBloc>()..add(const DriverHomeStarted()),
        child: const DriverHomePage(),
      ),
    ),
    GoRoute(
      path: '/active-ride',
      builder: (context, state) {
        final rideId = state.extra as int?;
        return BlocProvider(
          create: (_) => getIt<ActiveRideBloc>()
            ..add(ActiveRideStarted(rideId: rideId)),
          child: const ActiveRidePage(),
        );
      },
    ),
    GoRoute(
      path: '/earnings',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<EarningsBloc>()..add(const EarningsLoadRequested()),
        child: const EarningsPage(),
      ),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<HistoryBloc>()..add(const HistoryLoadRequested()),
        child: const RideHistoryPage(),
      ),
    ),
    GoRoute(
      path: '/ratings',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<HistoryBloc>()..add(const HistoryLoadRequested()),
        child: const RatingsPage(),
      ),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => const AccountPage(),
    ),
    GoRoute(
      path: '/profile-edit',
      builder: (context, state) => const ProfileEditPage(),
    ),
    GoRoute(
      path: '/language',
        builder: (context, state) => const core.LanguagePickerPage(),
    ),
  ],
  redirect: (context, state) {
    final authState = context.read<DriverAuthBloc>().state;
    final location = state.matchedLocation;
    final publicRoutes = {'/', '/login', '/otp', '/language'};

    if (authState is DriverAuthAuthenticated) {
      if (publicRoutes.contains(location)) {
        return '/home';
      }
    } else if (authState is! DriverAuthLoading && !publicRoutes.contains(location)) {
      return '/login';
    }

    return null;
  },
);
