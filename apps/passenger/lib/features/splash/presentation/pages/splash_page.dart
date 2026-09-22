import 'dart:math' as math;

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
    with TickerProviderStateMixin {
  static const _logoSize = 176.0;

  late final AnimationController _intro;
  late final AnimationController _pulse;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _tilt;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _barWidth;
  late final Animation<double> _glow;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.35, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.72, curve: Curves.linear),
      ),
    );
    _tilt = Tween<double>(begin: -0.12, end: 0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.05, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.42, 0.78, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.42, 0.82, curve: Curves.easeOutCubic),
      ),
    );
    _barWidth = Tween<double>(begin: 0, end: 72).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.58, 0.92, curve: Curves.easeOutCubic),
      ),
    );
    _glow = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _intro.forward();
    _pulse.repeat(reverse: true);
    _navigate();
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final authBloc = context.read<AuthBloc>();
    final prefs = passengerGetIt<SharedPreferences>();

    if (prefs.getString(AppConstants.localeKey) == null) {
      await prefs.setString(
        AppConstants.localeKey,
        SupportedLocales.defaultLocale.languageCode,
      );
    }
    await markOnboardingComplete();

    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 1750)),
      _intro.forward(),
    ]);

    try {
      final modules = passengerGetIt<FeatureModulesService>();
      await modules.hydrateOverrides();
      await modules.refresh(force: true);
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
          // Soft ambient orbs
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final t = _pulse.value;
              return Stack(
                children: [
                  Positioned(
                    top: -80 + 20 * t,
                    right: -60,
                    child: _Orb(
                      size: 220,
                      color: AppColors.accent.withValues(alpha: 0.14 + 0.06 * t),
                    ),
                  ),
                  Positioned(
                    bottom: -40 - 16 * t,
                    left: -50,
                    child: _Orb(
                      size: 180,
                      color: Colors.white.withValues(alpha: 0.05 + 0.03 * t),
                    ),
                  ),
                ],
              );
            },
          ),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_intro, _pulse]),
              builder: (context, _) {
                final glow = _glow.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _fade,
                      child: Transform.rotate(
                        angle: _tilt.value * math.pi,
                        child: ScaleTransition(
                          scale: _scale,
                          child: Container(
                            width: _logoSize,
                            height: _logoSize,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(44),
                              border: Border.all(
                                color: AppColors.accent.withValues(
                                  alpha: 0.35 + 0.35 * glow,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.22 + 0.28 * glow,
                                  ),
                                  blurRadius: 28 + 36 * glow,
                                  spreadRadius: 2 + 6 * glow,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              AppImages.logo,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.local_taxi_rounded,
                                size: 88,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Column(
                          children: [
                            Text(
                              'TaxiGo',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.8,
                                    fontSize: 42,
                                    height: 1.05,
                                  ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: _barWidth.value,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: AppColors.accentGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.55,
                                    ),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
