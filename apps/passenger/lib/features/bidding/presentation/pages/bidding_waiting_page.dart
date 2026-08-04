import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../application/bidding_bloc.dart';

class BiddingWaitingPage extends StatelessWidget {
  const BiddingWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<BiddingBloc, BiddingState>(
      listener: (context, state) {
        if (state.status == BiddingStatus.assigned &&
            state.assignedRide != null) {
          context.go('/ride/${state.assignedRide!.id}');
        } else if (state.status == BiddingStatus.cancelled) {
          context.go('/home');
        } else if (state.errorMessage != null &&
            state.status == BiddingStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final ride = state.ride;
        final offer = state.currentOffer ?? ride?.offeredFare ?? 0;
        final minimum = state.minimumFare ?? ride?.minimumFare ?? offer;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.lookingForDrivers),
          ),
          body: ride == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.radar,
                                size: 48,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.lookingForDrivers,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ride.pickupAddress,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.updateOffer,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.recommendedFareMinimum}: ${minimum.toStringAsFixed(2)} ${AppConstants.currency}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      _FareStepper(
                        value: offer,
                        onDecrease: () => context.read<BiddingBloc>().add(
                              const BiddingOfferAdjusted(-BiddingBloc.fareStep),
                            ),
                        onIncrease: () => context.read<BiddingBloc>().add(
                              const BiddingOfferAdjusted(BiddingBloc.fareStep),
                            ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: state.status == BiddingStatus.loading
                            ? null
                            : () => context
                                .read<BiddingBloc>()
                                .add(const BiddingOfferUpdateRequested()),
                        child: Text(l10n.updateOffer),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.availableDrivers,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (state.bids.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              l10n.noBidsYet,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ...state.bids.map(
                          (bid) => _DriverBidCard(
                            bid: bid,
                            onAccept: () => context.read<BiddingBloc>().add(
                                  BiddingAcceptBid(bid.id),
                                ),
                            onReject: () => context.read<BiddingBloc>().add(
                                  BiddingRejectBid(bid.id),
                                ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: state.status == BiddingStatus.loading
                            ? null
                            : () => _confirmCancel(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: Text(l10n.cancelRide),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelRide),
        content: Text(l10n.cancelRide),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<BiddingBloc>().add(const BiddingCancelRequested());
    }
  }
}

class _FareStepper extends StatelessWidget {
  const _FareStepper({
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final double value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: onDecrease,
              icon: const Icon(Icons.remove_circle_outline),
              color: AppColors.primary,
            ),
            Expanded(
              child: Text(
                '${value.toStringAsFixed(2)} ${AppConstants.currency}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ),
            IconButton(
              onPressed: onIncrease,
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverBidCard extends StatelessWidget {
  const _DriverBidCard({
    required this.bid,
    required this.onAccept,
    required this.onReject,
  });

  final RideBidModel bid;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final seconds = bid.secondsRemaining ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    (bid.driverName ?? 'D').substring(0, 1).toUpperCase(),
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid.driverName ?? 'Driver',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (bid.driverRating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(' ${bid.driverRating!.toStringAsFixed(2)}'),
                          ],
                        ),
                      if (bid.vehicleDescription != null)
                        Text(
                          bid.vehicleDescription!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${bid.amount.toStringAsFixed(2)} ${AppConstants.currency}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (seconds > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.secondsLeft(seconds),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: Text(l10n.rejectBid),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: l10n.acceptBid,
                    onPressed: onAccept,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
