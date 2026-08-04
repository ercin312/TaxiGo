import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  List<RideModel> _rides = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await passengerGetIt<RideRepository>().getRideHistory();
    if (!mounted) return;
    result.fold(
      (error) => setState(() {
        _error = error;
        _loading = false;
      }),
      (rides) => setState(() {
        _rides = rides;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripHistory)),
      body: LoadingOverlay(
        isLoading: _loading,
        child: _error != null
            ? ErrorView(message: _error!, onRetry: _load)
            : _rides.isEmpty
                ? Center(child: Text(l10n.noTrips))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      itemCount: _rides.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final ride = _rides[index];
                        return ListTile(
                          leading: const Icon(Icons.local_taxi, color: AppColors.primary),
                          title: Text(ride.dropoffAddress),
                          subtitle: Text(
                            '${rideStatusLabel(l10n, ride.status)} • ${ride.reference}',
                          ),
                          trailing: ride.estimatedFare != null
                              ? Text(
                                  '${ride.estimatedFare!.toStringAsFixed(2)} ${AppConstants.currency}',
                                )
                              : null,
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
