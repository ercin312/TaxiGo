import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../booking/presentation/widgets/vehicle_option_card.dart';
import '../../../shell/presentation/widgets/animated_bottom_sheet.dart';
import '../../application/bidding_bloc.dart';

class BiddingWaitingPage extends StatefulWidget {
  const BiddingWaitingPage({super.key});

  @override
  State<BiddingWaitingPage> createState() => _BiddingWaitingPageState();
}

class _BiddingWaitingPageState extends State<BiddingWaitingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radar;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _radar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    MapMarkerIcons.ensureLoaded();
  }

  @override
  void dispose() {
    _radar.dispose();
    super.dispose();
  }

  int get _elapsedMinutes {
    final start = _startedAt ?? DateTime.now();
    return DateTime.now().difference(start).inMinutes.clamp(0, 99);
  }

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
        final pickup = ride == null
            ? const LatLng(
                AppConstants.defaultLatitude,
                AppConstants.defaultLongitude,
              )
            : LatLng(ride.pickupLatitude, ride.pickupLongitude);

        return Scaffold(
          body: ride == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Positioned.fill(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: pickup,
                          zoom: 14.5,
                        ),
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId('pickup'),
                            position: pickup,
                            icon: MapMarkerIcons.pickupOrDefault,
                          ),
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _radar,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _RadarPainter(
                                progress: _radar.value,
                                color: AppColors.accent.withValues(alpha: 0.35),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedBottomSheet(
                        maxHeightFactor: 0.72,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            20 + MediaQuery.viewPaddingOf(context).bottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  AnimatedVehicleImage(
                                    vehicleType: ride.vehicleType,
                                    size: 78,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.discoverYourDriver,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: 0.72,
                                            minHeight: 8,
                                            backgroundColor: AppColors.mist,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            l10n.minutesElapsed(
                                                _elapsedMinutes),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.reservationDetails,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.mist.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  children: [
                                    _Line(
                                      icon: Icons.circle,
                                      color: AppColors.success,
                                      text: ride.pickupAddress,
                                    ),
                                    const SizedBox(height: 8),
                                    _Line(
                                      icon: Icons.location_on,
                                      color: AppColors.error,
                                      text: ride.dropoffAddress,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(l10n.tripDetails),
                              const SizedBox(height: 8),
                              _InfoTile(
                                icon: Icons.local_taxi_rounded,
                                label: ride.vehicleType,
                              ),
                              const SizedBox(height: 8),
                              _InfoTile(
                                icon: Icons.account_balance_wallet_outlined,
                                label: ride.paymentMethod == PaymentMethod.cash
                                    ? l10n.payInVehicle
                                    : ride.paymentMethod.value,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.updateOffer,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${l10n.recommendedFareMinimum}: ${minimum.toStringAsFixed(2)} ${AppConstants.currency}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              _FareStepper(
                                value: offer,
                                onDecrease: () =>
                                    context.read<BiddingBloc>().add(
                                          const BiddingOfferAdjusted(
                                            -BiddingBloc.fareStep,
                                          ),
                                        ),
                                onIncrease: () =>
                                    context.read<BiddingBloc>().add(
                                          const BiddingOfferAdjusted(
                                            BiddingBloc.fareStep,
                                          ),
                                        ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: state.status == BiddingStatus.loading
                                    ? null
                                    : () => context.read<BiddingBloc>().add(
                                          const BiddingOfferUpdateRequested(),
                                        ),
                                child: Text(l10n.updateOffer),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.availableDrivers,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              if (state.bids.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.mist.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        AppImages.rideSearching,
                                        height: 88,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                          Icons.radar,
                                          size: 40,
                                          color: AppColors.accentDeep,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.noBidsYet,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ...state.bids.map(
                                  (bid) => _DriverBidCard(
                                    bid: bid,
                                    onAccept: () =>
                                        context.read<BiddingBloc>().add(
                                              BiddingAcceptBid(bid.id),
                                            ),
                                    onReject: () =>
                                        context.read<BiddingBloc>().add(
                                              BiddingRejectBid(bid.id),
                                            ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(l10n.manageTrip),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: state.status == BiddingStatus.loading
                                    ? null
                                    : () => _confirmCancel(context),
                                icon: const Icon(Icons.cancel_outlined),
                                label: Text(l10n.cancelRide),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(
                                      color: AppColors.error),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < 3; i++) {
      final t = (progress + i / 3) % 1.0;
      paint.color = color.withValues(alpha: (1 - t) * 0.45);
      canvas.drawCircle(center, 28 + t * 110, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Line extends StatelessWidget {
  const _Line({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.ink),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onDecrease,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.ink,
          ),
          Expanded(
            child: Text(
              '${value.toStringAsFixed(2)} ${AppConstants.currency}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
            ),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.ink,
          ),
        ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.mist,
                child: Text(
                  (bid.driverName ?? 'D').substring(0, 1).toUpperCase(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.driverName ?? l10n.driverGeneric,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (bid.vehicleDescription != null)
                      Text(
                        bid.vehicleDescription!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Text(
                '${bid.amount.toStringAsFixed(2)} ${AppConstants.currency}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          if (seconds > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(l10n.secondsLeft(seconds)),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  child: Text(l10n.rejectBid),
                ),
              ),
              const SizedBox(width: 10),
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
    );
  }
}
