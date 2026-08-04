import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

export 'primary_button.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          ColoredBox(
            color: AppColors.ink.withValues(alpha: 0.35),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.accent,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message!),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
