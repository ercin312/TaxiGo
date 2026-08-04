import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Geometry helpers for animating a taxi along a map route.
abstract final class RouteGeometry {
  static List<LatLng> densify(List<LatLng> raw, {double stepMeters = 12}) {
    if (raw.length < 2) return List<LatLng>.from(raw);
    final out = <LatLng>[raw.first];
    for (var i = 0; i < raw.length - 1; i++) {
      final a = raw[i];
      final b = raw[i + 1];
      final dist = distanceMeters(a, b);
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

  static double distanceMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * r * math.asin(math.sqrt(h));
  }

  static double pathLengthMeters(List<LatLng> points) {
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += distanceMeters(points[i], points[i + 1]);
    }
    return total;
  }

  /// Bearing in degrees (0 = north, clockwise) from [from] to [to].
  static double bearingDegrees(LatLng from, LatLng to) {
    final lat1 = _rad(from.latitude);
    final lat2 = _rad(to.latitude);
    final dLon = _rad(to.longitude - from.longitude);
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (_deg(math.atan2(y, x)) + 360) % 360;
  }

  /// Position + heading for progress `t` in 0..1 along densified [points].
  static ({LatLng position, double heading, int index}) sample(
    List<LatLng> points,
    double t,
  ) {
    if (points.isEmpty) {
      return (position: const LatLng(0, 0), heading: 0, index: 0);
    }
    if (points.length == 1 || t <= 0) {
      final heading = points.length > 1
          ? bearingDegrees(points[0], points[1])
          : 0.0;
      return (position: points.first, heading: heading, index: 0);
    }
    if (t >= 1) {
      final last = points.length - 1;
      final heading = bearingDegrees(points[last - 1], points[last]);
      return (position: points.last, heading: heading, index: last);
    }

    final lengths = <double>[0];
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += distanceMeters(points[i], points[i + 1]);
      lengths.add(total);
    }
    if (total <= 0) {
      return (position: points.first, heading: 0, index: 0);
    }

    final target = total * t;
    var i = 0;
    while (i < lengths.length - 1 && lengths[i + 1] < target) {
      i++;
    }
    final segStart = lengths[i];
    final segEnd = lengths[i + 1];
    final segLen = (segEnd - segStart).clamp(0.0001, double.infinity);
    final localT = ((target - segStart) / segLen).clamp(0.0, 1.0);
    final a = points[i];
    final b = points[i + 1];
    final position = LatLng(
      a.latitude + (b.latitude - a.latitude) * localT,
      a.longitude + (b.longitude - a.longitude) * localT,
    );
    return (
      position: position,
      heading: bearingDegrees(a, b),
      index: i,
    );
  }

  static List<LatLng> remainingFrom(List<LatLng> points, int index) {
    if (points.isEmpty) return const [];
    if (index >= points.length - 1) return [points.last];
    return points.sublist(index);
  }

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;
}
