import 'package:taxigo_core/taxigo_core.dart';

/// Maps ride status localization keys to [AppLocalizations] getters.
extension RideStatusL10n on RideStatus {
  String localized(AppLocalizations l10n) => switch (this) {
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

extension DocumentTypeL10n on DocumentType {
  String localized(AppLocalizations l10n) => switch (this) {
        DocumentType.identity => l10n.documentIdentity,
        DocumentType.license => l10n.documentLicense,
        DocumentType.registration => l10n.documentRegistration,
        DocumentType.vehiclePhoto => l10n.documentVehiclePhoto,
      };
}
