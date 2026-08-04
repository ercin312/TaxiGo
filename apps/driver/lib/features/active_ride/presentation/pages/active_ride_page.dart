import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n_extensions.dart';
import '../../application/active_ride_bloc.dart';

class ActiveRidePage extends StatelessWidget {
  const ActiveRidePage({super.key});

  Future<void> _openNavigation(RideModel ride) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${ride.pickupLatitude},${ride.pickupLongitude}&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ActiveRideBloc, ActiveRideState>(
      listener: (context, state) {
        if (state is ActiveRideCompleted || state is ActiveRideEmpty) {
          context.go('/home');
        } else if (state is ActiveRideFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is ActiveRideLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is! ActiveRideLoaded) {
          return Scaffold(
            body: Center(child: Text(l10n.noActiveRide)),
          );
        }

        final ride = state.ride;
        final pickup = LatLng(ride.pickupLatitude, ride.pickupLongitude);
        final dropoff = LatLng(ride.dropoffLatitude, ride.dropoffLongitude);

        return LoadingOverlay(
          isLoading: state.isProcessing,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.activeRide),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: pickup,
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('pickup'),
                        position: pickup,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                      ),
                      Marker(
                        markerId: const MarkerId('dropoff'),
                        position: dropoff,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Chip(
                          label: Text(ride.status.localized(l10n)),
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.trip_origin),
                          title: Text(l10n.pickupLocation),
                          subtitle: Text(ride.pickupAddress),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(l10n.dropoffLocation),
                          subtitle: Text(ride.dropoffAddress),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _openNavigation(ride),
                          icon: const Icon(Icons.navigation),
                          label: Text(l10n.mapTitle),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButtons(context, ride, l10n),
                      ],
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

  Widget _buildActionButtons(
    BuildContext context,
    RideModel ride,
    AppLocalizations l10n,
  ) {
    switch (ride.status) {
      case RideStatus.driverAssigned:
      case RideStatus.driverArriving:
        return PrimaryButton(
          label: l10n.driverArrived,
          onPressed: () {
            context.read<ActiveRideBloc>().add(const ActiveRideMarkArrived());
          },
        );
      case RideStatus.driverArrived:
        return PrimaryButton(
          label: l10n.startTrip,
          onPressed: () {
            context.read<ActiveRideBloc>().add(const ActiveRideStartRide());
          },
        );
      case RideStatus.passengerOnBoard:
      case RideStatus.inProgress:
        return PrimaryButton(
          label: l10n.completeTrip,
          onPressed: () {
            context.read<ActiveRideBloc>().add(const ActiveRideComplete());
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
