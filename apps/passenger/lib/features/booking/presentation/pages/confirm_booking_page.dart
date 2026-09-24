import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../../shell/presentation/widgets/animated_bottom_sheet.dart';
import '../../application/booking_bloc.dart';
import '../widgets/vehicle_option_card.dart';

class ConfirmBookingPage extends StatefulWidget {
  const ConfirmBookingPage({super.key});

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  List<LatLng> _route = [];

  @override
  void initState() {
    super.initState();
    MapMarkerIcons.ensureLoaded();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoute());
  }

  Future<void> _loadRoute() async {
    final state = context.read<BookingBloc>().state;
    if (state.pickupLat == null || state.dropoffLat == null) return;
    final result = await passengerGetIt<MapsService>().getDirections(
      originLat: state.pickupLat!,
      originLng: state.pickupLng!,
      destinationLat: state.dropoffLat!,
      destinationLng: state.dropoffLng!,
      languageCode: Localizations.localeOf(context).languageCode,
    );
    if (!mounted) return;
    final points = result.fold(
      (_) => [
        LatLng(state.pickupLat!, state.pickupLng!),
        LatLng(state.dropoffLat!, state.dropoffLng!),
      ],
      (d) => d.points.length >= 2
          ? d.points
          : [
              LatLng(state.pickupLat!, state.pickupLng!),
              LatLng(state.dropoffLat!, state.dropoffLng!),
            ],
    );
    setState(() => _route = points);
  }

  Future<void> _pickSchedule(BookingBloc bloc) async {
    final now = DateTime.now().add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null || !mounted) return;
    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    bloc.add(BookingScheduleRequested(scheduled));
  }

  Future<void> _editNote(BookingBloc bloc, String? current) async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: current ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addNote),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: l10n.noteHint),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (ok == true) {
      bloc.add(BookingNoteChanged(ctrl.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state.status == BookingStatus.booked && state.createdRide != null) {
          if (state.createdRide!.scheduledAt != null ||
              state.scheduledAt != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.rideScheduled)),
            );
            final rideId = state.createdRide!.id;
            context.go('/trips?tab=upcoming&ride=$rideId');
          } else if (state.createdRide!.isBidding) {
            context.go(
              '/bidding/${state.createdRide!.id}',
              extra: state.createdRide,
            );
          } else {
            context.go('/ride/${state.createdRide!.id}');
          }
        } else if (state.status == BookingStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final estimate = state.estimate;
        final pickup = state.pickupLat == null
            ? null
            : LatLng(state.pickupLat!, state.pickupLng!);
        final dropoff = state.dropoffLat == null
            ? null
            : LatLng(state.dropoffLat!, state.dropoffLng!);
        final taxiTypes = ['standard', 'comfort', 'premium'];
        final transferTypes = ['van', 'comfort', 'premium'];
        final types =
            state.productMode == 'transfer' ? transferTypes : taxiTypes;

        return Scaffold(
          body: LoadingOverlay(
            isLoading: state.status == BookingStatus.loading,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: pickup ??
                          const LatLng(
                            AppConstants.defaultLatitude,
                            AppConstants.defaultLongitude,
                          ),
                      zoom: 13,
                    ),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    polylines: {
                      if (_route.length >= 2)
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: _route,
                          color: AppColors.mapRoute,
                          width: 5,
                        ),
                    },
                    markers: {
                      if (pickup != null)
                        Marker(
                          markerId: const MarkerId('pickup'),
                          position: pickup,
                          icon: MapMarkerIcons.pickupOrDefault,
                        ),
                      if (dropoff != null)
                        Marker(
                          markerId: const MarkerId('dropoff'),
                          position: dropoff,
                          icon: MapMarkerIcons.dropoffOrDefault,
                        ),
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Material(
                          color: AppColors.surfaceLight,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                        ),
                        const Spacer(),
                        if (estimate != null)
                          Material(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                l10n.nearbyDrivers(estimate.nearbyDriversCount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
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
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.mist.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _AddrLine(
                                  color: AppColors.success,
                                  text: state.pickupAddress ?? '',
                                ),
                                const SizedBox(height: 8),
                                _AddrLine(
                                  color: AppColors.error,
                                  text: state.dropoffAddress ?? '',
                                  trailing: IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => context.pop(),
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.mist.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ModeChip(
                                    label: l10n.productTaxi,
                                    selected: state.productMode == 'taxi',
                                    onTap: () => context
                                        .read<BookingBloc>()
                                        .add(const BookingProductModeChanged(
                                            'taxi')),
                                  ),
                                ),
                                Expanded(
                                  child: _ModeChip(
                                    label: l10n.productTransfer,
                                    selected: state.productMode == 'transfer',
                                    onTap: () => context
                                        .read<BookingBloc>()
                                        .add(const BookingProductModeChanged(
                                            'transfer')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...types.map((type) {
                            final selected = state.vehicleType == type;
                            final seats = type == 'van' ? 7 : 4;
                            final eta =
                                estimate?.estimatedDurationMinutes ?? 5;
                            final price = estimate == null
                                ? '—'
                                : _fareForType(
                                    estimate.totalFare,
                                    state.vehicleType,
                                    type,
                                  );
                            return VehicleOptionCard(
                              vehicleType: type,
                              title: _vehicleLabel(l10n, type),
                              meta:
                                  '${l10n.seatsCount(seats)} · ${l10n.etaMinutesShort(eta)}',
                              price: price,
                              selected: selected,
                              onTap: () => context.read<BookingBloc>().add(
                                    BookingVehicleTypeChanged(type),
                                  ),
                            );
                          }),
                          const SizedBox(height: 12),
                          _MatchModeSection(
                            matchMode: state.matchMode,
                            productMode: state.productMode,
                            biddingEnabled:
                                passengerGetIt<FeatureModulesService>().bidding,
                            fixedFare: estimate?.totalFare,
                            offeredFare: state.offeredFare,
                            onModeChanged: (mode) => context
                                .read<BookingBloc>()
                                .add(BookingMatchModeChanged(mode)),
                            onOfferDelta: (delta) => context
                                .read<BookingBloc>()
                                .add(BookingOfferAdjusted(delta)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionLink(
                                  icon: Icons.account_balance_wallet_outlined,
                                  label: l10n.paymentMethod,
                                  onTap: () => _pickPayment(context, state),
                                ),
                              ),
                              Expanded(
                                child: _ActionLink(
                                  icon: Icons.notes_rounded,
                                  label: l10n.addNote,
                                  onTap: () => _editNote(
                                    context.read<BookingBloc>(),
                                    state.passengerNote,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _ActionLink(
                                  icon: Icons.local_offer_outlined,
                                  label: l10n.coupon,
                                  onTap: () => context.push('/promos'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.matchMode == 'instant'
                                ? l10n.instantMatchHint
                                : l10n.fareMayVary,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  label: state.matchMode == 'bidding'
                                      ? l10n.requestBids
                                      : l10n.callTaxiGo,
                                  icon: state.matchMode == 'bidding'
                                      ? Icons.gavel_rounded
                                      : Icons.flash_on_rounded,
                                  onPressed: estimate == null
                                      ? null
                                      : () => context.read<BookingBloc>().add(
                                            const BookingSubmitRequested(),
                                          ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 56,
                                height: 54,
                                child: FilledButton(
                                  onPressed: estimate == null
                                      ? null
                                      : () => _pickSchedule(
                                            context.read<BookingBloc>(),
                                          ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.ink,
                                    foregroundColor: AppColors.accent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Icon(Icons.calendar_month),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickPayment(BuildContext context, BookingState state) async {
    final l10n = AppLocalizations.of(context)!;
    final methods = PaymentMethod.values.where((method) {
      if (method == PaymentMethod.card) {
        return passengerGetIt<FeatureModulesService>().cardPayments;
      }
      return true;
    }).toList();
    final selected = await showModalBottomSheet<PaymentMethod>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: methods
              .map(
                (m) => ListTile(
                  title: Text(_paymentLabel(l10n, m)),
                  trailing: m == state.paymentMethod
                      ? const Icon(Icons.check, color: AppColors.accentDeep)
                      : null,
                  onTap: () => Navigator.pop(context, m),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null && context.mounted) {
      context.read<BookingBloc>().add(BookingPaymentMethodChanged(selected));
    }
  }

  String _paymentLabel(AppLocalizations l10n, PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => l10n.paymentCash,
      PaymentMethod.wallet => l10n.paymentWallet,
      PaymentMethod.card => l10n.paymentCard,
    };
  }

  String _vehicleLabel(AppLocalizations l10n, String type) {
    return switch (type) {
      'comfort' => l10n.vehicleComfort,
      'premium' => l10n.vehiclePremium,
      'van' => l10n.vehicleVan,
      _ => l10n.vehicleStandard,
    };
  }

  String _fareForType(double selectedFare, String selectedType, String type) {
    double multiplier(String t) => switch (t) {
          'comfort' => 1.35,
          'premium' => 1.75,
          'van' => 2.2,
          _ => 1.0,
        };
    final base = selectedFare / multiplier(selectedType);
    return '${(base * multiplier(type)).toStringAsFixed(2)} ${AppConstants.currency}';
  }
}

class _MatchModeSection extends StatelessWidget {
  const _MatchModeSection({
    required this.matchMode,
    required this.productMode,
    required this.biddingEnabled,
    required this.fixedFare,
    required this.offeredFare,
    required this.onModeChanged,
    required this.onOfferDelta,
  });

  final String matchMode;
  final String productMode;
  final bool biddingEnabled;
  final double? fixedFare;
  final double? offeredFare;
  final ValueChanged<String> onModeChanged;
  final ValueChanged<double> onOfferDelta;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showBidding = biddingEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showBidding)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.mist.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModeChip(
                    label: l10n.matchModeInstant,
                    selected: matchMode == 'instant',
                    onTap: () => onModeChanged('instant'),
                  ),
                ),
                Expanded(
                  child: _ModeChip(
                    label: l10n.matchModeBidding,
                    selected: matchMode == 'bidding',
                    onTap: () => onModeChanged('bidding'),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: AppColors.accentDeep),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.matchModeInstantDesc,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        if (matchMode == 'instant') ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  productMode == 'transfer'
                      ? Icons.airport_shuttle_rounded
                      : Icons.near_me_rounded,
                  color: AppColors.ink,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productMode == 'transfer'
                            ? l10n.fixedPriceTransfer
                            : l10n.matchModeInstantDesc,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (fixedFare != null)
                        Text(
                          '${fixedFare!.toStringAsFixed(2)} ${AppConstants.currency}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (matchMode == 'bidding' && showBidding) ...[
          const SizedBox(height: 10),
          Text(
            l10n.yourOffer,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => onOfferDelta(-BookingBloc.fareStep),
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '${(offeredFare ?? fixedFare ?? 0).toStringAsFixed(2)} ${AppConstants.currency}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => onOfferDelta(BookingBloc.fareStep),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Text(
            l10n.matchModeBiddingDesc,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _AddrLine extends StatelessWidget {
  const _AddrLine({
    required this.color,
    required this.text,
    this.trailing,
  });

  final Color color;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.accent : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}

class _ActionLink extends StatelessWidget {
  const _ActionLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.ink),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
