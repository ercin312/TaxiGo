import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}

class HomeLocationUpdated extends HomeEvent {
  const HomeLocationUpdated(this.position);

  final Position position;

  @override
  List<Object?> get props => [position.latitude, position.longitude];
}

class HomeRefreshDrivers extends HomeEvent {
  const HomeRefreshDrivers();
}

class HomeFleetTick extends HomeEvent {
  const HomeFleetTick(this.drivers);

  final List<NearbyDriverPresence> drivers;

  @override
  List<Object?> get props => [drivers];
}

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.currentPosition,
    this.driverMarkers = const {},
    this.driverTrails = const {},
    this.nearbyDriverCount = 0,
    this.isDemoFleet = true,
    this.activeRide,
    this.errorMessage,
  });

  final HomeStatus status;
  final Position? currentPosition;
  final Set<Marker> driverMarkers;
  final Set<Polyline> driverTrails;
  final int nearbyDriverCount;

  /// True when map taxis come from the demo simulator (no live online drivers).
  final bool isDemoFleet;
  final RideModel? activeRide;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    Position? currentPosition,
    Set<Marker>? driverMarkers,
    Set<Polyline>? driverTrails,
    int? nearbyDriverCount,
    bool? isDemoFleet,
    RideModel? activeRide,
    String? errorMessage,
    bool clearActiveRide = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      driverMarkers: driverMarkers ?? this.driverMarkers,
      driverTrails: driverTrails ?? this.driverTrails,
      nearbyDriverCount: nearbyDriverCount ?? this.nearbyDriverCount,
      isDemoFleet: isDemoFleet ?? this.isDemoFleet,
      activeRide: clearActiveRide ? null : (activeRide ?? this.activeRide),
      errorMessage: errorMessage,
    );
  }

  LatLng? get currentLatLng {
    if (currentPosition == null) return null;
    return LatLng(currentPosition!.latitude, currentPosition!.longitude);
  }

  @override
  List<Object?> get props => [
        status,
        currentPosition,
        driverMarkers,
        driverTrails,
        nearbyDriverCount,
        isDemoFleet,
        activeRide,
        errorMessage,
      ];
}

enum HomeStatus { initial, loading, ready, failure }

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required RideRepository rideRepository,
    required MapsService mapsService,
    NearbyDriversFeed? nearbyDriversFeed,
  })  : _rideRepository = rideRepository,
        _feed = nearbyDriversFeed ??
            NearbyDriversCoordinator(
              mapsService: mapsService,
              allowDemoFallback: AppConstants.allowDemoMode,
            ),
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeLocationUpdated>(_onLocationUpdated);
    on<HomeRefreshDrivers>(_onRefreshDrivers);
    on<HomeFleetTick>(_onFleetTick);
  }

  final RideRepository _rideRepository;
  final NearbyDriversFeed _feed;

  StreamSubscription<List<NearbyDriverPresence>>? _feedSub;
  StreamSubscription<Position>? _positionSub;
  bool _feedBootstrapped = false;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final position = await _resolveDevicePosition();

      emit(state.copyWith(
        status: HomeStatus.ready,
        currentPosition: position,
      ));

      final activeResult = await _rideRepository.getActiveRide();
      activeResult.fold(
        (_) {},
        (ride) {
          if (ride != null) {
            emit(state.copyWith(activeRide: ride));
          }
        },
      );

      _listenDeviceLocation();
      if (position != null) {
        add(const HomeRefreshDrivers());
      }
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.ready,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<Position?> _resolveDevicePosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // Fast path: last known, then refine with current.
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        unawaited(_refineCurrentPosition());
        return last;
      }
    } catch (_) {}

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _refineCurrentPosition() async {
    try {
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (!isClosed) add(HomeLocationUpdated(fresh));
    } catch (_) {}
  }

  void _listenDeviceLocation() {
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      ),
    ).listen((position) {
      if (!isClosed) add(HomeLocationUpdated(position));
    });
  }

  Future<void> _onLocationUpdated(
    HomeLocationUpdated event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(currentPosition: event.position));
    if (_feedBootstrapped) {
      await _feed.updateCenter(
        LatLng(event.position.latitude, event.position.longitude),
      );
    } else {
      add(const HomeRefreshDrivers());
    }
  }

  Future<void> _onRefreshDrivers(
    HomeRefreshDrivers event,
    Emitter<HomeState> emit,
  ) async {
    await MapMarkerIcons.ensureLoaded();
    final around = state.currentLatLng;
    if (around == null) return;

    await _feedSub?.cancel();
    _feedSub = _feed.stream.listen((drivers) {
      if (!isClosed) add(HomeFleetTick(drivers));
    });

    await _feed.start(center: around);
    _feedBootstrapped = true;
  }

  void _onFleetTick(HomeFleetTick event, Emitter<HomeState> emit) {
    final taxiIcon = MapMarkerIcons.taxiOrDefault;
    final markers = <Marker>{};
    final trails = <Polyline>{};
    final isDemo =
        event.drivers.isEmpty || event.drivers.every((d) => d.isDemo);

    for (final taxi in event.drivers) {
      final plateOrLabel = taxi.plate ?? taxi.label;
      final snippet = taxi.isDemo
          ? (taxi.directionLabel ?? 'Yolda')
          : '${taxi.directionLabel ?? 'Yolda'} · çevrimiçi';

      markers.add(
        Marker(
          markerId: MarkerId(taxi.id),
          position: taxi.position,
          icon: taxiIcon,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          rotation: taxi.heading,
          infoWindow: InfoWindow(
            title: plateOrLabel,
            snippet: snippet,
          ),
        ),
      );

      if (taxi.pathAhead.length >= 2) {
        trails.add(
          Polyline(
            polylineId: PolylineId('trail_${taxi.id}'),
            points: taxi.pathAhead,
            color: AppColors.accent.withValues(alpha: 0.75),
            width: 4,
            jointType: JointType.round,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
          ),
        );
      }
    }

    emit(state.copyWith(
      driverMarkers: markers,
      driverTrails: trails,
      nearbyDriverCount: markers.length,
      isDemoFleet: isDemo,
      status: HomeStatus.ready,
    ));
  }

  @override
  Future<void> close() async {
    await _positionSub?.cancel();
    await _feedSub?.cancel();
    await _feed.dispose();
    return super.close();
  }
}
