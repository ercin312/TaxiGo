import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';
import '../../../booking/application/booking_bloc.dart';
import '../../../shell/presentation/widgets/soft_card.dart';

Future<void> showTripActionsSheet(
  BuildContext context, {
  required RideModel ride,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _TripActionsSheet(ride: ride),
  );
}

void rideAgainFromHistory(BuildContext context, RideModel ride) {
  final bloc = passengerGetIt<BookingBloc>()
    ..add(
      BookingLocationsSet(
        pickupLat: ride.pickupLatitude,
        pickupLng: ride.pickupLongitude,
        pickupAddress: ride.pickupAddress,
        dropoffLat: ride.dropoffLatitude,
        dropoffLng: ride.dropoffLongitude,
        dropoffAddress: ride.dropoffAddress,
      ),
    );
  if (ride.productMode == 'transfer') {
    bloc.add(const BookingProductModeChanged('transfer'));
  }
  if (ride.vehicleType.isNotEmpty) {
    bloc.add(BookingVehicleTypeChanged(ride.vehicleType));
  }
  context.push('/confirm-booking', extra: bloc);
}

class _TripActionsSheet extends StatelessWidget {
  const _TripActionsSheet({required this.ride});

  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final completed = ride.status == RideStatus.completed;
    final receiptsOn = locator<FeatureModulesService>().rideReceipts;
    final fare = ride.finalFare ?? ride.offeredFare ?? ride.estimatedFare;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.viewPaddingOf(context).bottom,
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
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.dropoffAddress,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ride.pickupAddress} → ${ride.dropoffAddress}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  '${rideStatusLabel(l10n, ride.status)} · ${ride.reference}'
                  '${fare != null ? ' · ${fare.toStringAsFixed(2)} ${AppConstants.currency}' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: l10n.rideAgain,
            icon: Icons.replay_rounded,
            onPressed: () {
              Navigator.pop(context);
              rideAgainFromHistory(context, ride);
            },
          ),
          if (completed && receiptsOn) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/receipt/${ride.id}');
              },
              icon: const Icon(Icons.receipt_long_rounded),
              label: Text(l10n.viewEReceipt),
            ),
          ],
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
