import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../core/l10n_extensions.dart';
import '../../../../di/locator.dart';
import '../../application/history_bloc.dart';

class DriverRideHistoryPage extends StatefulWidget {
  const DriverRideHistoryPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<DriverRideHistoryPage> createState() => _DriverRideHistoryPageState();
}

class _DriverRideHistoryPageState extends State<DriverRideHistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<RideModel> _planned = [];
  bool _plannedLoading = true;
  String? _plannedError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _loadPlanned();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadPlanned() async {
    setState(() {
      _plannedLoading = true;
      _plannedError = null;
    });
    final result = await passengerGetIt<DriverRepository>().getPlannedRides();
    if (!mounted) return;
    result.fold(
      (e) => setState(() {
        _plannedError = e;
        _plannedLoading = false;
      }),
      (rides) => setState(() {
        _planned = rides;
        _plannedLoading = false;
      }),
    );
  }

  Future<void> _claimPlanned(RideModel ride) async {
    final result = await passengerGetIt<DriverRepository>().acceptOffer(ride.id);
    if (!mounted) return;
    result.fold(
      (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yolculuk rezerve edildi')),
        );
        _loadPlanned();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rideHistory),
        bottom: TabBar(
          controller: _tabs,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(text: l10n.historyCompleted),
            Tab(text: l10n.historyUpcoming),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              if (state is HistoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HistoryFailure) {
                return ErrorView(
                  message: state.message,
                  onRetry: () {
                    context
                        .read<HistoryBloc>()
                        .add(const HistoryLoadRequested());
                  },
                );
              }
              if (state is! HistoryLoaded) {
                return const SizedBox.shrink();
              }
              final completed = state.rides
                  .where((r) => r.status == RideStatus.completed)
                  .toList();
              if (completed.isEmpty && !state.hasMore) {
                return Center(child: Text(l10n.noResults));
              }
              return ListView.builder(
                itemCount: completed.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == completed.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: OutlinedButton(
                          onPressed: () {
                            context
                                .read<HistoryBloc>()
                                .add(const HistoryLoadMore());
                          },
                          child: Text(l10n.next),
                        ),
                      ),
                    );
                  }
                  return _RideTile(ride: completed[index], l10n: l10n);
                },
              );
            },
          ),
          _PlannedList(
            loading: _plannedLoading,
            error: _plannedError,
            rides: _planned,
            l10n: l10n,
            onRetry: _loadPlanned,
            onClaim: _claimPlanned,
          ),
        ],
      ),
    );
  }
}

class _PlannedList extends StatelessWidget {
  const _PlannedList({
    required this.loading,
    required this.error,
    required this.rides,
    required this.l10n,
    required this.onRetry,
    required this.onClaim,
  });

  final bool loading;
  final String? error;
  final List<RideModel> rides;
  final AppLocalizations l10n;
  final VoidCallback onRetry;
  final ValueChanged<RideModel> onClaim;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return ErrorView(message: error!, onRetry: onRetry);
    }
    if (rides.isEmpty) {
      return Center(child: Text(l10n.noResults));
    }
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView.builder(
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          final reserved = ride.driverId != null;
          final when = ride.scheduledAt?.toLocal().toString().substring(0, 16) ??
              '';
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                child: Icon(
                  ride.productMode == 'transfer'
                      ? Icons.airport_shuttle
                      : Icons.event_available,
                  color: AppColors.accentDeep,
                ),
              ),
              title: Text(ride.dropoffAddress),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ride.pickupAddress),
                  Text(
                    when,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentDeep,
                        ),
                  ),
                  if (reserved)
                    Text(
                      'Rezerve',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                ],
              ),
              trailing: reserved
                  ? Text(
                      (ride.offeredFare ?? ride.estimatedFare)
                              ?.toStringAsFixed(2) ??
                          '--',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    )
                  : TextButton(
                      onPressed: () => onClaim(ride),
                      child: const Text('Al'),
                    ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

class _RideTile extends StatelessWidget {
  const _RideTile({required this.ride, required this.l10n});

  final RideModel ride;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(Icons.local_taxi, color: AppColors.primary),
        ),
        title: Text(ride.dropoffAddress),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ride.pickupAddress),
            Text(
              ride.completedAt?.toString().substring(0, 16) ??
                  ride.status.localized(l10n),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Text(
          ride.finalFare != null
              ? ride.finalFare!.toStringAsFixed(2)
              : ride.estimatedFare?.toStringAsFixed(2) ?? '--',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
