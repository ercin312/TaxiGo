import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import '../core/constants/app_constants.dart';
import '../domain/enums/ride_status.dart';
import '../domain/models/ride_location_model.dart';
import '../firebase/firebase_service.dart';

/// Firebase Realtime Database service for live ride and driver tracking.
class RtdbService {
  RtdbService({FirebaseDatabase? database}) : _database = database;

  final FirebaseDatabase? _database;

  FirebaseDatabase? get _db =>
      _database ?? (FirebaseService.isInitialized ? FirebaseDatabase.instance : null);

  DatabaseReference? _ref(String path) => _db?.ref(path);

  Stream<RideLocationModel> listenDriverLocation(int driverId) {
    final ref = _ref(AppConstants.driverLocationPath(driverId));
    if (ref == null) return const Stream.empty();

    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return const RideLocationModel(latitude: 0, longitude: 0);
      }
      final map = Map<String, dynamic>.from(value);
      return RideLocationModel(
        latitude: _toDouble(map['latitude']) ?? 0,
        longitude: _toDouble(map['longitude']) ?? 0,
        heading: _toDouble(map['heading']),
        recordedAt: _toDateTime(map['updated_at']),
      );
    });
  }

  /// Publishes online presence + GPS for passenger map discovery.
  ///
  /// Tree shape (production):
  /// `drivers/{id}` → is_online, plate?, name?, location{lat,lng,heading,updated_at}
  Future<void> writeDriverPresence({
    required int driverId,
    required double latitude,
    required double longitude,
    double? heading,
    String? plate,
    String? name,
    bool isOnline = true,
  }) async {
    final ref = _ref(AppConstants.driverPath(driverId));
    if (ref == null) return;

    final now = DateTime.now().toIso8601String();
    await ref.update({
      'is_online': isOnline,
      if (plate != null && plate.isNotEmpty) 'plate': plate,
      if (name != null && name.isNotEmpty) 'name': name,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        if (heading != null) 'heading': heading,
        'updated_at': now,
      },
      'updated_at': now,
    });
  }

  Future<void> writeDriverLocation({
    required int driverId,
    required double latitude,
    required double longitude,
    double? heading,
    String? plate,
    String? name,
  }) async {
    await writeDriverPresence(
      driverId: driverId,
      latitude: latitude,
      longitude: longitude,
      heading: heading,
      plate: plate,
      name: name,
      isOnline: true,
    );
  }

  Future<void> setDriverOffline(int driverId) async {
    final ref = _ref(AppConstants.driverPath(driverId));
    if (ref == null) return;
    await ref.update({
      'is_online': false,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Stream<RideStatus> listenRideStatus(int rideId) {
    final ref = _ref('${AppConstants.ridePath(rideId)}/status');
    if (ref == null) return const Stream.empty();

    return ref.onValue.map((event) {
      return RideStatus.fromString(event.snapshot.value?.toString());
    });
  }

  Stream<Map<String, dynamic>?> listenRide(int rideId) {
    final ref = _ref(AppConstants.ridePath(rideId));
    if (ref == null) return const Stream.empty();

    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return null;
      return Map<String, dynamic>.from(value);
    });
  }

  Future<void> writeRideStatus({
    required int rideId,
    required RideStatus status,
  }) async {
    final ref = _ref(AppConstants.ridePath(rideId));
    if (ref == null) return;

    await ref.update({
      'status': status.value,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeRide(int rideId) async {
    final ref = _ref(AppConstants.ridePath(rideId));
    if (ref == null) return;
    await ref.remove();
  }

  void cancelSubscription(String key) {
    _subscriptions[key]?.cancel();
    _subscriptions.remove(key);
  }

  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  final Map<String, StreamSubscription<DatabaseEvent>> _subscriptions = {};

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
