import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

enum PassengerTab { home, trips, account }

class FloatingPillNav extends StatelessWidget {
  const FloatingPillNav({
    super.key,
    required this.current,
    required this.onSelect,
    required this.homeLabel,
    required this.tripsLabel,
    required this.accountLabel,
  });

  final PassengerTab current;
  final ValueChanged<PassengerTab> onSelect;
  final String homeLabel;
  final String tripsLabel;
  final String accountLabel;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottom),
      child: Material(
        color: AppColors.surfaceLight,
        elevation: 10,
        shadowColor: AppColors.ink.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: homeLabel,
                  selected: current == PassengerTab.home,
                  onTap: () => onSelect(PassengerTab.home),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.history_rounded,
                  activeIcon: Icons.history_rounded,
                  label: tripsLabel,
                  selected: current == PassengerTab.trips,
                  onTap: () => onSelect(PassengerTab.trips),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: accountLabel,
                  selected: current == PassengerTab.account,
                  onTap: () => onSelect(PassengerTab.account),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.ink.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 22,
              color: selected ? AppColors.ink : AppColors.textSecondaryLight,
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
