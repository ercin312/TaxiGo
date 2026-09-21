import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taxigo_core/taxigo_core.dart';

/// Full-screen e-receipt for completed rides.
class RideReceiptPage extends StatefulWidget {
  const RideReceiptPage({super.key, required this.rideId});

  final int rideId;

  @override
  State<RideReceiptPage> createState() => _RideReceiptPageState();
}

class _RideReceiptPageState extends State<RideReceiptPage> {
  RideReceiptModel? _receipt;
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
    final result = await locator<RideRepository>().getReceipt(widget.rideId);
    if (!mounted) return;
    result.fold(
      (e) => setState(() {
        _error = e;
        _loading = false;
      }),
      (r) => setState(() {
        _receipt = r;
        _loading = false;
      }),
    );
  }

  Future<void> _share() async {
    final receipt = _receipt;
    if (receipt == null) return;
    final l10n = AppLocalizations.of(context)!;
    final box = context.findRenderObject() as RenderBox?;
    final origin = (box != null && box.hasSize)
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 1, 1);
    try {
      await Share.share(
        receipt.toShareText(),
        subject: '${l10n.eReceipt} ${receipt.receiptNumber}',
        sharePositionOrigin: origin,
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: receipt.toShareText()));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.receiptCopied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final receipt = _receipt;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.eReceipt),
        backgroundColor: AppColors.backgroundLight,
        actions: [
          if (receipt != null)
            IconButton(
              tooltip: l10n.shareReceipt,
              onPressed: _share,
              icon: const Icon(Icons.ios_share_rounded),
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: _error != null
            ? ErrorView(message: _error!, onRetry: _load)
            : receipt == null
                ? const SizedBox.shrink()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    receipt.companyName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.ink,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    l10n.eReceiptBadge,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (receipt.companyAddress != null)
                              Text(
                                receipt.companyAddress!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (receipt.companyTaxId != null)
                              Text(
                                '${l10n.taxId}: ${receipt.companyTaxId}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            const SizedBox(height: 8),
                            Text(
                              receipt.receiptNumber,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const Divider(height: 28),
                            _ReceiptRow(
                              label: l10n.tripReference,
                              value: receipt.rideReference,
                            ),
                            _ReceiptRow(
                              label: l10n.pickupLocation,
                              value: receipt.pickupAddress,
                            ),
                            _ReceiptRow(
                              label: l10n.dropoffLocation,
                              value: receipt.dropoffAddress,
                            ),
                            if (receipt.completedAt != null)
                              _ReceiptRow(
                                label: l10n.completedAt,
                                value: receipt.completedAt!
                                    .toLocal()
                                    .toString()
                                    .substring(0, 16),
                              ),
                            if (receipt.distanceKm != null)
                              _ReceiptRow(
                                label: l10n.distance,
                                value:
                                    '${receipt.distanceKm!.toStringAsFixed(1)} km',
                              ),
                            if (receipt.durationMinutes != null)
                              _ReceiptRow(
                                label: l10n.duration,
                                value: '${receipt.durationMinutes} min',
                              ),
                            if (receipt.driverName != null)
                              _ReceiptRow(
                                label: l10n.driverGeneric,
                                value: receipt.driverName!,
                              ),
                            if (receipt.vehiclePlate != null)
                              _ReceiptRow(
                                label: l10n.vehiclePlate,
                                value: receipt.vehiclePlate!,
                              ),
                            _ReceiptRow(
                              label: l10n.paymentMethod,
                              value: (receipt.paymentMethod ?? 'cash')
                                  .toUpperCase(),
                            ),
                            const Divider(height: 28),
                            if (receipt.subtotal != null)
                              _ReceiptRow(
                                label: l10n.subtotal,
                                value:
                                    '${receipt.subtotal!.toStringAsFixed(2)} ${receipt.currency}',
                              ),
                            if (receipt.discount != null &&
                                receipt.discount! > 0)
                              _ReceiptRow(
                                label: l10n.discount,
                                value:
                                    '-${receipt.discount!.toStringAsFixed(2)} ${receipt.currency}',
                              ),
                            _ReceiptRow(
                              label: l10n.total,
                              value:
                                  '${receipt.total.toStringAsFixed(2)} ${receipt.currency}',
                              emphasize: true,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.receiptExpenseHint,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: l10n.shareReceipt,
                        icon: Icons.ios_share_rounded,
                        onPressed: _share,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                fontSize: emphasize ? 18 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
