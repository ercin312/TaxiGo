import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_images.dart';

/// Auth composition: full-bleed night field + brand signal + soft sheet.
class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.showBackButton = false,
    this.topAction,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool showBackButton;
  final Widget? topAction;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.ink,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _SignalGridPainter(progress: _motion)),
          ),
          Positioned(
            top: -size.height * 0.08,
            right: -size.width * 0.25,
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _motion, curve: Curves.easeOut),
              child: Container(
                width: size.width * 0.85,
                height: size.width * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.22),
                      AppColors.accent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.08,
            left: 28,
            right: 28,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.12),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _motion,
                curve: const Interval(0.05, 0.55, curve: Curves.easeOutCubic),
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _motion,
                  curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.showBackButton)
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                          ),
                        const Spacer(),
                        if (widget.topAction != null) widget.topAction!,
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'TaxiGo',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.4,
                            height: 0.95,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: AppColors.accentGradient,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Şehirde hızlı, güvenli yolculuk.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                    ),
                    const SizedBox(height: 18),
                    Image.asset(
                      AppImages.logo,
                      height: 52,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.local_taxi_rounded,
                        size: 48,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 0),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.18),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _motion,
                  curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic),
                )),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: size.height * 0.52,
                    maxHeight: size.height * 0.72,
                  ),
                  decoration: const BoxDecoration(
                    gradient: AppColors.sheetGradient,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      28,
                      24,
                      24 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.dividerLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.title,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 20),
                        widget.child,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalGridPainter extends CustomPainter {
  _SignalGridPainter({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const step = 42.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * 0.55), paint);
    }
    for (double y = 0; y < size.height * 0.55; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final pulse = math.sin(progress.value * math.pi);
    final accent = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.accent.withValues(alpha: 0.0),
          AppColors.accent.withValues(alpha: 0.35 * pulse),
          AppColors.accent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.18, size.width, 3));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.22, size.width, 2.5),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant _SignalGridPainter oldDelegate) => false;
}
