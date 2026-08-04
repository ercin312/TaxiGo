part of 'active_ride_bloc.dart';

sealed class ActiveRideEvent extends Equatable {
  const ActiveRideEvent();

  @override
  List<Object?> get props => [];
}

class ActiveRideStarted extends ActiveRideEvent {
  const ActiveRideStarted({this.rideId});

  final int? rideId;

  @override
  List<Object?> get props => [rideId];
}

class ActiveRideStatusUpdated extends ActiveRideEvent {
  const ActiveRideStatusUpdated(this.ride);

  final RideModel ride;

  @override
  List<Object?> get props => [ride];
}

class ActiveRideMarkArrived extends ActiveRideEvent {
  const ActiveRideMarkArrived();
}

class ActiveRideStartRide extends ActiveRideEvent {
  const ActiveRideStartRide();
}

class ActiveRideComplete extends ActiveRideEvent {
  const ActiveRideComplete();
}

class ActiveRideCancel extends ActiveRideEvent {
  const ActiveRideCancel({this.reason});

  final String? reason;

  @override
  List<Object?> get props => [reason];
}
