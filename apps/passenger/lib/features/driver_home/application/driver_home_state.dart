part of 'driver_home_bloc.dart';

sealed class DriverHomeState extends Equatable {
  const DriverHomeState();

  @override
  List<Object?> get props => [];
}

class DriverHomeInitial extends DriverHomeState {
  const DriverHomeInitial();
}

class DriverHomeLoading extends DriverHomeState {
  const DriverHomeLoading();
}

class DriverHomeNotApproved extends DriverHomeState {
  const DriverHomeNotApproved(this.driver);

  final DriverModel driver;

  @override
  List<Object?> get props => [driver];
}

class DriverHomeReady extends DriverHomeState {
  const DriverHomeReady({
    required this.driver,
    required this.isOnline,
    this.activeRide,
    this.incomingRide,
    this.currentPosition,
    this.todayEarnings = 0,
    this.isTogglingOnline = false,
    this.isProcessingRide = false,
    this.successMessage,
  });

  final DriverModel driver;
  final bool isOnline;
  final RideModel? activeRide;
  final RideModel? incomingRide;
  final Position? currentPosition;
  final double todayEarnings;
  final bool isTogglingOnline;
  final bool isProcessingRide;
  final String? successMessage;

  DriverHomeReady copyWith({
    DriverModel? driver,
    bool? isOnline,
    RideModel? activeRide,
    RideModel? incomingRide,
    Position? currentPosition,
    double? todayEarnings,
    bool? isTogglingOnline,
    bool? isProcessingRide,
    String? successMessage,
    bool clearIncomingRide = false,
    bool clearActiveRide = false,
    bool clearSuccessMessage = false,
  }) {
    return DriverHomeReady(
      driver: driver ?? this.driver,
      isOnline: isOnline ?? this.isOnline,
      activeRide: clearActiveRide ? null : (activeRide ?? this.activeRide),
      incomingRide:
          clearIncomingRide ? null : (incomingRide ?? this.incomingRide),
      currentPosition: currentPosition ?? this.currentPosition,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      isTogglingOnline: isTogglingOnline ?? this.isTogglingOnline,
      isProcessingRide: isProcessingRide ?? this.isProcessingRide,
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        driver,
        isOnline,
        activeRide,
        incomingRide,
        currentPosition,
        todayEarnings,
        isTogglingOnline,
        isProcessingRide,
        successMessage,
      ];
}

class DriverHomeFailure extends DriverHomeState {
  const DriverHomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
