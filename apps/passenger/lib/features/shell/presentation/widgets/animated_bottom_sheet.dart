import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

/// Slide-up panel chrome used on home / bidding / confirm.
class AnimatedBottomSheet extends StatelessWidget {
  const AnimatedBottomSheet({
    super.key,
    required this.child,
    this.maxHeightFactor = 0.62,
    this.showHandle = true,
  });

  final Widget child;
  final double maxHeightFactor;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 40, end: 0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: (1 - (value / 40)).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.sheetGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.16),
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle) ...[
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
