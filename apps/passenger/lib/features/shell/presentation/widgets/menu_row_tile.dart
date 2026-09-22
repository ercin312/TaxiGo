import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

class MenuRowTile extends StatelessWidget {
  const MenuRowTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconBackground,
    this.iconColor,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconBackground;
  final Color? iconColor;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final bg = iconBackground ??
        (destructive
            ? const Color(0xFFFFE8D6)
            : AppColors.mist.withValues(alpha: 0.7));
    final fg = iconColor ??
        (destructive ? const Color(0xFFC45C12) : AppColors.ink);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: fg, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: destructive
                                ? const Color(0xFFC45C12)
                                : AppColors.textPrimaryLight,
                          ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
