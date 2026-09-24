import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

/// Clean dusk sky + transparent taxi. Soft headlight wash when lit — no cores when dim.
class LoginHeroScene extends StatefulWidget {
  const LoginHeroScene({super.key});

  @override
  State<LoginHeroScene> createState() => _LoginHeroSceneState();
}

class _LoginHeroSceneState extends State<LoginHeroScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lights;
  Timer? _blinkTimer;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _lights = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: 0.0,
    );
    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(
      Duration(milliseconds: 2800 + _rng.nextInt(3600)),
      _runBlink,
    );
  }

  Future<void> _runBlink() async {
    if (!mounted) return;
    // Soft swell — no hard “bulb” when returning to off.
    await _lights.animateTo(0.85, curve: Curves.easeOut);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    await _lights.animateTo(0.12, curve: Curves.easeInOut);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    await _lights.animateTo(0.9, curve: Curves.easeOut);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    await _lights.animateTo(0.0, curve: Curves.easeInOut);
    if (!mounted) return;
    _scheduleNextBlink();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _lights.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B1220),
                Color(0xFF1A2740),
                Color(0xFF3E3548),
                Color(0xFF9A7040),
                Color(0xFFC49450),
                Color(0xFF2A2218),
              ],
              stops: [0.0, 0.32, 0.55, 0.75, 0.9, 1.0],
            ),
          ),
        ),
        Positioned(
          right: -60,
          top: 130,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFF2C8).withValues(alpha: 0.22),
                  const Color(0xFFF5B400).withValues(alpha: 0.08),
                  const Color(0x00E08A3C),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 130,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xB3070B12), Color(0x00070B12)],
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.9),
          child: AnimatedBuilder(
            animation: _lights,
            builder: (context, _) => _TaxiWithLights(intensity: _lights.value),
          ),
        ),
      ],
    );
  }
}

class _TaxiWithLights extends StatelessWidget {
  const _TaxiWithLights({required this.intensity});

  final double intensity;

  static const _imgW = 979.0;
  static const _imgH = 570.0;

  /// Headlight centers as fractions of the image.
  static const _leftLamp = Offset(0.085, 0.555);
  static const _rightLamp = Offset(0.43, 0.57);

  @override
  Widget build(BuildContext context) {
    // Only show wash when clearly “on”; fully invisible when dim/off.
    final wash = ((intensity - 0.2) / 0.8).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = math.min(constraints.maxWidth * 0.94, 380.0);
        final maxH = constraints.maxHeight * 0.92;
        final scale = math.min(maxW / _imgW, maxH / _imgH);
        final w = _imgW * scale;
        final h = _imgH * scale;

        final left = Offset(_leftLamp.dx * w, _leftLamp.dy * h);
        final right = Offset(_rightLamp.dx * w, _rightLamp.dy * h);

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: w * 0.12,
                right: w * 0.12,
                bottom: 2,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/login_taxi.png',
                package: 'taxigo_core',
                width: w,
                height: h,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.local_taxi_rounded,
                  size: h * 0.7,
                  color: AppColors.accent,
                ),
              ),
              if (wash > 0.02) ...[
                _SoftBeam(origin: left, width: w, height: h, glow: wash),
                _SoftBeam(origin: right, width: w * 0.85, height: h, glow: wash * 0.9),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Soft forward wash only — no hard bulb / lamp-core dot.
class _SoftBeam extends StatelessWidget {
  const _SoftBeam({
    required this.origin,
    required this.width,
    required this.height,
    required this.glow,
  });

  final Offset origin;
  final double width;
  final double height;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: origin.dx - width * 0.2,
      top: origin.dy - height * 0.05,
      child: Opacity(
        opacity: glow * 0.7,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 9),
          child: Transform.rotate(
            angle: -0.38,
            child: Container(
              width: width * 0.26,
              height: height * 0.09,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(255, 246, 210, 0.55 * glow),
                    Color.fromRGBO(255, 220, 140, 0.18 * glow),
                    const Color(0x00FFE78C),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
