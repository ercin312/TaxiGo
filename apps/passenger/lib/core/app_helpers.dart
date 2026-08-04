import 'package:taxigo_core/taxigo_core.dart';

bool isProfileComplete(UserModel? user) {
  if (user == null) return false;
  final name = user.name.trim();
  if (name.isEmpty) return false;
  if (name.toLowerCase() == 'user') return false;
  if (RegExp(r'^user\s', caseSensitive: false).hasMatch(name)) return false;
  return true;
}

String rideStatusLabel(AppLocalizations l10n, RideStatus status) {
  return switch (status) {
    RideStatus.pending => l10n.rideStatusPending,
    RideStatus.driverAssigned => l10n.rideStatusDriverAssigned,
    RideStatus.driverArriving => l10n.rideStatusDriverArriving,
    RideStatus.driverArrived => l10n.rideStatusDriverArrived,
    RideStatus.passengerOnBoard => l10n.rideStatusPassengerOnBoard,
    RideStatus.inProgress => l10n.rideStatusInProgress,
    RideStatus.completed => l10n.rideStatusCompleted,
    RideStatus.cancelledByPassenger => l10n.rideStatusCancelledPassenger,
    RideStatus.cancelledByDriver => l10n.rideStatusCancelledDriver,
    RideStatus.expired => l10n.rideStatusExpired,
  };
}
