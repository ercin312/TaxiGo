import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';
import '../../../shell/presentation/widgets/empty_state_panel.dart';
import '../../../shell/presentation/widgets/soft_card.dart';
import '../widgets/trip_actions_sheet.dart';

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({
    super.key,
    this.initialTabIndex = 0,
    this.highlightRideId,
  });

  /// 0 = completed, 1 = upcoming, 2 = cancelled
  final int initialTabIndex;

  /// Just-scheduled ride id — ensures it appears even if history cache is stale.
  final int? highlightRideId;

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<RideModel> _rides = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTabIndex.clamp(0, 2);
    _tabs = TabController(length: 3, vsync: this, initialIndex: initial);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await passengerGetIt<RideRepository>().getRideHistory();
    if (!mounted) return;
    await result.fold(
      (error) async => setState(() {
        _error = error;
        _loading = false;
      }),
      (rides) async {
        var merged = List<RideModel>.from(rides);
        final highlightId = widget.highlightRideId;
        if (highlightId != null &&
            !merged.any((r) => r.id == highlightId)) {
          final one = await passengerGetIt<RideRepository>().getRide(highlightId);
          one.fold((_) {}, (ride) => merged = [ride, ...merged]);
        }
        if (!mounted) return;
        setState(() {
          _rides = merged;
          _loading = false;
        });
      },
    );
  }

  List<RideModel> _filter(int index) {
    switch (index) {
      case 1:
        final upcoming = _rides.where((r) {
          if (r.scheduledAt == null) return false;
          if (!r.scheduledAt!.isAfter(DateTime.now())) return false;
          return !r.status.isTerminal;
        }).toList();
        upcoming.sort((a, b) {
          final aa = a.scheduledAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bb = b.scheduledAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aa.compareTo(bb);
        });
        return upcoming;
      case 2:
        return _rides
            .where((r) =>
                r.status == RideStatus.cancelledByPassenger ||
                r.status == RideStatus.cancelledByDriver ||
                r.status == RideStatus.expired)
            .toList();
      default:
        return _rides.where((r) => r.status == RideStatus.completed).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                l10n.tripHistory,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.mist.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBar(
                  controller: _tabs,
                  onTap: (_) => setState(() {}),
                  indicator: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelColor: AppColors.accent,
                  unselectedLabelColor: AppColors.textSecondaryLight,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: l10n.historyCompleted),
                    Tab(text: l10n.historyUpcoming),
                    Tab(text: l10n.historyCancelled),
                  ],
                ),
              ),
            ),
            Expanded(
              child: LoadingOverlay(
                isLoading: _loading,
                child: _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : AnimatedBuilder(
                        animation: _tabs,
                        builder: (context, _) {
                          final items = _filter(_tabs.index);
                          if (items.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 80 + bottomInset),
                              child: EmptyStatePanel(
                                icon: _tabs.index == 1
                                    ? Icons.event_available_outlined
                                    : Icons.history_rounded,
                                illustrationAsset: AppImages.historyEmpty,
                                title: _tabs.index == 1
                                    ? l10n.noUpcomingTrips
                                    : _tabs.index == 2
                                        ? l10n.noCancelledTrips
                                        : l10n.noCompletedTrips,
                                subtitle: _tabs.index == 1
                                    ? l10n.noUpcomingTripsHint
                                    : l10n.noTrips,
                                ctaLabel: l10n.createNewTrip,
                                onCta: () => context.go('/home'),
                                tip: _tabs.index == 1 ? l10n.upcomingTip : null,
                              ),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                100 + bottomInset,
                              ),
                              itemCount: items.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final ride = items[index];
                                return SoftCard(
                                  onTap: () => showTripActionsSheet(
                                    context,
                                    ride: ride,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.local_taxi_rounded,
                                        color: AppColors.ink,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ride.dropoffAddress,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              '${rideStatusLabel(l10n, ride.status)} · ${ride.reference}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            if (ride.scheduledAt != null)
                                              Text(
                                                ride.scheduledAt!
                                                    .toLocal()
                                                    .toString()
                                                    .substring(0, 16),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors
                                                          .accentDeep,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if ((ride.finalFare ??
                                                  ride.estimatedFare) !=
                                              null)
                                            Text(
                                              '${(ride.finalFare ?? ride.estimatedFare)!.toStringAsFixed(2)} ${AppConstants.currency}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                          if (ride.status ==
                                              RideStatus.completed)
                                            Text(
                                              l10n.rideAgain,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors.accentDeep,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
