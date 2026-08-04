import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../application/driver_home_bloc.dart';
import '../widgets/incoming_ride_request_sheet.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<DriverHomeBloc, DriverHomeState>(
      listener: (context, state) {
        if (state is DriverHomeNotApproved) {
          context.go('/pending');
        } else if (state is DriverHomeReady && state.activeRide != null) {
          context.push('/active-ride', extra: state.activeRide!.id);
        } else if (state is DriverHomeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is DriverHomeLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DriverHomeFailure) {
          return Scaffold(
            body: ErrorView(
              message: state.message,
              onRetry: () {
                context.read<DriverHomeBloc>().add(const DriverHomeStarted());
              },
            ),
          );
        }

        if (state is! DriverHomeReady) {
          return const SizedBox.shrink();
        }

        final position = state.currentPosition;
        final initialTarget = position != null
            ? LatLng(position.latitude, position.longitude)
            : const LatLng(40.4093, 49.8671);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.driverMode),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () => context.push('/account'),
              ),
            ],
          ),
          drawer: _DriverDrawer(
            onEarnings: () => context.push('/earnings'),
            onHistory: () => context.push('/history'),
            onRatings: () => context.push('/ratings'),
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _EarningsSummaryCard(earnings: state.todayEarnings),
              ),
              if (state.incomingRide != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IncomingRideRequestSheet(
                    ride: state.incomingRide!,
                    onAccept: () {
                      context.read<DriverHomeBloc>().add(
                            const DriverHomeAcceptRide(),
                          );
                    },
                    onReject: () {
                      context.read<DriverHomeBloc>().add(
                            const DriverHomeRejectRide(),
                          );
                    },
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.isTogglingOnline
                ? null
                : () {
                    if (!state.driver.isApproved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.approvalPending)),
                      );
                      return;
                    }
                    context.read<DriverHomeBloc>().add(
                          const DriverHomeToggleOnline(),
                        );
                  },
            backgroundColor:
                state.isOnline ? Colors.red.shade600 : AppColors.primary,
            icon: Icon(state.isOnline ? Icons.stop : Icons.play_arrow),
            label: Text(
              state.isTogglingOnline
                  ? l10n.loading
                  : state.isOnline
                      ? l10n.goOffline
                      : l10n.goOnline,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _EarningsSummaryCard extends StatelessWidget {
  const _EarningsSummaryCard({required this.earnings});

  final double earnings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.payments, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.earnings,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    earnings.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<DriverHomeBloc>().add(
                      const DriverHomeRefreshEarnings(),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverDrawer extends StatelessWidget {
  const _DriverDrawer({
    required this.onEarnings,
    required this.onHistory,
    required this.onRatings,
  });

  final VoidCallback onEarnings;
  final VoidCallback onHistory;
  final VoidCallback onRatings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.local_taxi, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                Text(
                  l10n.driverMode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payments),
            title: Text(l10n.earnings),
            onTap: () {
              Navigator.pop(context);
              onEarnings();
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l10n.rideHistory),
            onTap: () {
              Navigator.pop(context);
              onHistory();
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text(l10n.rateRide),
            onTap: () {
              Navigator.pop(context);
              onRatings();
            },
          ),
        ],
      ),
    );
  }
}
