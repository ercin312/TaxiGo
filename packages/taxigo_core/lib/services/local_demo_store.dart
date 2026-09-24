import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/di/locator.dart';
import '../domain/enums/driver_approval_status.dart';
import '../domain/enums/payment_method.dart';
import '../domain/enums/ride_status.dart';
import '../domain/models/driver_model.dart';
import '../domain/models/fare_estimate_model.dart';
import '../domain/models/ride_comms_models.dart';
import '../domain/models/ride_model.dart';
import '../domain/models/user_model.dart';
import 'app_review_seed.dart';
import 'feature_modules_service.dart';

/// In-app demo data — active when TAXIGO_ALLOW_DEMO or Super Admin Demo module is on.
class LocalDemoStore {
  LocalDemoStore._();
  static final LocalDemoStore instance = LocalDemoStore._();

  bool get _demoOn {
    try {
      return locator<FeatureModulesService>().demoActive;
    } catch (_) {
      return AppConstants.allowDemoMode;
    }
  }

  /// Public mirror for repositories (local bidding / matching gates).
  bool get isDemoActive => _demoOn;

  RideModel? _activePassengerRide;
  RideModel? _activeDriverRide;
  RideModel? _pendingOffer;
  DriverModel? _driver;
  bool _driverOnline = false;
  double _todayEarnings = 125.50;
  int _nextRideId = 9001;
  final Set<String> _uploadedDocumentTypes = {};
  final List<RideModel> _history = [];
  final Map<int, List<RideMessageModel>> _rideMessages = {};
  int _nextMessageId = 1;
  final Map<int, DateTime> _bidExpiresAt = {};

  /// Stable bid expiry for local polling (do not reset every poll).
  DateTime bidExpiresAt(int rideId, {Duration ttl = const Duration(minutes: 2)}) {
    return _bidExpiresAt.putIfAbsent(
      rideId,
      () => DateTime.now().add(ttl),
    );
  }

  void clearBidExpiry(int rideId) {
    _bidExpiresAt.remove(rideId);
  }

  /// Active demo persona (city / taxi seed) after chip login.
  DemoAccount? _activeAccount;

  static const demoAccounts = <DemoAccount>[
    // Passengers — device GPS (Montenegro service area).
    DemoAccount(
      name: 'Marko Yolcu',
      phone: '+38267000001',
      role: 'passenger',
      label: 'Yolcu 1',
    ),
    DemoAccount(
      name: 'Ana Yolcu',
      phone: '+38267000002',
      role: 'passenger',
      label: 'Yolcu 2',
    ),
    // Taxis across Montenegro cities.
    DemoAccount(
      name: 'Nikola Podgorica',
      phone: '+38268000001',
      role: 'driver',
      label: 'Podgorica',
      areaLabel: 'Podgorica · Centar',
      latitude: 42.4410,
      longitude: 19.2628,
      vehicleMake: 'Toyota',
      vehicleModel: 'Corolla',
      vehiclePlate: 'PG TG 01',
      vehicleColor: 'Bijela',
    ),
    DemoAccount(
      name: 'Luka Budva',
      phone: '+38268000002',
      role: 'driver',
      label: 'Budva',
      areaLabel: 'Budva · Stari Grad',
      latitude: 42.2864,
      longitude: 18.8400,
      vehicleMake: 'Volkswagen',
      vehicleModel: 'Passat',
      vehiclePlate: 'BD TG 02',
      vehicleColor: 'Crna',
    ),
    DemoAccount(
      name: 'Petar Kotor',
      phone: '+38268000003',
      role: 'driver',
      label: 'Kotor',
      areaLabel: 'Kotor · Stari Grad',
      latitude: 42.4247,
      longitude: 18.7712,
      vehicleMake: 'Hyundai',
      vehicleModel: 'Elantra',
      vehiclePlate: 'KO TG 03',
      vehicleColor: 'Siva',
    ),
    DemoAccount(
      name: 'Ivan Tivat',
      phone: '+38268000004',
      role: 'driver',
      label: 'Tivat',
      areaLabel: 'Tivat · Porto Montenegro',
      latitude: 42.4340,
      longitude: 18.7064,
      vehicleMake: 'Mercedes',
      vehicleModel: 'Vito',
      vehiclePlate: 'TV TG 04',
      vehicleColor: 'Crna',
    ),
    DemoAccount(
      name: 'Stefan Bar',
      phone: '+38268000005',
      role: 'driver',
      label: 'Bar',
      areaLabel: 'Bar · Centar',
      latitude: 42.0931,
      longitude: 19.1003,
      vehicleMake: 'Skoda',
      vehicleModel: 'Octavia',
      vehiclePlate: 'BR TG 05',
      vehicleColor: 'Plava',
    ),
    DemoAccount(
      name: 'Milo Herceg Novi',
      phone: '+38268000006',
      role: 'driver',
      label: 'Herceg Novi',
      areaLabel: 'Herceg Novi · Centar',
      latitude: 42.4514,
      longitude: 18.5375,
      vehicleMake: 'Renault',
      vehicleModel: 'Megane',
      vehiclePlate: 'HN TG 06',
      vehicleColor: 'Bijela',
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

  /// Seeds an approved driver for App Review offline / local sessions.
  void seedApprovedDriver(DriverModel driver) {
    _driver = driver;
    _driverOnline = false;
  }

  /// Once per session: add App Review completed trips without wiping live rides.
  void ensureReviewHistorySeeded() {
    if (_history.any((r) => r.id == 1001 || r.reference == 'TG-REVIEW-001')) {
      return;
    }
    _history.addAll(AppReviewSeed.rideHistory());
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
      vehiclePlate: account?.vehiclePlate ?? 'PG TG 01',
      vehicleColor: account?.vehicleColor ?? 'Bijela',
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
      'van' => 2.2,
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
    String productMode = 'taxi',
    String matchMode = 'instant',
    DateTime? scheduledAt,
    String? passengerNote,
  }) {
    final estimate = estimateFare(
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
      vehicleType: vehicleType,
    );
    final fare = offeredFare ?? estimate.totalFare;
    final bidding = matchMode == 'bidding' && scheduledAt == null;
    final isScheduled = scheduledAt != null;
    final ride = RideModel(
      id: _nextRideId++,
      reference: 'DEMO-${DateTime.now().millisecondsSinceEpoch % 100000}',
      passengerId: passenger.id,
      status: isScheduled || bidding
          ? RideStatus.pending
          : RideStatus.driverArriving,
      driverId: isScheduled || bidding ? null : 1,
      driverName: isScheduled || bidding ? null : 'Demo Driver',
      vehiclePlate: isScheduled || bidding ? null : 'PG DEMO',
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      pickupAddress: pickupAddress,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
      dropoffAddress: dropoffAddress,
      estimatedDistanceKm: estimate.distanceKm,
      estimatedDurationMinutes: estimate.estimatedDurationMinutes,
      estimatedFare: estimate.totalFare,
      offeredFare: bidding ? fare : estimate.totalFare,
      minimumFare: 5,
      isBidding: bidding,
      paymentMethod: paymentMethod,
      vehicleType: vehicleType ?? 'standard',
      productMode: productMode,
      scheduledAt: scheduledAt,
      passengerNote: passengerNote,
      createdAt: DateTime.now(),
      expiresAt: isScheduled
          ? null
          : DateTime.now().add(const Duration(minutes: 15)),
    );
    if (isScheduled) {
      _history.insert(0, ride);
      return ride;
    }
    _activePassengerRide = ride;
    if (bidding) {
      _pendingOffer = ride;
    } else {
      _pendingOffer = null;
      if (ride.driverId != null) {
        _activeDriverRide = ride;
      }
    }
    // Instant without a pre-assigned driver: soft auto-match in demo only.
    if (_demoOn && !bidding && ride.status == RideStatus.pending) {
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (_activePassengerRide?.id != ride.id) return;
        if (_activePassengerRide?.status != RideStatus.pending) return;
        _activePassengerRide = ride.copyWith(
          status: RideStatus.driverAssigned,
          driverId: 7101,
          driverAssignedAt: DateTime.now(),
          finalFare: fare,
          driverName: 'TaxiGo ME',
          vehiclePlate: 'PG TG 100',
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
    final now = DateTime.now();
    final scheduled = _history
        .where((r) =>
            r.status == RideStatus.pending &&
            r.driverId == null &&
            r.scheduledAt != null &&
            r.scheduledAt!.isAfter(now))
        .toList();
    final pending = _pendingOffer;
    if (pending != null &&
        pending.status == RideStatus.pending &&
        (pending.scheduledAt == null || !pending.scheduledAt!.isAfter(now))) {
      return [pending, ...scheduled];
    }
    if (_demoOn) {
      return [_sampleIncomingRide(), ...scheduled];
    }
    return scheduled;
  }

  /// Future scheduled rides claimed by / available to this driver.
  List<RideModel> plannedForDriver({int? driverId}) {
    final now = DateTime.now();
    return _history.where((r) {
      if (r.scheduledAt == null || !r.scheduledAt!.isAfter(now)) return false;
      if (r.status.isTerminal) return false;
      if (r.driverId == null) return true;
      return driverId != null && r.driverId == driverId;
    }).toList()
      ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
  }

  RideModel _sampleIncomingRide() {
    return RideModel(
      id: 8999,
      reference: 'DEMO-REQ',
      passengerId: 1001,
      status: RideStatus.pending,
      pickupLatitude: 42.4410,
      pickupLongitude: 19.2628,
      pickupAddress: 'Trg Republike, Podgorica',
      dropoffLatitude: 42.2864,
      dropoffLongitude: 18.8400,
      dropoffAddress: 'Budva Old Town',
      estimatedDistanceKm: 62.0,
      estimatedDurationMinutes: 55,
      estimatedFare: 85.0,
      offeredFare: 85.0,
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
    for (final ride in _history) {
      if (ride.id == id) return ride;
    }
    if (id == 8999) return _sampleIncomingRide();
    return _activePassengerRide ?? _activeDriverRide;
  }

  List<RideModel> history() {
    final rides = <RideModel>[..._history];
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
    final isFutureScheduled = ride.scheduledAt != null &&
        ride.scheduledAt!.isAfter(DateTime.now());
    final updated = ride.copyWith(
      id: ride.id,
      status: isFutureScheduled
          ? RideStatus.driverAssigned
          : RideStatus.driverArriving,
      driverId: driverId,
      driverAssignedAt: DateTime.now(),
      finalFare: ride.offeredFare ?? ride.estimatedFare,
      driverName: ride.driverName ?? 'Demo Taksi',
      vehiclePlate: ride.vehiclePlate ?? 'PG TG 01',
    );
    _replace(updated);
    _pendingOffer = null;
    if (isFutureScheduled) return;
    _activeDriverRide = updated;
    _activePassengerRide = updated;
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
      _activePassengerRide =
          updated.status.isTerminal ? null : updated;
    }
    if (_activeDriverRide?.id == updated.id) {
      _activeDriverRide = updated.status.isTerminal ? null : updated;
    }
    if (_pendingOffer?.id == updated.id) {
      _pendingOffer = updated.status == RideStatus.pending ? updated : null;
    }
    final idx = _history.indexWhere((r) => r.id == updated.id);
    if (idx >= 0) {
      _history[idx] = updated;
    } else if (updated.status.isTerminal ||
        (updated.scheduledAt != null &&
            updated.scheduledAt!.isAfter(DateTime.now()))) {
      _history.insert(0, updated);
    }
  }

  List<RideMessageModel> rideMessages(int rideId) {
    return List.unmodifiable(_rideMessages[rideId] ?? const []);
  }

  RideMessageModel addRideMessage(
    int rideId,
    String body,
    String? templateKey,
  ) {
    final msg = RideMessageModel(
      id: _nextMessageId++,
      rideId: rideId,
      senderId: 1,
      body: body,
      senderName: _activeAccount?.name ?? 'You',
      templateKey: templateKey,
      isMine: true,
      createdAt: DateTime.now(),
    );
    final list = _rideMessages.putIfAbsent(rideId, () => []);
    list.add(msg);
    return msg;
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
