import 'package:flutter/material.dart';

import '../../theme/admin_colors.dart';

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AdminColors.accent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: AdminColors.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AdminColors.ink.withValues(alpha: 0.05)),
            boxShadow: AdminColors.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.22),
                            color.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 16,
                        color: color.withValues(alpha: 0.7),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.ink,
                    height: 1.05,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.muted,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple 7-day bar chart for revenue / activity.
class AdminSparkBars extends StatelessWidget {
  const AdminSparkBars({
    super.key,
    required this.values,
    this.labels = const ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'],
  });

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = max <= 0 ? 1.0 : max;

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: (values[i] / safeMax).clamp(0.08, 1.0),
                        widthFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AdminColors.accentGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    i < labels.length ? labels[i] : '',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
