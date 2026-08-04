/// Ride lifecycle statuses aligned with the backend API.
enum RideStatus {
  pending('pending'),
  driverAssigned('driver_assigned'),
  driverArriving('driver_arriving'),
  driverArrived('driver_arrived'),
  passengerOnBoard('passenger_on_board'),
  inProgress('in_progress'),
  completed('completed'),
  cancelledByPassenger('cancelled_by_passenger'),
  cancelledByDriver('cancelled_by_driver'),
  expired('expired');

  const RideStatus(this.value);

  final String value;

  static RideStatus fromString(String? raw) {
    return RideStatus.values.firstWhere(
      (status) => status.value == raw,
      orElse: () => RideStatus.pending,
    );
  }

  /// Localization key in [AppLocalizations] for this status.
  String get displayKey => switch (this) {
        RideStatus.pending => 'rideStatusPending',
        RideStatus.driverAssigned => 'rideStatusDriverAssigned',
        RideStatus.driverArriving => 'rideStatusDriverArriving',
        RideStatus.driverArrived => 'rideStatusDriverArrived',
        RideStatus.passengerOnBoard => 'rideStatusPassengerOnBoard',
        RideStatus.inProgress => 'rideStatusInProgress',
        RideStatus.completed => 'rideStatusCompleted',
        RideStatus.cancelledByPassenger => 'rideStatusCancelledByPassenger',
        RideStatus.cancelledByDriver => 'rideStatusCancelledByDriver',
        RideStatus.expired => 'rideStatusExpired',
      };

  bool get isTerminal => switch (this) {
        RideStatus.completed ||
        RideStatus.cancelledByPassenger ||
        RideStatus.cancelledByDriver ||
        RideStatus.expired =>
          true,
        _ => false,
      };

  bool get isActive => !isTerminal;
}
