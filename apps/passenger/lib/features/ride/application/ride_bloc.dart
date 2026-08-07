import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

abstract class RideEvent extends Equatable {
  const RideEvent();

  @override
  List<Object?> get props => [];
}

class RideWatchStarted extends RideEvent {
  const RideWatchStarted(this.rideId);

  final int rideId;

  @override
  List<Object?> get props => [rideId];
}

class RideStatusUpdated extends RideEvent {
  const RideStatusUpdated(this.status);

  final RideStatus status;

  @override
  List<Object?> get props => [status];
}

class RideDriverLocationUpdated extends RideEvent {
  const RideDriverLocationUpdated(this.location);

  final RideLocationModel location;

  @override
  List<Object?> get props => [location];
}

class RideRefreshRequested extends RideEvent {
  const RideRefreshRequested();
}

class RideCancelRequested extends RideEvent {
  const RideCancelRequested({this.reason});

  final String? reason;

  @override
  List<Object?> get props => [reason];
}

class RideRateSubmitted extends RideEvent {
  const RideRateSubmitted({required this.score, this.comment});

  final int score;
  final String? comment;

  @override
  List<Object?> get props => [score, comment];
}

class RideTripAnimationCompleted extends RideEvent {
  const RideTripAnimationCompleted();
}

class RideApproachCompleted extends RideEvent {
  const RideApproachCompleted();
}

class RideLocalSnapshotReceived extends RideEvent {
  const RideLocalSnapshotReceived(this.ride);

  final RideModel ride;

  @override
  List<Object?> get props => [ride];
}

class RideState extends Equatable {
  const RideState({
    this.status = RideBlocStatus.initial,
    this.ride,
    this.activeRideId,
    this.driverLocation,
    this.errorMessage,
    this.ratingSubmitted = false,
  });

  final RideBlocStatus status;
  final RideModel? ride;
  final int? activeRideId;
  final RideLocationModel? driverLocation;
  final String? errorMessage;
  final bool ratingSubmitted;

  RideState copyWith({
    RideBlocStatus? status,
    RideModel? ride,
    int? activeRideId,
    RideLocationModel? driverLocation,
    String? errorMessage,
    bool? ratingSubmitted,
    bool clearError = false,
  }) {
    return RideState(
      status: status ?? this.status,
      ride: ride ?? this.ride,
      activeRideId: activeRideId ?? this.activeRideId,
      driverLocation: driverLocation ?? this.driverLocation,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      ratingSubmitted: ratingSubmitted ?? this.ratingSubmitted,
    );
  }

  @override
  List<Object?> get props => [
        status,
        ride,
        activeRideId,
        driverLocation,
        errorMessage,
        ratingSubmitted,
      ];
}

enum RideBlocStatus { initial, loading, active, completed, cancelled, failure }

class RideBloc extends Bloc<RideEvent, RideState> {
  RideBloc({
    required RideRepository rideRepository,
    required RtdbService rtdbService,
  })  : _rideRepository = rideRepository,
        _rtdbService = rtdbService,
        super(const RideState()) {
    on<RideWatchStarted>(_onWatchStarted);
    on<RideStatusUpdated>(_onStatusUpdated);
    on<RideDriverLocationUpdated>(_onDriverLocationUpdated);
    on<RideRefreshRequested>(_onRefresh);
    on<RideCancelRequested>(_onCancel);
    on<RideRateSubmitted>(_onRate);
    on<RideTripAnimationCompleted>(_onTripAnimationCompleted);
    on<RideApproachCompleted>(_onApproachCompleted);
    on<RideLocalSnapshotReceived>(_onLocalSnapshot);
  }

  final RideRepository _rideRepository;
  final RtdbService _rtdbService;
  StreamSubscription<RideStatus>? _statusSub;
  StreamSubscription<RideLocationModel>? _locationSub;
  Timer? _localPollTimer;

  Future<void> _onWatchStarted(
    RideWatchStarted event,
    Emitter<RideState> emit,
  ) async {
    emit(state.copyWith(
      status: RideBlocStatus.loading,
      activeRideId: event.rideId,
      clearError: true,
    ));

    await _statusSub?.cancel();
    await _locationSub?.cancel();
    _localPollTimer?.cancel();

    if (FirebaseService.isInitialized) {
      _statusSub = _rtdbService.listenRideStatus(event.rideId).listen((status) {
        add(RideStatusUpdated(status));
      });
    }

    // Also poll — needed for local demo status progression without RTDB.
    _localPollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (isClosed) return;
      final latest = await _rideRepository.getRide(event.rideId);
      latest.fold((_) {}, (ride) {
        if (isClosed) return;
        if (state.ride?.status != ride.status ||
            state.ride?.driverId != ride.driverId) {
          add(RideLocalSnapshotReceived(ride));
        }
      });
    });

    final result = await _rideRepository.getRide(event.rideId);
    result.fold(
      (error) => emit(state.copyWith(
        status: RideBlocStatus.failure,
        errorMessage: error,
      )),
      (ride) {
        emit(state.copyWith(status: RideBlocStatus.active, ride: ride));
        _watchDriverLocation(ride);
      },
    );
  }

  void _watchDriverLocation(RideModel ride) {
    if (!FirebaseService.isInitialized) return;
    final driverId = ride.driverId;
    if (driverId == null) return;
    _locationSub?.cancel();
    _locationSub = _rtdbService.listenDriverLocation(driverId).listen(
      (location) => add(RideDriverLocationUpdated(location)),
    );
  }

  void _onDriverLocationUpdated(
    RideDriverLocationUpdated event,
    Emitter<RideState> emit,
  ) {
    emit(state.copyWith(driverLocation: event.location));
  }

  Future<void> _onStatusUpdated(
    RideStatusUpdated event,
    Emitter<RideState> emit,
  ) async {
    if (state.ride == null) return;
    final updated = state.ride!.copyWith(status: event.status);
    emit(state.copyWith(ride: updated));

    if (event.status == RideStatus.completed) {
      emit(state.copyWith(status: RideBlocStatus.completed));
    } else if (event.status == RideStatus.cancelledByPassenger ||
        event.status == RideStatus.cancelledByDriver ||
        event.status == RideStatus.expired) {
      emit(state.copyWith(status: RideBlocStatus.cancelled));
    }
  }

  Future<void> _onRefresh(
    RideRefreshRequested event,
    Emitter<RideState> emit,
  ) async {
    final rideId = state.activeRideId;
    if (rideId == null) return;
    add(RideWatchStarted(rideId));
  }

  Future<void> _onCancel(
    RideCancelRequested event,
    Emitter<RideState> emit,
  ) async {
    final rideId = state.activeRideId;
    if (rideId == null) return;

    emit(state.copyWith(status: RideBlocStatus.loading, clearError: true));
    final result =
        await _rideRepository.cancelRide(rideId, reason: event.reason);
    result.fold(
      (error) => emit(state.copyWith(
        status: RideBlocStatus.failure,
        errorMessage: error,
      )),
      (ride) => emit(state.copyWith(
        status: RideBlocStatus.cancelled,
        ride: ride,
      )),
    );
  }

  Future<void> _onRate(
    RideRateSubmitted event,
    Emitter<RideState> emit,
  ) async {
    final rideId = state.activeRideId;
    if (rideId == null) return;

    emit(state.copyWith(status: RideBlocStatus.loading, clearError: true));
    final result = await _rideRepository.rateRide(
      rideId,
      score: event.score,
      comment: event.comment,
    );
    result.fold(
      (error) => emit(state.copyWith(
        status: RideBlocStatus.failure,
        errorMessage: error,
      )),
      (_) => emit(state.copyWith(
        status: RideBlocStatus.completed,
        ratingSubmitted: true,
      )),
    );
  }

  void _onLocalSnapshot(
    RideLocalSnapshotReceived event,
    Emitter<RideState> emit,
  ) {
    final ride = event.ride;
    emit(state.copyWith(status: RideBlocStatus.active, ride: ride));
    if (ride.status == RideStatus.completed) {
      emit(state.copyWith(status: RideBlocStatus.completed));
    } else if (ride.status == RideStatus.cancelledByPassenger ||
        ride.status == RideStatus.cancelledByDriver ||
        ride.status == RideStatus.expired) {
      emit(state.copyWith(status: RideBlocStatus.cancelled));
    }
  }

  Future<void> _onApproachCompleted(
    RideApproachCompleted event,
    Emitter<RideState> emit,
  ) async {
    if (!AppConstants.allowDemoMode) return;
    final rideId = state.activeRideId;
    if (rideId == null) return;
    try {
      LocalDemoStore.instance.advance(rideId, RideStatus.driverArrived);
      LocalDemoStore.instance.advance(rideId, RideStatus.inProgress);
    } catch (_) {}
    final result = await _rideRepository.getRide(rideId);
    result.fold(
      (_) {},
      (ride) => emit(state.copyWith(
        status: RideBlocStatus.active,
        ride: ride.copyWith(
          status: RideStatus.inProgress,
          driverArrivedAt: DateTime.now(),
          startedAt: DateTime.now(),
        ),
      )),
    );
  }

  Future<void> _onTripAnimationCompleted(
    RideTripAnimationCompleted event,
    Emitter<RideState> emit,
  ) async {
    if (!AppConstants.allowDemoMode) return;
    final rideId = state.activeRideId;
    if (rideId == null) return;

    try {
      LocalDemoStore.instance.advance(rideId, RideStatus.completed);
    } catch (_) {}

    emit(state.copyWith(
      status: RideBlocStatus.completed,
      ride: state.ride?.copyWith(
        status: RideStatus.completed,
        completedAt: DateTime.now(),
        finalFare: state.ride?.finalFare ??
            state.ride?.offeredFare ??
            state.ride?.estimatedFare,
      ),
    ));
  }

  @override
  Future<void> close() async {
    await _statusSub?.cancel();
    await _locationSub?.cancel();
    _localPollTimer?.cancel();
    return super.close();
  }
}
