import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  WalletModel? _wallet;
  List<WalletTransactionModel> _transactions = [];
  bool _loading = true;
  String? _error;
  bool _topUpEnabled = false;
  final List<double> _presets = const [5, 10, 20, 50, 100];
  double? _selectedAmount;
  bool _topUpBusy = false;

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

    final modules = passengerGetIt<FeatureModulesService>();
    await modules.refresh(force: true);

    final walletRepo = passengerGetIt<WalletRepository>();
    final walletResult = await walletRepo.getWallet();
    final txResult = await walletRepo.getTransactions();
    if (!mounted) return;

    walletResult.fold(
      (error) => setState(() {
        _error = error;
        _loading = false;
        _topUpEnabled = modules.walletTopUp;
      }),
      (wallet) {
        txResult.fold(
          (error) => setState(() {
            _wallet = wallet;
            _error = error;
            _loading = false;
            _topUpEnabled = modules.walletTopUp;
            _selectedAmount ??=
                _presets.isNotEmpty ? _presets.first : AppConstants.minTopUp;
          }),
          (txs) => setState(() {
            _wallet = wallet;
            _transactions = txs;
            _loading = false;
            _topUpEnabled = modules.walletTopUp;
            _selectedAmount ??=
                _presets.isNotEmpty ? _presets.first : AppConstants.minTopUp;
          }),
        );
      },
    );
  }

  Future<void> _confirmTopUp() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = _selectedAmount;
    if (amount == null || amount < AppConstants.minTopUp) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.topUp),
        content: Text(
          l10n.topUpConfirm(amount.toStringAsFixed(2), AppConstants.currency),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _topUpBusy = true);
    final result = await passengerGetIt<WalletRepository>().topUp(amount);
    if (!mounted) return;
    setState(() => _topUpBusy = false);

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.topUpSuccess)),
        );
        _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = _wallet?.currency ?? AppConstants.currency;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.wallet),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: LoadingOverlay(
        isLoading: _loading || _topUpBusy,
        child: _error != null && _wallet == null
            ? ErrorView(message: _error!, onRetry: _load)
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ink.withValues(alpha: 0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.balance,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_wallet?.balance.toStringAsFixed(2) ?? '0.00'} $currency',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_topUpEnabled) ...[
                      Text(
                        l10n.topUp,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.topUpHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _presets.map((amount) {
                          final selected = _selectedAmount == amount;
                          return ChoiceChip(
                            label: Text(
                              '${amount.toStringAsFixed(0)} $currency',
                            ),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _selectedAmount = amount),
                            selectedColor: AppColors.ink,
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: l10n.topUp,
                        icon: Icons.add_card_rounded,
                        isLoading: _topUpBusy,
                        onPressed: _confirmTopUp,
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.mist.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.topUpDisabled,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Text(
                      l10n.transactions,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (_transactions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.noTrips,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    else
                      ..._transactions.map(
                        (tx) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              tx.amount >= 0
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: tx.amount >= 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            title: Text(tx.description ?? tx.type),
                            subtitle: Text(
                              tx.createdAt?.toString().substring(0, 16) ?? '',
                            ),
                            trailing: Text(
                              '${tx.amount >= 0 ? '+' : ''}${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: tx.amount >= 0
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
