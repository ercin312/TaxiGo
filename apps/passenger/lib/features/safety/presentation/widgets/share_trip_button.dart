import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taxigo_core/taxigo_core.dart';

class ShareTripButton extends StatefulWidget {
  const ShareTripButton({
    super.key,
    required this.rideId,
    this.compact = true,
  });

  final int rideId;

  /// App-bar icon when true; full-width button when false.
  final bool compact;

  @override
  State<ShareTripButton> createState() => _ShareTripButtonState();
}

class _ShareTripButtonState extends State<ShareTripButton> {
  bool _busy = false;

  Future<void> _share() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);

    try {
      final result =
          await locator<RideRepository>().shareTrip(widget.rideId);
      if (!mounted) return;

      final url = result.rightOrNull;
      if (url == null || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.leftOrNull ?? 'Paylaşım linki alınamadı'),
          ),
        );
        return;
      }

      final message = '${l10n.shareTripMessage}\n$url';
      final box = context.findRenderObject() as RenderBox?;
      final origin = (box != null && box.hasSize)
          ? box.localToGlobal(Offset.zero) & box.size
          : const Rect.fromLTWH(0, 0, 1, 1);

      try {
        await Share.share(
          message,
          subject: l10n.shareTrip,
          sharePositionOrigin: origin,
        );
      } catch (_) {
        await Clipboard.setData(ClipboardData(text: message));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paylaşım linki panoya kopyalandı'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!locator<FeatureModulesService>().shareTrip) {
      return const SizedBox.shrink();
    }

    if (widget.compact) {
      return IconButton(
        tooltip: l10n.shareTrip,
        onPressed: _busy ? null : _share,
        icon: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.share),
      );
    }

    return OutlinedButton.icon(
      onPressed: _busy ? null : _share,
      icon: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.ios_share),
      label: Text(l10n.shareTrip),
    );
  }
}
