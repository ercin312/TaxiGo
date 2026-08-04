import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';

class RatingsPage extends StatelessWidget {
  const RatingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rateRide)),
      body: FutureBuilder(
        future: getIt<DriverRepository>().getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text(l10n.somethingWentWrong));
          }

          final driver = snapshot.data!.fold((_) => null, (d) => d);

          if (driver == null) {
            return Center(child: Text(l10n.somethingWentWrong));
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        driver.ratingAverage.toStringAsFixed(1),
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < driver.ratingAverage.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 28,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${driver.ratingCount} ${l10n.rateRide}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _RatingStatRow(
                  label: l10n.tripCompleted,
                  value: '${driver.totalRides}',
                ),
                _RatingStatRow(
                  label: l10n.rateRide,
                  value: driver.ratingAverage.toStringAsFixed(2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RatingStatRow extends StatelessWidget {
  const _RatingStatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
