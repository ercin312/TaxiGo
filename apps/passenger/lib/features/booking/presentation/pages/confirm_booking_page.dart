import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../application/booking_bloc.dart';

class ConfirmBookingPage extends StatelessWidget {
  const ConfirmBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state.status == BookingStatus.booked && state.createdRide != null) {
          context.go('/bidding/${state.createdRide!.id}', extra: state.createdRide);
        } else if (state.status == BookingStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final estimate = state.estimate;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.confirmBooking)),
          body: LoadingOverlay(
            isLoading: state.status == BookingStatus.loading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.fareEstimate,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          if (estimate != null) ...[
                            _InfoRow(
                              l10n.distance,
                              '${estimate.distanceKm.toStringAsFixed(1)} ${l10n.km}',
                            ),
                            _InfoRow(
                              l10n.duration,
                              '${estimate.estimatedDurationMinutes} ${l10n.minutes}',
                            ),
                            _InfoRow(
                              l10n.estimatedFare,
                              '${estimate.totalFare.toStringAsFixed(2)} ${AppConstants.currency}',
                            ),
                            _InfoRow(
                              l10n.nearbyDrivers(estimate.nearbyDriversCount),
                              '${estimate.nearbyDriversCount}',
                            ),
                          ] else
                            Text(l10n.loading),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.vehicleType, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _VehicleChip(
                        label: l10n.vehicleStandard,
                        subtitle: estimate == null
                            ? null
                            : _fareForType(estimate.totalFare, state.vehicleType, 'standard'),
                        selected: state.vehicleType == 'standard',
                        onSelected: () => context.read<BookingBloc>().add(
                              const BookingVehicleTypeChanged('standard'),
                            ),
                      ),
                      _VehicleChip(
                        label: l10n.vehicleComfort,
                        subtitle: estimate == null
                            ? '+35%'
                            : _fareForType(estimate.totalFare, state.vehicleType, 'comfort'),
                        selected: state.vehicleType == 'comfort',
                        onSelected: () => context.read<BookingBloc>().add(
                              const BookingVehicleTypeChanged('comfort'),
                            ),
                      ),
                      _VehicleChip(
                        label: l10n.vehiclePremium,
                        subtitle: estimate == null
                            ? '+75%'
                            : _fareForType(estimate.totalFare, state.vehicleType, 'premium'),
                        selected: state.vehicleType == 'premium',
                        onSelected: () => context.read<BookingBloc>().add(
                              const BookingVehicleTypeChanged('premium'),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.paymentMethod, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...PaymentMethod.values
                      .where((method) {
                        if (method == PaymentMethod.card) {
                          return passengerGetIt<FeatureModulesService>()
                              .cardPayments;
                        }
                        return true;
                      })
                      .map(
                    (method) => RadioListTile<PaymentMethod>(
                      value: method,
                      groupValue: state.paymentMethod,
                      onChanged: (value) {
                        if (value == null) return;
                        context.read<BookingBloc>().add(
                              BookingPaymentMethodChanged(value),
                            );
                      },
                      title: Text(_paymentLabel(l10n, method)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.offerYourFare,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (estimate != null)
                    Text(
                      '${l10n.recommendedFareMinimum}: ${estimate.totalFare.toStringAsFixed(2)} ${AppConstants.currency}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 12),
                  if (estimate != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => context.read<BookingBloc>().add(
                                    const BookingOfferAdjusted(
                                      -BookingBloc.fareStep,
                                    ),
                                  ),
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.primary,
                            ),
                            Expanded(
                              child: Text(
                                '${(state.offeredFare ?? estimate.totalFare).toStringAsFixed(2)} ${AppConstants.currency}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.read<BookingBloc>().add(
                                    const BookingOfferAdjusted(
                                      BookingBloc.fareStep,
                                    ),
                                  ),
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: l10n.createRequest,
                    isLoading: state.status == BookingStatus.loading,
                    onPressed: estimate == null
                        ? null
                        : () => context.read<BookingBloc>().add(
                              const BookingSubmitRequested(),
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _paymentLabel(AppLocalizations l10n, PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => l10n.paymentCash,
      PaymentMethod.wallet => l10n.paymentWallet,
      PaymentMethod.card => l10n.paymentCard,
    };
  }

  /// Reconstruct display fares for chips from the currently selected estimate.
  String _fareForType(double selectedFare, String selectedType, String type) {
    final selectedMultiplier = switch (selectedType) {
      'comfort' => 1.35,
      'premium' => 1.75,
      _ => 1.0,
    };
    final base = selectedFare / selectedMultiplier;
    final multiplier = switch (type) {
      'comfort' => 1.35,
      'premium' => 1.75,
      _ => 1.0,
    };
    final fare = base * multiplier;
    return '${fare.toStringAsFixed(2)} ${AppConstants.currency}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))],
      ),
    );
  }
}

class _VehicleChip extends StatelessWidget {
  const _VehicleChip({
    required this.label,
    this.subtitle,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : Colors.black54,
              ),
            ),
          ],
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
    );
  }
}
