import 'package:flutter/material.dart';

import '../../theme/admin_colors.dart';

class AdminSectionHeader extends StatelessWidget {
  const AdminSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.ink,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AdminColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?action,
      ],
    );
  }
}

class AdminStatusChip extends StatelessWidget {
  const AdminStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AdminPanel extends StatelessWidget {
  const AdminPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AdminColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminColors.ink.withValues(alpha: 0.05)),
        boxShadow: AdminColors.softShadow,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: content,
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AdminColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: AdminColors.accentDeep),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AdminColors.muted, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdminSearchField extends StatelessWidget {
  const AdminSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, color: AdminColors.muted),
        filled: true,
        fillColor: AdminColors.panel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AdminColors.ink.withValues(alpha: 0.04)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AdminColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

Color adminStatusColor(String status) {
  return switch (status) {
    'completed' || 'approved' || 'verified' => AdminColors.success,
    'pending' => AdminColors.warning,
    'cancelled_by_passenger' ||
    'cancelled_by_driver' ||
    'expired' ||
    'rejected' ||
    'banned' =>
      AdminColors.danger,
    'in_progress' || 'driver_arriving' || 'passenger_on_board' =>
      AdminColors.info,
    _ => AdminColors.muted,
  };
}

String adminStatusLabel(String status) {
  return switch (status) {
    'pending' => 'Bekliyor',
    'approved' => 'Onaylı',
    'rejected' => 'Reddedildi',
    'banned' => 'Yasaklı',
    'completed' => 'Tamamlandı',
    'in_progress' => 'Yolda',
    'driver_arriving' => 'Yaklaşıyor',
    'driver_arrived' => 'Geldi',
    'driver_assigned' => 'Atandı',
    'passenger_on_board' => 'Yolcuda',
    'cancelled_by_passenger' => 'Yolcu iptal',
    'cancelled_by_driver' => 'Sürücü iptal',
    'expired' => 'Süresi doldu',
    _ => status,
  };
}
