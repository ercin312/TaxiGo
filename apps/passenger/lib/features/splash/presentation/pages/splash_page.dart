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
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fade = CurvedAnimation(
      parent: _motion,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _motion,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _motion.forward();
    _navigate();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final authBloc = context.read<AuthBloc>();
    final prefs = passengerGetIt<SharedPreferences>();

    // Ensure a locale exists so we never force the language picker first.
    if (prefs.getString(AppConstants.localeKey) == null) {
      await prefs.setString(
        AppConstants.localeKey,
        SupportedLocales.defaultLocale.languageCode,
      );
    }
    // Skip onboarding carousel permanently.
    await markOnboardingComplete();

    // Hold until logo animation mostly finishes.
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 1100)),
      _motion.forward(),
    ]);

    // Load Super Admin feature flags for gated payments UI.
    try {
      await passengerGetIt<FeatureModulesService>().refresh(force: true);
    } catch (_) {}

    try {
      await authBloc.stream
          .firstWhere(
            (state) =>
                state.status != AuthStatus.initial &&
                state.status != AuthStatus.loading,
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {}

    if (!mounted || _navigated) return;
    _navigated = true;

    final authState = authBloc.state;
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
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.45),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.25),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AppImages.logo,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_taxi_rounded,
                          size: 52,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
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
