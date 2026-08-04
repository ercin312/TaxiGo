import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../app/router.dart';
import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _navigate();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final authBloc = context.read<AuthBloc>();

    // Short branding beat only — never wait on network / modules.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    await authBloc.stream
        .firstWhere(
          (state) =>
              state.status != AuthStatus.initial &&
              state.status != AuthStatus.loading,
        )
        .timeout(
          const Duration(seconds: 2),
          onTimeout: () => authBloc.state.status == AuthStatus.loading
              ? const AuthState(status: AuthStatus.unauthenticated)
              : authBloc.state,
        );

    if (!mounted) return;

    final authState = authBloc.state;
    final onboardingDone = await isOnboardingComplete();
    final localeSet =
        passengerGetIt<SharedPreferences>().getString(AppConstants.localeKey) !=
            null;

    if (!mounted) return;

    if (!localeSet) {
      context.go('/language');
      return;
    }

    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }

    if (authState.status == AuthStatus.authenticated) {
      if (!isProfileComplete(authState.user)) {
        context.go('/profile-setup');
      } else {
        context.go(await resolveHomeRoute());
      }
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.heroGradient),
          ),
          FadeTransition(
            opacity: CurvedAnimation(parent: _motion, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(
                CurvedAnimation(parent: _motion, curve: Curves.easeOutCubic),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TaxiGo',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.6,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 56,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: AppColors.accentGradient,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
