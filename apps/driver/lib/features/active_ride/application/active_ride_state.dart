part of 'active_ride_bloc.dart';

sealed class ActiveRideState extends Equatable {
  const ActiveRideState();

  @override
  List<Object?> get props => [];
}

class ActiveRideInitial extends ActiveRideState {
  const ActiveRideInitial();
}

class ActiveRideLoading extends ActiveRideState {
  const ActiveRideLoading();
}

class ActiveRideEmpty extends ActiveRideState {
  const ActiveRideEmpty();
}

class ActiveRideLoaded extends ActiveRideState {
  const ActiveRideLoaded({
    required this.ride,
    this.isProcessing = false,
  });

  final RideModel ride;
  final bool isProcessing;

  ActiveRideLoaded copyWith({
    RideModel? ride,
    bool? isProcessing,
  }) {
    return ActiveRideLoaded(
      ride: ride ?? this.ride,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [ride, isProcessing];
}

class ActiveRideCompleted extends ActiveRideState {
  const ActiveRideCompleted(this.ride);

  final RideModel ride;

  @override
  List<Object?> get props => [ride];
}

class ActiveRideFailure extends ActiveRideState {
  const ActiveRideFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
