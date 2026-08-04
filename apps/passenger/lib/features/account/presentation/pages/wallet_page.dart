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
    final walletRepo = passengerGetIt<WalletRepository>();
    final walletResult = await walletRepo.getWallet();
    final txResult = await walletRepo.getTransactions();
    if (!mounted) return;
    walletResult.fold(
      (error) => setState(() {
        _error = error;
        _loading = false;
      }),
      (wallet) {
        txResult.fold(
          (error) => setState(() {
            _wallet = wallet;
            _error = error;
            _loading = false;
          }),
          (txs) => setState(() {
            _wallet = wallet;
            _transactions = txs;
            _loading = false;
          }),
        );
      },
    );
  }

  Future<void> _topUp() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await passengerGetIt<WalletRepository>().topUp(10);
    if (!mounted) return;
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.topUp)),
        );
        _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wallet)),
      body: LoadingOverlay(
        isLoading: _loading,
        child: _error != null
            ? ErrorView(message: _error!, onRetry: _load)
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(l10n.balance),
                            const SizedBox(height: 8),
                            Text(
                              '${_wallet?.balance.toStringAsFixed(2) ?? '0.00'} ${_wallet?.currency ?? AppConstants.currency}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: l10n.topUp,
                              onPressed: _topUp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.transactions, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_transactions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(l10n.noTrips, textAlign: TextAlign.center),
                      )
                    else
                      ..._transactions.map(
                        (tx) => ListTile(
                          title: Text(tx.description ?? tx.type),
                          subtitle: Text(tx.description ?? tx.type),
                          trailing: Text(
                            '${tx.amount >= 0 ? '+' : ''}${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: tx.amount >= 0 ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.bold,
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
