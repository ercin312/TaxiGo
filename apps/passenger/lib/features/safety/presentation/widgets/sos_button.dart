import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxigo_core/taxigo_core.dart';

class SosButton extends StatelessWidget {
  const SosButton({super.key, this.rideId});

  final int? rideId;

  Future<void> _sendSos(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sos),
        content: Text(l10n.sosConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.no)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.yes)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final position = await Geolocator.getCurrentPosition();
      final api = locator<ApiClient>();
      await api.post(
        ApiEndpoints.safetySos,
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          if (rideId != null) 'ride_id': rideId,
        },
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.sosSent)),
        );
      }
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
    if (!locator<FeatureModulesService>().sosAlerts) {
      return const SizedBox.shrink();
    }

    return Material(
      color: AppColors.error,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _sendSos(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            l10n.sos,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
