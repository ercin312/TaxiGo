import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

class IncomingRideRequestSheet extends StatelessWidget {
  const IncomingRideRequestSheet({
    super.key,
    required this.ride,
    required this.onAccept,
    required this.onReject,
  });

  final RideModel ride;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.notifications_active, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.pendingRides,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _RideDetailRow(
            icon: Icons.trip_origin,
            label: l10n.pickupLocation,
            value: ride.pickupAddress,
          ),
          const SizedBox(height: 12),
          _RideDetailRow(
            icon: Icons.location_on,
            label: l10n.dropoffLocation,
            value: ride.dropoffAddress,
          ),
          const SizedBox(height: 12),
          _RideDetailRow(
            icon: Icons.attach_money,
            label: l10n.estimatedFare,
            value: ride.estimatedFare?.toStringAsFixed(2) ?? '--',
          ),
          if (ride.estimatedDistanceKm != null) ...[
            const SizedBox(height: 12),
            _RideDetailRow(
              icon: Icons.straighten,
              label: l10n.estimatedDistance,
              value: '${ride.estimatedDistanceKm!.toStringAsFixed(1)} km',
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.rejectRide),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  label: l10n.acceptRide,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _RideDetailRow extends StatelessWidget {
  const _RideDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
