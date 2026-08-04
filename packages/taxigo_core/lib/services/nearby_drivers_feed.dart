import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/constants/app_constants.dart';
import '../domain/models/nearby_driver_presence.dart';
import '../firebase/firebase_service.dart';
import 'maps_service.dart';
import 'nearby_fleet_simulator.dart';

/// Abstraction for “who is near me right now on the map”.
///
/// Production path: [NearbyDriversCoordinator] prefers Firebase RTDB presence
/// written by the driver app. Demo simulation is only a fill-in when no live
/// online drivers are in radius.
abstract class NearbyDriversFeed {
  Stream<List<NearbyDriverPresence>> get stream;

  Future<void> start({
    required LatLng center,
    double radiusKm = AppConstants.matchingRadiusKm,
  });

  Future<void> updateCenter(LatLng center);

  Future<void> stop();

  Future<void> dispose();
}

/// Merges live RTDB driver presence with optional demo fallback.
class NearbyDriversCoordinator implements NearbyDriversFeed {
  NearbyDriversCoordinator({
    required MapsService mapsService,
    FirebaseDatabase? database,
    this.allowDemoFallback = true,
  })  : _database = database,
        _demo = NearbyFleetSimulator(mapsService);

  final FirebaseDatabase? _database;
  final NearbyFleetSimulator _demo;
  final bool allowDemoFallback;

  final _out = StreamController<List<NearbyDriverPresence>>.broadcast();
  final _trailBuffers = <String, List<LatLng>>{};

  StreamSubscription<DatabaseEvent>? _rtdbSub;
  StreamSubscription<List<NearbyTaxiSnapshot>>? _demoSub;
  LatLng? _center;
  double _radiusKm = AppConstants.matchingRadiusKm;
  bool _demoRunning = false;
  List<NearbyDriverPresence> _lastLive = const [];

  FirebaseDatabase? get _db =>
      _database ??
      (FirebaseService.isInitialized ? FirebaseDatabase.instance : null);

  @override
  Stream<List<NearbyDriverPresence>> get stream => _out.stream;

  @override
  Future<void> start({
    required LatLng center,
    double radiusKm = AppConstants.matchingRadiusKm,
  }) async {
    await stop();
    _center = center;
    _radiusKm = radiusKm;

    final db = _db;
    if (db != null) {
      _rtdbSub = db.ref(AppConstants.rtdbDriversPath).onValue.listen(
        (event) {
          final origin = _center ?? center;
          final live =
              _parseLiveDrivers(event.snapshot.value, origin, _radiusKm);
          _lastLive = live;
          if (live.isNotEmpty) {
            unawaited(_pauseDemo());
            _emit(live);
          } else if (allowDemoFallback) {
            unawaited(_ensureDemo(origin));
          } else {
            _emit(const []);
          }
        },
        onError: (_) {
          if (allowDemoFallback) {
            unawaited(_ensureDemo(_center ?? center));
          }
        },
      );
    } else if (allowDemoFallback) {
      await _ensureDemo(center);
    }
  }

  @override
  Future<void> updateCenter(LatLng center) async {
    _center = center;
    if (_lastLive.isNotEmpty) {
      final filtered = _lastLive.where((d) {
        return _distanceKm(
              center.latitude,
              center.longitude,
              d.latitude,
              d.longitude,
            ) <=
            _radiusKm;
      }).toList();
      if (filtered.isNotEmpty) {
        _emit(filtered);
        return;
      }
    }
    if (allowDemoFallback && !_demoRunning) {
      await _ensureDemo(center);
    }
  }

  @override
  Future<void> stop() async {
    await _rtdbSub?.cancel();
    _rtdbSub = null;
    await _pauseDemo();
    _lastLive = const [];
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _demo.dispose();
    await _out.close();
  }

  Future<void> _ensureDemo(LatLng center) async {
    if (_demoRunning || _lastLive.isNotEmpty) return;
    _demoRunning = true;
    await _demoSub?.cancel();
    _demoSub = _demo.stream.listen((snapshots) {
      if (_lastLive.isNotEmpty) return; // live always wins
      _emit(
        snapshots
            .map(
              (s) => NearbyDriverPresence(
                id: s.id,
                latitude: s.position.latitude,
                longitude: s.position.longitude,
                heading: s.heading,
                label: s.label,
                directionLabel: s.directionLabel,
                pathAhead: s.pathAhead,
                source: NearbyDriverSource.demo,
                updatedAt: DateTime.now(),
              ),
            )
            .toList(),
      );
    });
    await _demo.start(center: center, count: 4);
    // Race: live drivers may have appeared while routes were loading.
    if (!_demoRunning || _lastLive.isNotEmpty) {
      await _pauseDemo();
    }
  }

  Future<void> _pauseDemo() async {
    if (!_demoRunning) return;
    _demoRunning = false;
    await _demoSub?.cancel();
    _demoSub = null;
    await _demo.stop();
  }

  void _emit(List<NearbyDriverPresence> drivers) {
    if (_out.isClosed) return;
    _out.add(List<NearbyDriverPresence>.unmodifiable(drivers));
  }

  List<NearbyDriverPresence> _parseLiveDrivers(
    Object? raw,
    LatLng center,
    double radiusKm,
  ) {
    if (raw is! Map) return const [];
    final drivers = <NearbyDriverPresence>[];
    raw.forEach((key, value) {
      if (value is! Map) return;
      final map = Map<String, dynamic>.from(value);
      final online = map['is_online'] == true || map['is_online'] == 1;
      if (!online) return;

      final locRaw = map['location'];
      if (locRaw is! Map) return;
      final loc = Map<String, dynamic>.from(locRaw);
      final lat = _toDouble(loc['latitude']);
      final lng = _toDouble(loc['longitude']);
      if (lat == null || lng == null) return;
      if (_distanceKm(center.latitude, center.longitude, lat, lng) > radiusKm) {
        return;
      }

      final heading = _toDouble(loc['heading']) ?? 0;
      final id = key.toString();
      final plate = map['plate']?.toString();
      final name = map['name']?.toString();
      final label = (name != null && name.isNotEmpty)
          ? name
          : (plate != null && plate.isNotEmpty ? plate : 'Taksi $id');

      final pos = LatLng(lat, lng);
      final trail = _pushTrail(id, pos);

      drivers.add(
        NearbyDriverPresence(
          id: id,
          latitude: lat,
          longitude: lng,
          heading: heading,
          label: label,
          plate: plate,
          directionLabel: _directionLabel(heading),
          pathAhead: trail,
          source: NearbyDriverSource.live,
          updatedAt: DateTime.tryParse(loc['updated_at']?.toString() ?? '') ??
              DateTime.now(),
          isOnline: true,
        ),
      );
    });
    return drivers;
  }

  List<LatLng> _pushTrail(String id, LatLng pos) {
    final buf = _trailBuffers.putIfAbsent(id, () => <LatLng>[]);
    if (buf.isEmpty ||
        _distanceKm(
              buf.last.latitude,
              buf.last.longitude,
              pos.latitude,
              pos.longitude,
            ) >
            0.005) {
      buf.add(pos);
    } else {
      buf[buf.length - 1] = pos;
    }
    while (buf.length > 24) {
      buf.removeAt(0);
    }
    return List<LatLng>.from(buf);
  }

  static String _directionLabel(double heading) {
    const labels = [
      'Kuzey',
      'Kuzeydoğu',
      'Doğu',
      'Güneydoğu',
      'Güney',
      'Güneybatı',
      'Batı',
      'Kuzeybatı',
    ];
    final idx = ((heading + 22.5) % 360 / 45).floor() % 8;
    return labels[idx];
  }

  static double _distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180;

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
