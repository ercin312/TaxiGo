import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  final _codeController = TextEditingController();
  PromoModel? _result;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    final result = await passengerGetIt<WalletRepository>().validatePromoCode(code);
    if (!mounted) return;
    result.fold(
      (error) => setState(() {
        _error = error;
        _loading = false;
      }),
      (promo) => setState(() {
        _result = promo;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.promos)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l10n.enterPromoCode,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _loading ? null : _validate,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            if (_result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _result!.code,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result!.isValid ? l10n.promoApplied : l10n.invalidPromo,
                        style: TextStyle(
                          color: _result!.isValid ? AppColors.success : AppColors.error,
                        ),
                      ),
                      if (_result!.discountAmount != null &&
                          _result!.discountAmount! > 0)
                        Text(
                          '-${_result!.discountAmount!.toStringAsFixed(2)} ${AppConstants.currency}',
                        ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            PrimaryButton(
              label: l10n.applyPromo,
              isLoading: _loading,
              onPressed: _validate,
            ),
          ],
        ),
      ),
    );
  }
}
