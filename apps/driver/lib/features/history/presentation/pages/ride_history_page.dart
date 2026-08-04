import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../core/l10n_extensions.dart';
import '../../application/history_bloc.dart';

class RideHistoryPage extends StatelessWidget {
  const RideHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rideHistory)),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistoryFailure) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<HistoryBloc>().add(const HistoryLoadRequested());
              },
            );
          }

          if (state is! HistoryLoaded) {
            return const SizedBox.shrink();
          }

          if (state.rides.isEmpty) {
            return Center(child: Text(l10n.noResults));
          }

          return ListView.builder(
            itemCount: state.rides.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.rides.length) {
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

              final ride = state.rides[index];
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
            },
          );
        },
      ),
    );
  }
}
