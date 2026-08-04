import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../di/locator.dart';
import '../features/account/presentation/pages/account_page.dart';
import '../features/account/presentation/pages/complaint_page.dart';
import '../features/account/presentation/pages/profile_edit_page.dart';
import '../features/account/presentation/pages/promo_page.dart';
import '../features/account/presentation/pages/trip_history_page.dart';
import '../features/account/presentation/pages/wallet_page.dart';
import '../features/active_ride/application/active_ride_bloc.dart';
import '../features/active_ride/presentation/pages/active_ride_page.dart';
import '../features/app_mode/application/app_mode_cubit.dart';
import '../features/auth/presentation/pages/otp_verify_page.dart';
import '../features/auth/presentation/pages/phone_login_page.dart';
import '../features/auth/presentation/pages/profile_setup_page.dart';
import '../features/bidding/application/bidding_bloc.dart';
import '../features/bidding/presentation/pages/bidding_waiting_page.dart';
import '../features/booking/application/booking_bloc.dart';
import '../features/booking/presentation/pages/confirm_booking_page.dart';
import '../features/booking/presentation/pages/destination_page.dart';
import '../features/driver_history/application/history_bloc.dart';
import '../features/driver_history/presentation/pages/ratings_page.dart';
import '../features/driver_history/presentation/pages/ride_history_page.dart';
import '../features/driver_home/application/driver_home_bloc.dart';
import '../features/driver_home/presentation/pages/driver_home_page.dart';
import '../features/earnings/application/earnings_bloc.dart';
import '../features/earnings/presentation/pages/earnings_page.dart';
import '../features/home/presentation/pages/home_map_page.dart';
import '../features/kyc/application/kyc_bloc.dart';
import '../features/kyc/presentation/pages/driver_registration_page.dart';
import '../features/kyc/presentation/pages/pending_approval_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/ride/presentation/pages/ride_completed_page.dart';
import '../features/ride/presentation/pages/ride_status_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import 'auth_refresh.dart';

const _onboardingCompleteKey = 'passenger_onboarding_complete';

const _publicPaths = {
  '/splash',
  '/language',
  '/onboarding',
  '/login',
  '/otp',
};

GoRouter createAppRouter(AuthBloc authBloc) {
  final authRefresh = GoRouterAuthRefresh(authBloc);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final auth = authRefresh.state;
      final isPublic = _publicPaths.contains(loc);
      final authed = auth.status == AuthStatus.authenticated;
      final checking = auth.status == AuthStatus.initial ||
          auth.status == AuthStatus.loading;

      if (loc == '/splash' || checking) return null;

      if (!authed && !isPublic) return '/login';

      if (authed && (loc == '/login' || loc == '/otp')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) => LanguagePickerPage(
          showContinueButton: true,
          onContinue: () => context.go('/onboarding'),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const PhoneLoginPage(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra;
          final map = extra is Map
              ? Map<String, dynamic>.from(extra)
              : <String, dynamic>{};
          return OtpVerifyPage(
            phone: map['phone']?.toString() ?? '',
            name: map['name']?.toString(),
            channel: map['channel']?.toString(),
            debugCode: map['debugCode']?.toString(),
          );
        },
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeMapPage(),
      ),
      GoRoute(
        path: '/driver-home',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              passengerGetIt<DriverHomeBloc>()..add(const DriverHomeStarted()),
          child: const DriverHomePage(),
        ),
      ),
      GoRoute(
        path: '/destination',
        builder: (context, state) => const DestinationPage(),
      ),
      GoRoute(
        path: '/confirm-booking',
        builder: (context, state) {
          final bloc = state.extra as BookingBloc?;
          if (bloc != null) {
            return BlocProvider.value(
              value: bloc,
              child: const ConfirmBookingPage(),
            );
          }
          return BlocProvider(
            create: (_) => passengerGetIt<BookingBloc>(),
            child: const ConfirmBookingPage(),
          );
        },
      ),
      GoRoute(
        path: '/bidding/:id',
        builder: (context, state) {
          final ride = state.extra as RideModel?;
          return BlocProvider(
            create: (_) => passengerGetIt<BiddingBloc>()
              ..add(BiddingStarted(ride ??
                  RideModel(
                    id: int.parse(state.pathParameters['id']!),
                    reference: '',
                    passengerId: 0,
                    pickupLatitude: 0,
                    pickupLongitude: 0,
                    pickupAddress: '',
                    dropoffLatitude: 0,
                    dropoffLongitude: 0,
                    dropoffAddress: '',
                  ))),
            child: const BiddingWaitingPage(),
          );
        },
      ),
      GoRoute(
        path: '/ride/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return RideStatusPage(rideId: id);
        },
      ),
      GoRoute(
        path: '/ride-completed/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return RideCompletedPage(rideId: id);
        },
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
        path: '/wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: '/trips',
        builder: (context, state) => const TripHistoryPage(),
      ),
      GoRoute(
        path: '/promos',
        builder: (context, state) => const PromoPage(),
      ),
      GoRoute(
        path: '/complaints',
        builder: (context, state) => const ComplaintPage(),
      ),
      GoRoute(
        path: '/driver/register',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              passengerGetIt<KycBloc>()..add(const KycCheckStatus()),
          child: const DriverRegistrationPage(),
        ),
      ),
      GoRoute(
        path: '/driver/pending',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              passengerGetIt<KycBloc>()..add(const KycCheckStatus()),
          child: const PendingApprovalPage(),
        ),
      ),
      GoRoute(
        path: '/driver/active-ride',
        builder: (context, state) {
          final rideId = state.extra as int?;
          return BlocProvider(
            create: (_) => passengerGetIt<ActiveRideBloc>()
              ..add(ActiveRideStarted(rideId: rideId)),
            child: const ActiveRidePage(),
          );
        },
      ),
      GoRoute(
        path: '/driver/earnings',
        builder: (context, state) => BlocProvider(
          create: (_) => passengerGetIt<EarningsBloc>()
            ..add(const EarningsLoadRequested()),
          child: const EarningsPage(),
        ),
      ),
      GoRoute(
        path: '/driver/history',
        builder: (context, state) => BlocProvider(
          create: (_) => passengerGetIt<HistoryBloc>()
            ..add(const HistoryLoadRequested()),
          child: const DriverRideHistoryPage(),
        ),
      ),
      GoRoute(
        path: '/driver/ratings',
        builder: (context, state) => BlocProvider(
          create: (_) => passengerGetIt<HistoryBloc>()
            ..add(const HistoryLoadRequested()),
          child: const RatingsPage(),
        ),
      ),
    ],
  );
}

Future<bool> isOnboardingComplete() async {
  final prefs = passengerGetIt<SharedPreferences>();
  return prefs.getBool(_onboardingCompleteKey) ?? false;
}

Future<void> markOnboardingComplete() async {
  final prefs = passengerGetIt<SharedPreferences>();
  await prefs.setBool(_onboardingCompleteKey, true);
}

Future<String> resolveHomeRoute() async {
  final mode = passengerGetIt<AppModeCubit>().state;
  if (mode == AppMode.driver) {
    return '/driver-home';
  }
  return '/home';
}
