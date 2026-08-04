import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'local_notification_service.dart';

/// Delivers OTP codes via device notification (production flow, no SMS).
class OtpDeliveryService {
  OtpDeliveryService(this._notifications);

  final LocalNotificationService _notifications;

  Future<void> deliver({
    required BuildContext context,
    required String code,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    await _notifications.showOtpCode(
      code,
      title: l10n.otpNotificationTitle,
      body: l10n.otpNotificationBody(code),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.otpNotificationSent),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
