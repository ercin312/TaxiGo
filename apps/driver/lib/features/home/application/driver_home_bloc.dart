import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxigo_core/taxigo_core.dart';

part 'driver_home_event.dart';
part 'driver_home_state.dart';

class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {
  DriverHomeBloc({
    required DriverRepository driverRepository,
    required RtdbService rtdbService,
  })  : _driverRepository = driverRepository,
        _rtdbService = rtdbService,
        super(const DriverHomeInitial()) {
    on<DriverHomeStarted>(_onStarted);
    on<DriverHomeToggleOnline>(_onToggleOnline);
    on<DriverHomeLocationUpdated>(_onLocationUpdated);
    on<DriverHomeIncomingRideReceived>(_onIncomingRideReceived);
    on<DriverHomeAcceptRide>(_onAcceptRide);
    on<DriverHomeRejectRide>(_onRejectRide);
    on<DriverHomeRefreshEarnings>(_onRefreshEarnings);
  }

  final DriverRepository _driverRepository;
  final RtdbService _rtdbService;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _pendingPollTimer;

  Future<void> _onStarted(
    DriverHomeStarted event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(const DriverHomeLoading());

    final profileResult = await _driverRepository.getProfile();
    await profileResult.fold(
      (message) async => emit(DriverHomeFailure(message)),
      (driver) async {
        if (!driver.isApproved) {
          emit(DriverHomeNotApproved(driver));
          return;
        }

        final activeResult = await _driverRepository.getActiveRide();
        RideModel? activeRide;
        activeResult.fold((_) {}, (ride) => activeRide = ride);

        final earnings = await _loadTodayEarnings();

        emit(DriverHomeReady(
          driver: driver,
          isOnline: driver.isOnline,
          activeRide: activeRide,
          todayEarnings: earnings,
        ));

        if (driver.isOnline) {
          await _startLocationTracking();
          _startPendingPoll();
        }
      },
    );
  }

  Future<void> _onToggleOnline(
    DriverHomeToggleOnline event,
    Emitter<DriverHomeState> emit,
  ) async {
    final current = state;
    if (current is! DriverHomeReady) return;

    if (!current.driver.isApproved) {
      emit(DriverHomeNotApproved(current.driver));
      return;
    }

    emit(current.copyWith(isTogglingOnline: true));

    if (current.isOnline) {
      await _stopLocationTracking();
      _stopPendingPoll();
      try {
        await _rtdbService.setDriverOffline(current.driver.id);
      } catch (_) {}
      final result = await _driverRepository.goOffline();
      await result.fold(
        (message) async => emit(DriverHomeFailure(message)),
        (_) async {
          final profile = await _driverRepository.getProfile();
          profile.fold(
            (message) => emit(DriverHomeFailure(message)),
            (driver) => emit(current.copyWith(
              driver: driver,
              isOnline: false,
              isTogglingOnline: false,
            )),
          );
        },
      );
    } else {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(DriverHomeFailure('Location permission required'));
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      await _driverRepository.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
      );

      final result = await _driverRepository.goOnline();
      await result.fold(
        (message) async => emit(DriverHomeFailure(message)),
        (_) async {
          await _rtdbService.writeDriverPresence(
            driverId: current.driver.id,
            latitude: position.latitude,
            longitude: position.longitude,
            heading: position.heading,
            plate: current.driver.vehiclePlate,
            isOnline: true,
          );

          final profile = await _driverRepository.getProfile();
          profile.fold(
            (message) => emit(DriverHomeFailure(message)),
            (driver) {
              emit(current.copyWith(
                driver: driver,
                isOnline: true,
                isTogglingOnline: false,
                currentPosition: position,
              ));
              _startLocationTracking();
              _startPendingPoll();
            },
          );
        },
      );
    }
  }

  Future<void> _onLocationUpdated(
    DriverHomeLocationUpdated event,
    Emitter<DriverHomeState> emit,
  ) async {
    final current = state;
    if (current is! DriverHomeReady || !current.isOnline) return;

    await _rtdbService.writeDriverPresence(
      driverId: current.driver.id,
      latitude: event.position.latitude,
      longitude: event.position.longitude,
      heading: event.position.heading,
      plate: current.driver.vehiclePlate,
      isOnline: true,
    );

    await _driverRepository.updateLocation(
      latitude: event.position.latitude,
      longitude: event.position.longitude,
      heading: event.position.heading,
    );

    emit(current.copyWith(currentPosition: event.position));
  }

  void _onIncomingRideReceived(
    DriverHomeIncomingRideReceived event,
    Emitter<DriverHomeState> emit,
  ) {
    final current = state;
    if (current is DriverHomeReady &&
        current.isOnline &&
        current.activeRide == null) {
      emit(current.copyWith(incomingRide: event.ride));
    }
  }

  Future<void> _onAcceptRide(
    DriverHomeAcceptRide event,
    Emitter<DriverHomeState> emit,
  ) async {
    final current = state;
    if (current is! DriverHomeReady || current.incomingRide == null) return;

    emit(current.copyWith(isProcessingRide: true));

    final result =
        await _driverRepository.acceptRide(current.incomingRide!.id);

    result.fold(
      (message) => emit(DriverHomeFailure(message)),
      (ride) => emit(current.copyWith(
        activeRide: ride,
        incomingRide: null,
        isProcessingRide: false,
      )),
    );
  }

  Future<void> _onRejectRide(
    DriverHomeRejectRide event,
    Emitter<DriverHomeState> emit,
  ) async {
    final current = state;
    if (current is! DriverHomeReady || current.incomingRide == null) return;

    await _driverRepository.rejectRide(current.incomingRide!.id);
    emit(current.copyWith(incomingRide: null));
  }

  Future<void> _onRefreshEarnings(
    DriverHomeRefreshEarnings event,
    Emitter<DriverHomeState> emit,
  ) async {
    final current = state;
    if (current is! DriverHomeReady) return;

    final earnings = await _loadTodayEarnings();
    emit(current.copyWith(todayEarnings: earnings));
  }

  Future<double> _loadTodayEarnings() async {
    final result = await _driverRepository.getRideHistory(page: 1);
    return result.fold(
      (_) => 0,
      (rides) {
        final today = DateTime.now();
        return rides
            .where((r) =>
                r.status == RideStatus.completed &&
                r.completedAt != null &&
                r.completedAt!.year == today.year &&
                r.completedAt!.month == today.month &&
                r.completedAt!.day == today.day)
            .fold<double>(0, (sum, r) => sum + (r.finalFare ?? 0));
      },
    );
  }

  Future<void> _startLocationTracking() async {
    await _positionSubscription?.cancel();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      add(DriverHomeLocationUpdated(position));
    });
  }

  Future<void> _stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _startPendingPoll() {
    _pendingPollTimer?.cancel();
    _pendingPollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (state is! DriverHomeReady) return;
      final current = state as DriverHomeReady;
      if (!current.isOnline || current.activeRide != null) return;

      final result = await _driverRepository.getPendingRides();
      result.fold((_) {}, (rides) {
        if (rides.isNotEmpty) {
          add(DriverHomeIncomingRideReceived(rides.first));
        }
      });
    });
  }

  void _stopPendingPoll() {
    _pendingPollTimer?.cancel();
    _pendingPollTimer = null;
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _pendingPollTimer?.cancel();
    return super.close();
  }
}
