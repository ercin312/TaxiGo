import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

part 'active_ride_event.dart';
part 'active_ride_state.dart';

class ActiveRideBloc extends Bloc<ActiveRideEvent, ActiveRideState> {
  ActiveRideBloc({
    required DriverRepository driverRepository,
    required RtdbService rtdbService,
  })  : _driverRepository = driverRepository,
        _rtdbService = rtdbService,
        super(const ActiveRideInitial()) {
    on<ActiveRideStarted>(_onStarted);
    on<ActiveRideStatusUpdated>(_onStatusUpdated);
    on<ActiveRideMarkArrived>(_onMarkArrived);
    on<ActiveRideStartRide>(_onStartRide);
    on<ActiveRideComplete>(_onComplete);
  }

  final DriverRepository _driverRepository;
  final RtdbService _rtdbService;
  StreamSubscription<RideStatus>? _statusSubscription;

  Future<void> _onStarted(
    ActiveRideStarted event,
    Emitter<ActiveRideState> emit,
  ) async {
    emit(const ActiveRideLoading());

    final result = await _driverRepository.getActiveRide();

    await result.fold(
      (message) async => emit(ActiveRideFailure(message)),
      (ride) async {
        if (ride == null) {
          emit(const ActiveRideEmpty());
          return;
        }

        emit(ActiveRideLoaded(ride: ride));
        _statusSubscription?.cancel();
        _statusSubscription =
            _rtdbService.listenRideStatus(ride.id).listen((status) {
          add(ActiveRideStatusUpdated(
            ride.copyWith(status: status),
          ));
        });
      },
    );
  }

  void _onStatusUpdated(
    ActiveRideStatusUpdated event,
    Emitter<ActiveRideState> emit,
  ) {
    final current = state;
    if (current is ActiveRideLoaded) {
      emit(current.copyWith(ride: event.ride));

      if (event.ride.status.isTerminal) {
        emit(ActiveRideCompleted(event.ride));
      }
    }
  }

  Future<void> _onMarkArrived(
    ActiveRideMarkArrived event,
    Emitter<ActiveRideState> emit,
  ) async {
    final current = state;
    if (current is! ActiveRideLoaded) return;

    emit(current.copyWith(isProcessing: true));

    final result = await _driverRepository.markArrived(current.ride.id);

    result.fold(
      (message) => emit(ActiveRideFailure(message)),
      (ride) => emit(ActiveRideLoaded(ride: ride)),
    );
  }

  Future<void> _onStartRide(
    ActiveRideStartRide event,
    Emitter<ActiveRideState> emit,
  ) async {
    final current = state;
    if (current is! ActiveRideLoaded) return;

    emit(current.copyWith(isProcessing: true));

    final result = await _driverRepository.startRide(current.ride.id);

    result.fold(
      (message) => emit(ActiveRideFailure(message)),
      (ride) => emit(ActiveRideLoaded(ride: ride)),
    );
  }

  Future<void> _onComplete(
    ActiveRideComplete event,
    Emitter<ActiveRideState> emit,
  ) async {
    final current = state;
    if (current is! ActiveRideLoaded) return;

    emit(current.copyWith(isProcessing: true));

    final result = await _driverRepository.completeRide(current.ride.id);

    result.fold(
      (message) => emit(ActiveRideFailure(message)),
      (ride) => emit(ActiveRideCompleted(ride)),
    );
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
