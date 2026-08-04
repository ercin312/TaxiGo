import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taxigo_core/taxigo_core.dart';

class ShareTripButton extends StatelessWidget {
  const ShareTripButton({super.key, required this.rideId});

  final int rideId;

  Future<void> _share(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final api = locator<ApiClient>();
      final response = await api.post<Map<String, dynamic>>(
        ApiEndpoints.rideShare(rideId),
      );
      final url = response.data?['share_url'] as String? ?? '';
      if (url.isEmpty) return;
      await Share.share('${l10n.shareTripMessage}\n$url');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!locator<FeatureModulesService>().shareTrip) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: l10n.shareTrip,
      onPressed: () => _share(context),
      icon: const Icon(Icons.share),
    );
  }
}
