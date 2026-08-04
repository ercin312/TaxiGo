part of 'driver_home_bloc.dart';

sealed class DriverHomeEvent extends Equatable {
  const DriverHomeEvent();

  @override
  List<Object?> get props => [];
}

class DriverHomeStarted extends DriverHomeEvent {
  const DriverHomeStarted();
}

class DriverHomeToggleOnline extends DriverHomeEvent {
  const DriverHomeToggleOnline();
}

class DriverHomeLocationUpdated extends DriverHomeEvent {
  const DriverHomeLocationUpdated(this.position);

  final Position position;

  @override
  List<Object?> get props => [position];
}

class DriverHomeIncomingRideReceived extends DriverHomeEvent {
  const DriverHomeIncomingRideReceived(this.ride);

  final RideModel ride;

  @override
  List<Object?> get props => [ride];
}

class DriverHomeAcceptRide extends DriverHomeEvent {
  const DriverHomeAcceptRide();
}

class DriverHomeRejectRide extends DriverHomeEvent {
  const DriverHomeRejectRide();
}

class DriverHomeDismissIncoming extends DriverHomeEvent {
  const DriverHomeDismissIncoming();
}

class DriverHomeRefreshEarnings extends DriverHomeEvent {
  const DriverHomeRefreshEarnings();
}
