import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

class DestinationSearchBar extends StatelessWidget {
  const DestinationSearchBar({
    super.key,
    required this.onTap,
    this.nearbyDriverCount,
    this.isDemoFleet = false,
  });

  final VoidCallback onTap;
  final int? nearbyDriverCount;

  /// When true, nearby taxis are simulated until real drivers go online.
  final bool isDemoFleet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nearbyLabel = nearbyDriverCount == null
        ? null
        : l10n.nearbyDrivers(nearbyDriverCount!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: AppColors.sheetGradient,
            border: Border.all(color: AppColors.dividerLight.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.16),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TaxiGo',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.accentDeep,
                        letterSpacing: 0.6,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.homeTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (nearbyLabel != null)
                            Text(
                              nearbyLabel,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.ink,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
