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
    on<DriverHomeSubmitBid>(_onSubmitBid);
    on<DriverHomeRejectRide>(_onRejectRide);
    on<DriverHomeRefreshEarnings>(_onRefreshEarnings);
    on<DriverHomeDismissSuccess>(_onDismissSuccess);
  }

  final DriverRepository _driverRepository;
  final RtdbService _rtdbService;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _pendingPollTimer;
  StreamSubscription<int>? _fcmRideSubscription;

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
        final seed = LocalDemoStore.instance.seedPosition;

        emit(DriverHomeReady(
          driver: driver,
          isOnline: driver.isOnline,
          activeRide: activeRide,
          todayEarnings: earnings,
          currentPosition: seed,
        ));

        if (driver.isOnline) {
          if (!LocalDemoStore.instance.hasSeedLocation) {
            await _startLocationTracking();
          }
          _startPendingPoll();
          _listenFcmRideRequests();
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
      _stopFcmRideRequests();
      try {
        await _rtdbService.setDriverOffline(current.driver.id);
      } catch (_) {
        // Demo / offline — RTDB optional.
      }
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
      Position position;
      final seed = LocalDemoStore.instance.seedPosition;
      if (seed != null) {
        position = seed;
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
        position = await Geolocator.getCurrentPosition();
      }

      await _driverRepository.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
      );

      final result = await _driverRepository.goOnline(
        latitude: position.latitude,
        longitude: position.longitude,
      );
          await result.fold(
        (message) async => emit(DriverHomeFailure(message)),
        (_) async {
          try {
            await _rtdbService.writeDriverPresence(
              driverId: current.driver.id,
              latitude: position.latitude,
              longitude: position.longitude,
              heading: position.heading,
              plate: current.driver.vehiclePlate,
              isOnline: true,
            );
          } catch (_) {
            // Demo / offline — RTDB optional.
          }

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
              if (!LocalDemoStore.instance.hasSeedLocation) {
                _startLocationTracking();
              }
              _startPendingPoll();
              _listenFcmRideRequests();
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

    try {
      await _rtdbService.writeDriverPresence(
        driverId: current.driver.id,
        latitude: event.position.latitude,
        longitude: event.position.longitude,
        heading: event.position.heading,
        plate: current.driver.vehiclePlate,
        isOnline: true,
      );
    } catch (_) {
      // Demo / offline — RTDB optional.
    }

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
        await _driverRepository.acceptOffer(current.incomingRide!.id);

    result.fold(
      (message) => emit(DriverHomeFailure(message)),
      (_) => emit(current.copyWith(
        incomingRide: null,
        isProcessingRide: false,
        successMessage: 'bid_submitted',
      )),
    );
  }

  Future<void> _onSubmitBid(
    DriverHomeSubmitBid event,
    Emitter<DriverHomeState> emit,
  ) async {
    final current = state;
    if (current is! DriverHomeReady || current.incomingRide == null) return;

    emit(current.copyWith(isProcessingRide: true));

    final result = await _driverRepository.submitBid(
      current.incomingRide!.id,
      event.amount,
    );

    result.fold(
      (message) => emit(DriverHomeFailure(message)),
      (_) => emit(current.copyWith(
        incomingRide: null,
        isProcessingRide: false,
        successMessage: 'bid_submitted',
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

  void _onDismissSuccess(
    DriverHomeDismissSuccess event,
    Emitter<DriverHomeState> emit,
  ) {
    final current = state;
    if (current is DriverHomeReady) {
      emit(current.copyWith(clearSuccessMessage: true));
    }
  }

  Future<double> _loadTodayEarnings() async {
    final demo = LocalDemoStore.instance.todayEarnings;
    final result = await _driverRepository.getRideHistory(page: 1);
    return result.fold(
      (_) => demo,
      (rides) {
        final today = DateTime.now();
        final fromRides = rides
            .where((r) =>
                r.status == RideStatus.completed &&
                r.completedAt != null &&
                r.completedAt!.year == today.year &&
                r.completedAt!.month == today.month &&
                r.completedAt!.day == today.day)
            .fold<double>(0, (sum, r) => sum + (r.finalFare ?? 0));
        return fromRides > 0 ? fromRides : demo;
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
      if (!current.isOnline ||
          current.activeRide != null ||
          current.incomingRide != null) {
        return;
      }

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

  void _listenFcmRideRequests() {
    _fcmRideSubscription?.cancel();
    _fcmRideSubscription = RideRequestInbox.instance.stream.listen((rideId) async {
      if (state is! DriverHomeReady) return;
      final current = state as DriverHomeReady;
      if (!current.isOnline || current.activeRide != null) return;

      final result = await _driverRepository.getPendingRides();
      result.fold((_) {}, (rides) {
        final match = rides.where((r) => r.id == rideId);
        if (match.isNotEmpty) {
          add(DriverHomeIncomingRideReceived(match.first));
        } else if (rides.isNotEmpty) {
          add(DriverHomeIncomingRideReceived(rides.first));
        }
      });
    });
  }

  void _stopFcmRideRequests() {
    _fcmRideSubscription?.cancel();
    _fcmRideSubscription = null;
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _pendingPollTimer?.cancel();
    _fcmRideSubscription?.cancel();
    return super.close();
  }
}
