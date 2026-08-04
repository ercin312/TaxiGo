import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Source of a nearby taxi shown on the passenger map.
///
/// Production uses [live] (Firebase RTDB / driver app GPS).
/// [demo] exists only until enough real online drivers are nearby.
enum NearbyDriverSource { live, demo }

/// Canonical nearby-driver presence for the passenger home map.
///
/// Live drivers publish:
/// `drivers/{driverId}/is_online`, `location.{latitude,longitude,heading,updated_at}`,
/// optional `plate` / `name`. The UI must not care whether the value came from
/// demo simulation or RTDB — only [source] differs.
class NearbyDriverPresence extends Equatable {
  const NearbyDriverPresence({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.source,
    this.heading = 0,
    this.plate,
    this.directionLabel,
    this.pathAhead = const [],
    this.updatedAt,
    this.isOnline = true,
  });

  final String id;
  final double latitude;
  final double longitude;
  final double heading;
  final String label;
  final String? plate;
  final String? directionLabel;
  final List<LatLng> pathAhead;
  final NearbyDriverSource source;
  final DateTime? updatedAt;
  final bool isOnline;

  LatLng get position => LatLng(latitude, longitude);

  bool get isDemo => source == NearbyDriverSource.demo;

  NearbyDriverPresence copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    String? label,
    String? plate,
    String? directionLabel,
    List<LatLng>? pathAhead,
    DateTime? updatedAt,
    bool? isOnline,
  }) {
    return NearbyDriverPresence(
      id: id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      label: label ?? this.label,
      plate: plate ?? this.plate,
      directionLabel: directionLabel ?? this.directionLabel,
      pathAhead: pathAhead ?? this.pathAhead,
      source: source,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
        id,
        latitude,
        longitude,
        heading,
        label,
        plate,
        directionLabel,
        pathAhead,
        source,
        updatedAt,
        isOnline,
      ];
}
