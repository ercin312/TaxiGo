import 'dart:async';
import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'maps_service.dart';

class NearbyTaxiSnapshot {
  const NearbyTaxiSnapshot({
    required this.id,
    required this.position,
    required this.heading,
    required this.label,
    required this.directionLabel,
    required this.pathAhead,
  });

  final String id;
  final LatLng position;
  final double heading;
  final String label;
  final String directionLabel;
  final List<LatLng> pathAhead;
}

/// Live nearby taxis moving along real road routes (OSRM/Google).
class NearbyFleetSimulator {
  NearbyFleetSimulator(this._maps);

  final MapsService _maps;
  final _rng = math.Random();
  final _controller =
      StreamController<List<NearbyTaxiSnapshot>>.broadcast();

  StreamSubscription<void>? _noop;
  Timer? _tick;
  final List<_SimTaxi> _taxis = [];
  bool _running = false;

  Stream<List<NearbyTaxiSnapshot>> get stream => _controller.stream;

  Future<void> start({
    required LatLng center,
    int count = 4,
  }) async {
    await stop();
    _running = true;
    _taxis.clear();

    final spawned = <_SimTaxi>[];
    for (var i = 0; i < count; i++) {
      if (!_running) return;
      final taxi = await _createTaxi(
        id: 'fleet_$i',
        label: 'Taksi ${i + 1}',
        center: center,
        seed: i,
      );
      if (taxi != null) spawned.add(taxi);
    }

    // Fallback static-ish orbits if routing failed entirely.
    if (!_running) return;
    if (spawned.isEmpty) {
      for (var i = 0; i < count; i++) {
        spawned.add(_fallbackTaxi(i, center));
      }
    }

    if (!_running) return;
    _taxis.addAll(spawned);
    _emit();
    _tick = Timer.periodic(const Duration(milliseconds: 400), (_) {
      _advanceAll();
      _emit();
    });

    // Periodically refresh one taxi onto a new road segment.
    _noop = Stream.periodic(const Duration(seconds: 18)).listen((_) async {
      if (!_running || _taxis.isEmpty) return;
      final i = _rng.nextInt(_taxis.length);
      final current = _taxis[i];
      final refreshed = await _createTaxi(
        id: current.id,
        label: current.label,
        center: current.position,
        seed: i + _rng.nextInt(20),
        from: current.position,
      );
      if (refreshed != null && _running) {
        _taxis[i] = refreshed;
      }
    });
  }

  Future<void> updateCenter(LatLng center) async {
    // Keep existing taxis; only used if fleet empty.
    if (_taxis.isNotEmpty || _running) return;
    await start(center: center);
  }

  Future<void> stop() async {
    _running = false;
    _tick?.cancel();
    _tick = null;
    await _noop?.cancel();
    _noop = null;
    _taxis.clear();
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(
      _taxis.map((t) {
        final ahead = t.route.length > t.index + 1
            ? t.route.sublist(t.index, math.min(t.index + 28, t.route.length))
            : <LatLng>[t.position];
        return NearbyTaxiSnapshot(
          id: t.id,
          position: t.position,
          heading: t.heading,
          label: t.label,
          directionLabel: _directionLabel(t.heading),
          pathAhead: ahead,
        );
      }).toList(),
    );
  }

  void _advanceAll() {
    for (final taxi in _taxis) {
      if (taxi.route.length < 2) continue;
      taxi.index = math.min(taxi.index + taxi.step, taxi.route.length - 1);
      final pos = taxi.route[taxi.index];
      taxi.position = pos;
      if (taxi.index < taxi.route.length - 1) {
        taxi.heading = _bearing(pos, taxi.route[taxi.index + 1]);
      } else if (taxi.index > 0) {
        taxi.heading = _bearing(taxi.route[taxi.index - 1], pos);
      }

      // Loop / bounce: reverse route when finished.
      if (taxi.index >= taxi.route.length - 1) {
        taxi.route = taxi.route.reversed.toList();
        taxi.index = 0;
        taxi.position = taxi.route.first;
        if (taxi.route.length > 1) {
          taxi.heading = _bearing(taxi.route[0], taxi.route[1]);
        }
      }
    }
  }

  Future<_SimTaxi?> _createTaxi({
    required String id,
    required String label,
    required LatLng center,
    required int seed,
    LatLng? from,
  }) async {
    final start = from ??
        LatLng(
          center.latitude + _offset(seed, 0.0018, 0.0045),
          center.longitude + _offset(seed + 3, 0.0018, 0.0045),
        );
    final end = LatLng(
      start.latitude + _offset(seed + 7, 0.004, 0.012),
      start.longitude + _offset(seed + 11, 0.004, 0.012),
    );

    final result = await _maps.getDirections(
      originLat: start.latitude,
      originLng: start.longitude,
      destinationLat: end.latitude,
      destinationLng: end.longitude,
    );

    return result.fold(
      (_) => null,
      (directions) {
        if (directions.points.length < 3) return null;
        final dense = _densify(directions.points, stepMeters: 14);
        if (dense.length < 3) return null;
        return _SimTaxi(
          id: id,
          label: label,
          route: dense,
          index: 0,
          position: dense.first,
          heading: _bearing(dense.first, dense[1]),
          step: 1 + (seed % 2),
        );
      },
    );
  }

  _SimTaxi _fallbackTaxi(int i, LatLng center) {
    final route = <LatLng>[];
    final baseLat = center.latitude + (i - 1) * 0.0025;
    final baseLng = center.longitude + (i - 1.5) * 0.002;
    for (var s = 0; s < 40; s++) {
      final t = s / 39;
      route.add(
        LatLng(
          baseLat + math.sin(t * math.pi * 2) * 0.003,
          baseLng + t * 0.006 - 0.003,
        ),
      );
    }
    return _SimTaxi(
      id: 'fleet_$i',
      label: 'Taksi ${i + 1}',
      route: route,
      index: 0,
      position: route.first,
      heading: _bearing(route.first, route[1]),
      step: 1,
    );
  }

  double _offset(int seed, double min, double max) {
    final sign = seed.isEven ? 1.0 : -1.0;
    final span = max - min;
    return sign * (min + _rng.nextDouble() * span);
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

  static double _bearing(LatLng from, LatLng to) {
    final lat1 = _rad(from.latitude);
    final lat2 = _rad(to.latitude);
    final dLon = _rad(to.longitude - from.longitude);
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (_deg(math.atan2(y, x)) + 360) % 360;
  }

  static List<LatLng> _densify(List<LatLng> raw, {double stepMeters = 14}) {
    if (raw.length < 2) return List<LatLng>.from(raw);
    final out = <LatLng>[raw.first];
    for (var i = 0; i < raw.length - 1; i++) {
      final a = raw[i];
      final b = raw[i + 1];
      final dist = _distanceMeters(a, b);
      if (dist <= stepMeters) {
        out.add(b);
        continue;
      }
      final steps = (dist / stepMeters).ceil();
      for (var s = 1; s <= steps; s++) {
        final t = s / steps;
        out.add(
          LatLng(
            a.latitude + (b.latitude - a.latitude) * t,
            a.longitude + (b.longitude - a.longitude) * t,
          ),
        );
      }
    }
    return out;
  }

  static double _distanceMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * r * math.asin(math.sqrt(h));
  }

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;
}

class _SimTaxi {
  _SimTaxi({
    required this.id,
    required this.label,
    required this.route,
    required this.index,
    required this.position,
    required this.heading,
    required this.step,
  });

  final String id;
  final String label;
  List<LatLng> route;
  int index;
  LatLng position;
  double heading;
  final int step;
}
