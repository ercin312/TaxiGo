import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../application/ride_bloc.dart';

class RideCompletedPage extends StatefulWidget {
  const RideCompletedPage({super.key, required this.rideId});

  final int rideId;

  @override
  State<RideCompletedPage> createState() => _RideCompletedPageState();
}

class _RideCompletedPageState extends State<RideCompletedPage> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) =>
          passengerGetIt<RideBloc>()..add(RideWatchStarted(widget.rideId)),
      child: BlocConsumer<RideBloc, RideState>(
        listener: (context, state) {
          if (state.ratingSubmitted) {
            context.go('/home');
          } else if (state.status == RideBlocStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.tripCompleted)),
            body: LoadingOverlay(
              isLoading: state.status == RideBlocStatus.loading,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.check_circle, size: 80, color: AppColors.success),
                    const SizedBox(height: 24),
                    Text(
                      l10n.rateDriver,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          onPressed: () => setState(() => _rating = star),
                          icon: Icon(
                            star <= _rating ? Icons.star : Icons.star_border,
                            color: AppColors.secondary,
                            size: 40,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.complaintDescription,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: l10n.submitRating,
                      onPressed: () {
                        context.read<RideBloc>().add(
                              RideRateSubmitted(
                                score: _rating,
                                comment: _commentController.text.trim().isEmpty
                                    ? null
                                    : _commentController.text.trim(),
                              ),
                            );
                      },
                    ),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: Text(l10n.skip),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
