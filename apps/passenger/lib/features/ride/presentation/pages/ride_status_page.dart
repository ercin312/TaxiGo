import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';
import '../../application/ride_bloc.dart';
import '../../../safety/presentation/widgets/share_trip_button.dart';
import '../../../safety/presentation/widgets/sos_button.dart';
import '../utils/route_geometry.dart';

/// Passenger live tracking: only the matched taxi + tracking line.
class RideStatusPage extends StatelessWidget {
  const RideStatusPage({super.key, required this.rideId});

  final int rideId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          passengerGetIt<RideBloc>()..add(RideWatchStarted(rideId)),
      child: _RideStatusView(rideId: rideId),
    );
  }
}

enum _TrackPhase { waiting, approach, trip, done }

class _RideStatusView extends StatefulWidget {
  const _RideStatusView({required this.rideId});

  final int rideId;

  @override
  State<_RideStatusView> createState() => _RideStatusViewState();
}

class _RideStatusViewState extends State<_RideStatusView>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  List<LatLng> _routePoints = [];
  List<LatLng> _denseRoute = [];

  AnimationController? _moveController;
  late final AnimationController _pulseController;

  _TrackPhase _phase = _TrackPhase.waiting;
  double _progress = 0;
  LatLng? _taxiPosition;
  double _taxiHeading = 0;
  int _routeIndex = 0;
  bool _approachStarted = false;
  bool _tripStarted = false;

  @override
  void initState() {
    super.initState();
    MapMarkerIcons.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseController.addListener(() {
      if (mounted &&
          (_phase == _TrackPhase.approach || _phase == _TrackPhase.trip)) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _moveController?.dispose();
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  bool _isApproach(RideStatus s) =>
      s == RideStatus.driverAssigned ||
      s == RideStatus.driverArriving ||
      s == RideStatus.driverArrived;

  bool _isTrip(RideStatus s) =>
      s == RideStatus.inProgress || s == RideStatus.passengerOnBoard;

  Future<void> _followCamera(LatLng position, double heading) async {
    final controller = _mapController;
    if (controller == null) return;
    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 16.4,
            tilt: 38,
            bearing: heading,
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> _fitBounds(List<LatLng> points) async {
    final controller = _mapController;
    if (controller == null || points.length < 2) return;
    var minLat = points.first.latitude;
    var maxLat = minLat;
    var minLng = points.first.longitude;
    var maxLng = minLng;
    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          80,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onRideUpdated(RideModel ride) async {
    if (_isApproach(ride.status) && !_approachStarted) {
      await _startApproach(ride);
      return;
    }
    if (_isTrip(ride.status) && !_tripStarted) {
      await _startTrip(ride);
    }
  }

  /// Matched taxi moves from a nearby road point → passenger pickup only.
  Future<void> _startApproach(RideModel ride) async {
    _approachStarted = true;
    setState(() => _phase = _TrackPhase.approach);

    final pickup = LatLng(ride.pickupLatitude, ride.pickupLongitude);
    // Start ~600–900m away so approach is visible.
    final start = LatLng(
      pickup.latitude + 0.0065,
      pickup.longitude - 0.0045,
    );

    final result = await passengerGetIt<MapsService>().getDirections(
      originLat: start.latitude,
      originLng: start.longitude,
      destinationLat: pickup.latitude,
      destinationLng: pickup.longitude,
    );

    if (!mounted) return;
    final points = result.fold(
      (_) => [start, pickup],
      (d) => d.points.length >= 2 ? d.points : [start, pickup],
    );
    final dense = RouteGeometry.densify(points, stepMeters: 10);

    setState(() {
      _routePoints = points;
      _denseRoute = dense;
      _taxiPosition = dense.first;
      _taxiHeading = dense.length > 1
          ? RouteGeometry.bearingDegrees(dense.first, dense[1])
          : 0;
      _routeIndex = 0;
      _progress = 0;
    });

    await _fitBounds(points);
    _runMoveAnimation(
      durationSeconds: (RouteGeometry.pathLengthMeters(dense) / 45)
          .clamp(14.0, 35.0),
      onDone: () {
        if (!mounted) return;
        setState(() {
          _taxiPosition = pickup;
          _progress = 1;
          _phase = _TrackPhase.waiting;
        });
        context.read<RideBloc>().add(const RideApproachCompleted());
      },
    );
  }

  Future<void> _startTrip(RideModel ride) async {
    _tripStarted = true;
    setState(() => _phase = _TrackPhase.trip);

    final pickup = LatLng(ride.pickupLatitude, ride.pickupLongitude);
    final dropoff = LatLng(ride.dropoffLatitude, ride.dropoffLongitude);

    final result = await passengerGetIt<MapsService>().getDirections(
      originLat: pickup.latitude,
      originLng: pickup.longitude,
      destinationLat: dropoff.latitude,
      destinationLng: dropoff.longitude,
    );

    if (!mounted) return;
    final points = result.fold(
      (_) => [pickup, dropoff],
      (d) => d.points.length >= 2 ? d.points : [pickup, dropoff],
    );
    final dense = RouteGeometry.densify(points, stepMeters: 10);

    setState(() {
      _routePoints = points;
      _denseRoute = dense;
      _taxiPosition = dense.first;
      _taxiHeading = dense.length > 1
          ? RouteGeometry.bearingDegrees(dense.first, dense[1])
          : 0;
      _routeIndex = 0;
      _progress = 0;
    });

    await _fitBounds(points);
    _runMoveAnimation(
      durationSeconds: (RouteGeometry.pathLengthMeters(dense) / 55)
          .clamp(18.0, 55.0),
      onDone: () {
        if (!mounted) return;
        setState(() {
          _phase = _TrackPhase.done;
          _progress = 1;
          if (_denseRoute.isNotEmpty) {
            _taxiPosition = _denseRoute.last;
            _routeIndex = _denseRoute.length - 1;
          }
        });
        context.read<RideBloc>().add(const RideTripAnimationCompleted());
      },
    );
  }

  void _runMoveAnimation({
    required double durationSeconds,
    required VoidCallback onDone,
  }) {
    _moveController?.dispose();
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (durationSeconds * 1000).round()),
    );
    _moveController = controller;

    controller.addListener(() {
      if (_denseRoute.isEmpty) return;
      final t = Curves.easeInOutCubic.transform(controller.value);
      final sample = RouteGeometry.sample(_denseRoute, t);
      setState(() {
        _progress = t;
        _taxiPosition = sample.position;
        _taxiHeading = sample.heading;
        _routeIndex = sample.index;
      });
      if ((controller.value * 30).round() % 2 == 0) {
        unawaited(_followCamera(sample.position, sample.heading));
      }
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) onDone();
    });

    unawaited(controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<RideBloc, RideState>(
      listener: (context, state) {
        if (state.status == RideBlocStatus.completed) {
          context.go('/ride-completed/${widget.rideId}');
        } else if (state.status == RideBlocStatus.cancelled) {
          context.go('/home');
        } else if (state.ride != null) {
          _onRideUpdated(state.ride!);
        }
      },
      builder: (context, state) {
        final ride = state.ride;
        final status = ride?.status ?? RideStatus.pending;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _phase == _TrackPhase.approach
                  ? 'Taksiniz geliyor'
                  : _phase == _TrackPhase.trip
                      ? 'Sürüş devam ediyor'
                      : rideStatusLabel(l10n, status),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              ShareTripButton(rideId: widget.rideId),
              const SizedBox(width: 8),
              SosButton(rideId: widget.rideId),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              if (state.status == RideBlocStatus.loading)
                const LinearProgressIndicator(minHeight: 3),
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          ride?.pickupLatitude ?? 41.0082,
                          ride?.pickupLongitude ?? 28.9784,
                        ),
                        zoom: 15,
                      ),
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      markers: _buildMarkers(ride),
                      polylines: _buildPolylines(),
                      onMapCreated: (controller) async {
                        _mapController = controller;
                        if (_routePoints.isNotEmpty) {
                          await _fitBounds(_routePoints);
                        }
                      },
                    ),
                    if (_phase == _TrackPhase.approach ||
                        _phase == _TrackPhase.trip)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: _LiveBanner(
                          pulse: _pulseController,
                          progress: _progress,
                          title: _phase == _TrackPhase.approach
                              ? 'Anlaştığın taksi sana geliyor'
                              : 'Varışa gidiyorsunuz',
                          subtitle: _phase == _TrackPhase.approach
                              ? '${ride?.vehiclePlate ?? 'Taksi'} · ${ride?.driverName ?? 'Sürücü'}'
                              : 'Sadece senin taksin haritada',
                        ),
                      ),
                  ],
                ),
              ),
              _RideStatusPanel(
                ride: ride,
                status: status,
                phase: _phase,
                progress: _progress,
                plate: ride?.vehiclePlate ?? 'Taksi',
                driverName: ride?.driverName ?? 'Sürücü',
              ),
              if (state.status == RideBlocStatus.failure &&
                  state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Set<Polyline> _buildPolylines() {
    if (_denseRoute.length < 2) return {};
    final traveled = _denseRoute.sublist(
      0,
      (_routeIndex + 1).clamp(1, _denseRoute.length),
    );
    final remaining = RouteGeometry.remainingFrom(_denseRoute, _routeIndex);
    final glow = _pulseController.value;

    // Clear tracking line: remaining path taxi will follow.
    return {
      if (remaining.length >= 2)
        Polyline(
          polylineId: const PolylineId('track_remaining'),
          points: remaining,
          color: _phase == _TrackPhase.approach
              ? AppColors.accent.withValues(alpha: 0.45 + glow * 0.4)
              : AppColors.primary.withValues(alpha: 0.35 + glow * 0.35),
          width: 6,
          patterns: _phase == _TrackPhase.approach
              ? const <PatternItem>[]
              : [PatternItem.dash(18), PatternItem.gap(10)],
          jointType: JointType.round,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
        ),
      if (traveled.length >= 2)
        Polyline(
          polylineId: const PolylineId('track_done'),
          points: traveled,
          color: AppColors.primary,
          width: 7,
          jointType: JointType.round,
        ),
    };
  }

  Set<Marker> _buildMarkers(RideModel? ride) {
    if (ride == null) return {};
    final pickup = LatLng(ride.pickupLatitude, ride.pickupLongitude);
    final dropoff = LatLng(ride.dropoffLatitude, ride.dropoffLongitude);

    final markers = <Marker>{
      // Passenger meeting point — always visible during approach.
      Marker(
        markerId: const MarkerId('you'),
        position: pickup,
        icon: MapMarkerIcons.pickupOrDefault,
        infoWindow: const InfoWindow(
          title: 'Sen buradasın',
          snippet: 'Biniş noktası',
        ),
      ),
    };

    // Dropoff only after trip starts — avoid confusion during pickup.
    if (_phase == _TrackPhase.trip || _phase == _TrackPhase.done) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: dropoff,
          icon: MapMarkerIcons.dropoffOrDefault,
          infoWindow: const InfoWindow(title: 'Varış'),
        ),
      );
    }

    final taxiPos = _taxiPosition;
    if (taxiPos != null && _phase != _TrackPhase.waiting) {
      markers.add(
        Marker(
          markerId: const MarkerId('matched_taxi'),
          position: taxiPos,
          icon: MapMarkerIcons.taxiOrDefault,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          rotation: _taxiHeading,
          infoWindow: InfoWindow(
            title: 'Senin taksin',
            snippet:
                '${ride.vehiclePlate ?? 'Taksi'} · ${ride.driverName ?? 'Sürücü'}',
          ),
        ),
      );
    }

    return markers;
  }
}

class _LiveBanner extends StatelessWidget {
  const _LiveBanner({
    required this.pulse,
    required this.progress,
    required this.title,
    required this.subtitle,
  });

  final Animation<double> pulse;
  final double progress;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        return Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          color: AppColors.ink.withValues(alpha: 0.9),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent
                            .withValues(alpha: 0.45 + pulse.value * 0.55),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      '%${(progress * 100).round()}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RideStatusPanel extends StatelessWidget {
  const _RideStatusPanel({
    required this.ride,
    required this.status,
    required this.phase,
    required this.progress,
    required this.plate,
    required this.driverName,
  });

  final RideModel? ride;
  final RideStatus status;
  final _TrackPhase phase;
  final double progress;
  final String plate;
  final String driverName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isApproach = phase == _TrackPhase.approach;
    final isTrip = phase == _TrackPhase.trip;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isApproach
                  ? 'Taksiniz sana geliyor'
                  : isTrip
                      ? 'Varış noktasına gidiliyor…'
                      : rideStatusLabel(l10n, status),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Material(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                dense: true,
                leading: Icon(Icons.local_taxi, color: AppColors.primary),
                title: Text(
                  plate,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('$driverName · sadece bu araca bin'),
              ),
            ),
            if (ride != null) ...[
              const SizedBox(height: 8),
              Text(
                isApproach
                    ? 'Biniş: ${ride!.pickupAddress}'
                    : '${ride!.pickupAddress} → ${ride!.dropoffAddress}',
              ),
              if (ride!.estimatedFare != null)
                Text(
                  '${ride!.estimatedFare!.toStringAsFixed(2)} ${AppConstants.currency}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
            if (isApproach || isTrip) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: AppColors.accent,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (status == RideStatus.pending ||
                status == RideStatus.driverAssigned ||
                status == RideStatus.driverArriving)
              OutlinedButton(
                onPressed: () {
                  context.read<RideBloc>().add(const RideCancelRequested());
                },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.cancelRide),
              ),
          ],
        ),
      ),
    );
  }
}
