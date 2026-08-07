import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/constants/app_constants.dart';
import '../domain/enums/driver_approval_status.dart';
import '../domain/enums/payment_method.dart';
import '../domain/enums/ride_status.dart';
import '../domain/models/driver_model.dart';
import '../domain/models/fare_estimate_model.dart';
import '../domain/models/ride_model.dart';
import '../domain/models/user_model.dart';

/// In-app demo data (debug / TAXIGO_ALLOW_DEMO only).
class LocalDemoStore {
  LocalDemoStore._();
  static final LocalDemoStore instance = LocalDemoStore._();

  RideModel? _activePassengerRide;
  RideModel? _activeDriverRide;
  RideModel? _pendingOffer;
  DriverModel? _driver;
  bool _driverOnline = false;
  double _todayEarnings = 125.50;
  int _nextRideId = 9001;
  final Set<String> _uploadedDocumentTypes = {};

  /// Active demo persona (city / taxi seed) after chip login.
  DemoAccount? _activeAccount;

  static const demoAccounts = <DemoAccount>[
    // Passengers — always open on the device GPS (no city seed).
    DemoAccount(
      name: 'Ahmet Yolcu',
      phone: '+905551000001',
      role: 'passenger',
      label: 'Yolcu 1',
    ),
    DemoAccount(
      name: 'Ayşe Yolcu',
      phone: '+905551000002',
      role: 'passenger',
      label: 'Yolcu 2',
    ),
    // Taxis in different cities — seed location only for these driver demos.
    DemoAccount(
      name: 'Mehmet Taksim',
      phone: '+905552000001',
      role: 'driver',
      label: 'Taksim',
      areaLabel: 'İstanbul · Taksim',
      latitude: 41.0369,
      longitude: 28.9850,
      vehicleMake: 'Toyota',
      vehicleModel: 'Corolla',
      vehiclePlate: '34 TG 01',
      vehicleColor: 'Beyaz',
    ),
    DemoAccount(
      name: 'Can Kadıköy',
      phone: '+905552000002',
      role: 'driver',
      label: 'Kadıköy',
      areaLabel: 'İstanbul · Kadıköy',
      latitude: 40.9901,
      longitude: 29.0292,
      vehicleMake: 'Volkswagen',
      vehicleModel: 'Passat',
      vehiclePlate: '34 TG 02',
      vehicleColor: 'Siyah',
    ),
    DemoAccount(
      name: 'Emre Beşiktaş',
      phone: '+905552000003',
      role: 'driver',
      label: 'Beşiktaş',
      areaLabel: 'İstanbul · Beşiktaş',
      latitude: 41.0422,
      longitude: 29.0067,
      vehicleMake: 'Hyundai',
      vehicleModel: 'Elantra',
      vehiclePlate: '34 TG 03',
      vehicleColor: 'Gri',
    ),
    DemoAccount(
      name: 'Ali Kızılay',
      phone: '+905552000004',
      role: 'driver',
      label: 'Ankara',
      areaLabel: 'Ankara · Kızılay',
      latitude: 39.9208,
      longitude: 32.8541,
      vehicleMake: 'Renault',
      vehicleModel: 'Megane',
      vehiclePlate: '06 TG 01',
      vehicleColor: 'Beyaz',
    ),
    DemoAccount(
      name: 'Deniz Alsancak',
      phone: '+905552000005',
      role: 'driver',
      label: 'İzmir',
      areaLabel: 'İzmir · Alsancak',
      latitude: 38.4360,
      longitude: 27.1428,
      vehicleMake: 'Fiat',
      vehicleModel: 'Egea',
      vehiclePlate: '35 TG 01',
      vehicleColor: 'Sarı',
    ),
    DemoAccount(
      name: 'Burak Lara',
      phone: '+905552000006',
      role: 'driver',
      label: 'Antalya',
      areaLabel: 'Antalya · Lara',
      latitude: 36.8565,
      longitude: 30.7925,
      vehicleMake: 'Skoda',
      vehicleModel: 'Octavia',
      vehiclePlate: '07 TG 01',
      vehicleColor: 'Lacivert',
    ),
  ];

  static List<DemoAccount> get passengerDemos =>
      demoAccounts.where((a) => a.role == 'passenger').toList();

  static List<DemoAccount> get taxiDemos =>
      demoAccounts.where((a) => a.role == 'driver').toList();

  static DemoAccount? findByPhone(String phone) {
    final normalized = phone.trim();
    for (final account in demoAccounts) {
      if (account.phone == normalized) return account;
    }
    return null;
  }

  DemoAccount? get activeAccount => _activeAccount;

  /// Seed map only for **driver** city-taxi demos. Passengers always use GPS.
  LatLng? get seedLatLng {
    final a = _activeAccount;
    if (a == null || a.role != 'driver') return null;
    if (a.latitude == null || a.longitude == null) return null;
    return LatLng(a.latitude!, a.longitude!);
  }

  Position? get seedPosition {
    final point = seedLatLng;
    if (point == null) return null;
    return Position(
      latitude: point.latitude,
      longitude: point.longitude,
      timestamp: DateTime.now(),
      accuracy: 8,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  bool get hasSeedLocation => seedLatLng != null;

  /// Call on demo chip login so map & driver presence open in that city.
  void applyDemoAccount(DemoAccount account) {
    _activeAccount = account;
    _driver = null;
    _driverOnline = false;
    _uploadedDocumentTypes.clear();
    _activePassengerRide = null;
    _activeDriverRide = null;
    _pendingOffer = null;
  }

  void clearDemoSession() {
    _activeAccount = null;
    _driver = null;
    _driverOnline = false;
    _uploadedDocumentTypes.clear();
    _activePassengerRide = null;
    _activeDriverRide = null;
    _pendingOffer = null;
  }

  /// Returns existing KYC profile, or a pre-approved demo taxi profile.
  /// Passengers without registration return null (must complete KYC).
  DriverModel? existingDriverProfile(UserModel user) {
    if (_driver != null) {
      return _driver!.copyWith(
        userId: user.id,
        isOnline: _driverOnline,
      );
    }
    if (_activeAccount?.role == 'driver') {
      return driverFor(user);
    }
    return null;
  }

  DriverModel registerPendingDriver(
    UserModel user, {
    required String vehicleMake,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleColor,
  }) {
    _uploadedDocumentTypes.clear();
    _driver = DriverModel(
      id: 7000 + (user.id % 1000),
      userId: user.id,
      approvalStatus: DriverApprovalStatus.pending,
      isOnline: false,
      ratingAverage: 0,
      ratingCount: 0,
      totalRides: 0,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      vehiclePlate: vehiclePlate,
      vehicleColor: vehicleColor,
    );
    return _driver!;
  }

  void markDocumentUploaded(String type) {
    _uploadedDocumentTypes.add(type);
  }

  Set<String> get uploadedDocumentTypes => Set.unmodifiable(_uploadedDocumentTypes);

  /// Local-only shortcut after admin-style review is simulated.
  void approvePendingDriver() {
    if (_driver == null) return;
    _driver = _driver!.copyWith(
      approvalStatus: DriverApprovalStatus.approved,
      approvedAt: DateTime.now(),
      rejectionReason: null,
    );
  }

  DriverModel driverFor(UserModel user) {
    final account = _activeAccount;
    _driver ??= DriverModel(
      id: 7000 + (user.id % 1000),
      userId: user.id,
      approvalStatus: DriverApprovalStatus.approved,
      isOnline: _driverOnline,
      ratingAverage: 4.8,
      ratingCount: 42,
      totalRides: 180,
      approvedAt: DateTime.now().subtract(const Duration(days: 30)),
      vehicleMake: account?.vehicleMake ?? 'Toyota',
      vehicleModel: account?.vehicleModel ?? 'Corolla',
      vehiclePlate: account?.vehiclePlate ?? '34 TG 01',
      vehicleColor: account?.vehicleColor ?? 'Beyaz',
      currentLatitude: account?.latitude,
      currentLongitude: account?.longitude,
    );
    return _driver!.copyWith(
      userId: user.id,
      isOnline: _driverOnline,
      currentLatitude: account?.latitude ?? _driver!.currentLatitude,
      currentLongitude: account?.longitude ?? _driver!.currentLongitude,
    );
  }

  void setOnline(bool online) => _driverOnline = online;

  bool get isOnline => _driverOnline;

  double get todayEarnings => _todayEarnings;

  FareEstimateModel estimateFare({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    String? vehicleType,
  }) {
    final distanceKm = _haversineKm(
      pickupLatitude,
      pickupLongitude,
      dropoffLatitude,
      dropoffLongitude,
    );
    final minutes = math.max(5, (distanceKm * 2.4).round());
    const base = 2.50;
    const perKm = 1.20;
    const perMin = 0.25;
    const minimum = 5.0;
    final raw = base + (distanceKm * perKm) + (minutes * perMin);
    final standard = math.max(minimum, raw);
    final multiplier = switch (vehicleType) {
      'comfort' => 1.35,
      'premium' => 1.75,
      _ => 1.0,
    };
    final fare =
        double.parse((standard * multiplier).toStringAsFixed(2));
    return FareEstimateModel(
      distanceKm: double.parse(distanceKm.toStringAsFixed(2)),
      estimatedDurationMinutes: minutes,
      fare: fare,
      nearbyDriversCount: 3,
      finalFare: fare,
    );
  }

  RideModel createRide({
    required UserModel passenger,
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required String dropoffAddress,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? vehicleType,
    double? offeredFare,
  }) {
    final estimate = estimateFare(
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
      vehicleType: vehicleType,
    );
    final fare = offeredFare ?? estimate.totalFare;
    final ride = RideModel(
      id: _nextRideId++,
      reference: 'DEMO-${DateTime.now().millisecondsSinceEpoch % 100000}',
      passengerId: passenger.id,
      status: RideStatus.pending,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      pickupAddress: pickupAddress,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
      dropoffAddress: dropoffAddress,
      estimatedDistanceKm: estimate.distanceKm,
      estimatedDurationMinutes: estimate.estimatedDurationMinutes,
      estimatedFare: estimate.totalFare,
      offeredFare: fare,
      minimumFare: 5,
      isBidding: false,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    );
    _activePassengerRide = ride;
    _pendingOffer = ride;
    // Auto-match only in explicit demo builds — never in App Store.
    if (AppConstants.allowDemoMode) {
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (_activePassengerRide?.id != ride.id) return;
        if (_activePassengerRide?.status != RideStatus.pending) return;
        _activePassengerRide = ride.copyWith(
          status: RideStatus.driverAssigned,
          driverId: 7101,
          driverAssignedAt: DateTime.now(),
          finalFare: fare,
          driverName: 'TaxiGo Sürücü',
          vehiclePlate: '34 TG 100',
        );
      });
      Future<void>.delayed(const Duration(seconds: 3), () {
        if (_activePassengerRide?.id != ride.id) return;
        if (_activePassengerRide?.status != RideStatus.driverAssigned) return;
        _activePassengerRide = _activePassengerRide!.copyWith(
          status: RideStatus.driverArriving,
        );
      });
    }
    return ride;
  }

  RideModel? get passengerActiveRide {
    final ride = _activePassengerRide;
    if (ride == null || ride.status.isTerminal) return null;
    return ride;
  }

  RideModel? get driverActiveRide {
    final ride = _activeDriverRide;
    if (ride == null || ride.status.isTerminal) return null;
    return ride;
  }

  List<RideModel> pendingForDriver() {
    if (!_driverOnline) return const [];
    final pending = _pendingOffer;
    if (pending != null && pending.status == RideStatus.pending) {
      return [pending];
    }
    if (AppConstants.allowDemoMode) {
      return [_sampleIncomingRide()];
    }
    return const [];
  }

  RideModel _sampleIncomingRide() {
    return RideModel(
      id: 8999,
      reference: 'DEMO-REQ',
      passengerId: 1001,
      status: RideStatus.pending,
      pickupLatitude: 41.015,
      pickupLongitude: 28.98,
      pickupAddress: 'Taksim Meydanı',
      dropoffLatitude: 41.04,
      dropoffLongitude: 29.00,
      dropoffAddress: 'Levent Metro',
      estimatedDistanceKm: 4.2,
      estimatedDurationMinutes: 12,
      estimatedFare: 12.50,
      offeredFare: 12.50,
      minimumFare: 5,
      isBidding: true,
      paymentMethod: PaymentMethod.cash,
      createdAt: DateTime.now(),
    );
  }

  RideModel? getRide(int id) {
    if (_activePassengerRide?.id == id) return _activePassengerRide;
    if (_activeDriverRide?.id == id) return _activeDriverRide;
    if (_pendingOffer?.id == id) return _pendingOffer;
    if (id == 8999) return _sampleIncomingRide();
    return _activePassengerRide ?? _activeDriverRide;
  }

  List<RideModel> history() {
    final rides = <RideModel>[];
    if (_activePassengerRide != null) rides.add(_activePassengerRide!);
    if (_activeDriverRide != null &&
        _activeDriverRide!.id != _activePassengerRide?.id) {
      rides.add(_activeDriverRide!);
    }
    return rides;
  }

  RideModel cancelPassenger(int rideId, {String? reason}) {
    final ride = getRide(rideId);
    if (ride == null) {
      throw StateError('Ride not found');
    }
    final updated = ride.copyWith(
      status: RideStatus.cancelledByPassenger,
      cancellationReason: reason,
      cancelledAt: DateTime.now(),
    );
    _replace(updated);
    return updated;
  }

  void acceptAsDriver(int rideId, int driverId) {
    final ride = getRide(rideId) ?? _sampleIncomingRide();
    final updated = ride.copyWith(
      id: ride.id,
      status: RideStatus.driverAssigned,
      driverId: driverId,
      driverAssignedAt: DateTime.now(),
      finalFare: ride.offeredFare ?? ride.estimatedFare,
    );
    _activeDriverRide = updated;
    _activePassengerRide = updated;
    _pendingOffer = null;
    _todayEarnings += (updated.finalFare ?? 10) * 0.85;
  }

  void rejectAsDriver(int rideId) {
    if (_pendingOffer?.id == rideId) {
      _pendingOffer = null;
    }
  }

  RideModel advance(int rideId, RideStatus status) {
    final ride = getRide(rideId);
    if (ride == null) throw StateError('Ride not found');
    final updated = ride.copyWith(
      status: status,
      driverArrivedAt: status == RideStatus.driverArrived
          ? DateTime.now()
          : ride.driverArrivedAt,
      startedAt: status == RideStatus.inProgress ||
              status == RideStatus.passengerOnBoard
          ? DateTime.now()
          : ride.startedAt,
      completedAt:
          status == RideStatus.completed ? DateTime.now() : ride.completedAt,
      finalFare: status == RideStatus.completed
          ? (ride.offeredFare ?? ride.estimatedFare)
          : ride.finalFare,
    );
    _replace(updated);
    if (status == RideStatus.completed) {
      _todayEarnings += (updated.finalFare ?? 10) * 0.85;
      _activeDriverRide = null;
      _activePassengerRide = null;
    }
    return updated;
  }

  void _replace(RideModel updated) {
    if (_activePassengerRide?.id == updated.id) {
      _activePassengerRide = updated;
    }
    if (_activeDriverRide?.id == updated.id) {
      _activeDriverRide = updated;
    }
    if (_pendingOffer?.id == updated.id) {
      _pendingOffer = updated.status == RideStatus.pending ? updated : null;
    }
  }

  Set<Marker> nearbyDriverMarkers(
    LatLng around, {
    BitmapDescriptor? icon,
  }) {
    const offsets = <(double, double)>[
      (0.004, 0.002),
      (-0.003, 0.004),
      (0.002, -0.005),
    ];
    final markerIcon = icon ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    return {
      for (var i = 0; i < offsets.length; i++)
        Marker(
          markerId: MarkerId('demo_driver_$i'),
          position: LatLng(
            around.latitude + offsets[i].$2,
            around.longitude + offsets[i].$1,
          ),
          icon: markerIcon,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: InfoWindow(title: 'Demo taksi ${i + 1}'),
          rotation: i * 40.0,
        ),
    };
  }

  static double _haversineKm(
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
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _rad(double deg) => deg * math.pi / 180;
}

class DemoAccount {
  const DemoAccount({
    required this.name,
    required this.phone,
    required this.role,
    required this.label,
    this.areaLabel,
    this.latitude,
    this.longitude,
    this.vehicleMake,
    this.vehicleModel,
    this.vehiclePlate,
    this.vehicleColor,
  });

  final String name;
  final String phone;
  final String role;
  final String label;

  /// City / district shown under the chip (e.g. "İstanbul · Kadıköy").
  final String? areaLabel;
  final double? latitude;
  final double? longitude;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? vehicleColor;

  bool get hasLocation => latitude != null && longitude != null;
}
