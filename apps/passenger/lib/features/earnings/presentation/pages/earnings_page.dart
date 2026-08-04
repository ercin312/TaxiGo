import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../application/earnings_bloc.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  Future<void> _showWithdrawDialog(
    BuildContext context,
    double balance,
  ) async {
    final amountController = TextEditingController(
      text: balance > 20 ? '20' : balance.toStringAsFixed(0),
    );
    final bankController = TextEditingController();
    final accountController = TextEditingController();
    final holderController = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Para çekme talebi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bakiye: ${balance.toStringAsFixed(2)} ${AppConstants.currency}'),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tutar'),
              ),
              TextField(
                controller: bankController,
                decoration: const InputDecoration(labelText: 'Banka'),
              ),
              TextField(
                controller: accountController,
                decoration: const InputDecoration(labelText: 'IBAN / Hesap'),
              ),
              TextField(
                controller: holderController,
                decoration: const InputDecoration(labelText: 'Hesap sahibi'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gönder'),
          ),
        ],
      ),
    );

    if (submitted != true || !context.mounted) return;

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final result = await passengerGetIt<WalletRepository>().requestWithdrawal(
      amount: amount,
      bankName: bankController.text.trim(),
      accountNumber: accountController.text.trim(),
      accountHolder: holderController.text.trim(),
    );

    if (!context.mounted) return;
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Para çekme talebi gönderildi.')),
        );
        context.read<EarningsBloc>().add(const EarningsLoadRequested());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.earnings)),
      body: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) {
          if (state is EarningsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EarningsFailure) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<EarningsBloc>().add(const EarningsLoadRequested());
              },
            );
          }

          if (state is! EarningsLoaded) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<EarningsBloc>().add(
                    EarningsPeriodChanged(state.period),
                  );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<EarningsPeriod>(
                  segments: [
                    ButtonSegment(
                      value: EarningsPeriod.daily,
                      label: Text(l10n.balance),
                    ),
                    ButtonSegment(
                      value: EarningsPeriod.weekly,
                      label: Text(l10n.transactions),
                    ),
                  ],
                  selected: {state.period},
                  onSelectionChanged: (selection) {
                    context.read<EarningsBloc>().add(
                          EarningsPeriodChanged(selection.first),
                        );
                  },
                ),
                const SizedBox(height: 24),
                _StatCard(
                  title: l10n.earnings,
                  value: state.totalEarnings.toStringAsFixed(2),
                  icon: Icons.payments,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: l10n.tripCompleted,
                        value: '${state.rideCount}',
                        icon: Icons.local_taxi,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: l10n.wallet,
                        value: state.walletBalance.toStringAsFixed(2),
                        icon: Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (passengerGetIt<FeatureModulesService>().withdrawals)
                  PrimaryButton(
                    label: 'Para Çek',
                    onPressed: () =>
                        _showWithdrawDialog(context, state.walletBalance),
                  ),
                const SizedBox(height: 24),
                Text(
                  l10n.rideHistory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (state.recentRides.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.noResults,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                    ),
                  )
                else
                  ...state.recentRides.map(
                    (ride) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.route, color: AppColors.primary),
                        ),
                        title: Text(ride.dropoffAddress),
                        subtitle: Text(
                          ride.completedAt?.toString().substring(0, 16) ?? '',
                        ),
                        trailing: Text(
                          ride.finalFare?.toStringAsFixed(2) ?? '--',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
