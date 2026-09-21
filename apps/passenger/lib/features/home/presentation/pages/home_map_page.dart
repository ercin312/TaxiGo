import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../application/home_bloc.dart';
import '../../../booking/presentation/widgets/vehicle_option_card.dart';
import '../../../safety/presentation/widgets/sos_button.dart';
import '../widgets/map_zoom_controls.dart';

class HomeMapPage extends StatelessWidget {
  const HomeMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => passengerGetIt<HomeBloc>()..add(const HomeStarted()),
      child: const _HomeMapView(),
    );
  }
}

class _HomeMapView extends StatefulWidget {
  const _HomeMapView();

  @override
  State<_HomeMapView> createState() => _HomeMapViewState();
}

class _HomeMapViewState extends State<_HomeMapView> {
  String? _mapStyle;
  GoogleMapController? _mapController;
  bool _styleLoaded = false;
  bool _centeredOnUser = false;
  List<RecentPlace> _recents = [];
  String? _pickupLabel;

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_styleLoaded) {
      _styleLoaded = true;
      _loadMapStyle();
    }
  }

  Future<void> _loadRecents() async {
    final places = passengerGetIt<RecentPlacesService>().list();
    if (!mounted) return;
    setState(() => _recents = places);
  }

  Future<void> _loadMapStyle() async {
    final style = await MapStyleLoader.loadForBrightness(Brightness.light);
    if (!mounted) return;
    setState(() => _mapStyle = style);
    if (_mapController != null && style != null) {
      try {
        await _mapController!.setMapStyle(style);
      } catch (_) {}
    }
  }

  Future<void> _centerOnUser(LatLng target) async {
    final controller = _mapController;
    if (controller == null || _centeredOnUser) return;
    _centeredOnUser = true;
    try {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(target, 15));
    } catch (_) {}
  }

  Future<void> _resolvePickupLabel(LatLng? me) async {
    if (me == null || _pickupLabel != null) return;
    try {
      final marks = await placemarkFromCoordinates(me.latitude, me.longitude);
      if (!mounted || marks.isEmpty) return;
      final p = marks.first;
      final parts = [
        p.thoroughfare,
        p.subLocality,
        p.locality,
      ].whereType<String>().where((e) => e.isNotEmpty);
      setState(() => _pickupLabel = parts.join(', '));
    } catch (_) {}
  }

  String _greeting(AppLocalizations l10n, String name) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return l10n.greetingMorning(name);
    if (hour >= 12 && hour < 17) return l10n.greetingAfternoon(name);
    if (hour >= 17 && hour < 22) return l10n.greetingEvening(name);
    return l10n.greetingNight(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final user = context.watch<AuthBloc>().state.user;
    final firstName = (user?.name ?? 'TaxiGo').split(' ').first;

    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        final ride = state.activeRide;
        if (ride != null && ride.isActive) {
          if (ride.status == RideStatus.pending && ride.isBidding) {
            context.go('/bidding/${ride.id}');
          } else {
            context.go('/ride/${ride.id}');
          }
        }
        final me = state.currentLatLng;
        if (me != null) {
          _centerOnUser(me);
          _resolvePickupLabel(me);
        }
      },
      builder: (context, state) {
        final position = state.currentLatLng;

        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position ??
                      const LatLng(
                        AppConstants.defaultLatitude,
                        AppConstants.defaultLongitude,
                      ),
                  zoom: position == null ? AppConstants.defaultMapZoom : 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: {
                  ...state.driverMarkers,
                  if (state.currentLatLng != null)
                    Marker(
                      markerId: const MarkerId('me'),
                      position: state.currentLatLng!,
                      icon: MapMarkerIcons.pickupOrDefault,
                      infoWindow: InfoWindow(title: l10n.youAreHere),
                    ),
                },
                polylines: state.driverTrails,
                onMapCreated: (controller) async {
                  _mapController = controller;
                  await MapMarkerIcons.ensureLoaded();
                  if (mounted) setState(() {});
                  if (_mapStyle != null) {
                    await controller.setMapStyle(_mapStyle);
                  }
                  final me = context.read<HomeBloc>().state.currentLatLng;
                  if (me != null) {
                    await _centerOnUser(me);
                  }
                },
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: AppColors.glass,
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.my_location_rounded,
                                  size: 18,
                                  color: AppColors.accentDeep,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _pickupLabel ??
                                        l10n.podgoricaMontenegro,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.ink,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const SosButton(),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: MediaQuery.paddingOf(context).top + 72,
                child: MapZoomControls(controller: _mapController),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 72 + bottomInset,
                child: _HomeSheet(
                  greeting: _greeting(l10n, firstName),
                  nearbyLabel: l10n.nearbyDrivers(state.nearbyDriverCount),
                  recents: _recents,
                  onSearch: () => context.push('/destination'),
                  onLocate: () {
                    context.read<HomeBloc>().add(const HomeRefreshDrivers());
                    final target = state.currentLatLng;
                    if (target != null && _mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(target, 15),
                      );
                    }
                  },
                ),
              ),
              if (state.status == HomeStatus.loading)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 88,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeSheet extends StatelessWidget {
  const _HomeSheet({
    required this.greeting,
    required this.onSearch,
    required this.onLocate,
    required this.recents,
    this.nearbyLabel,
  });

  final String greeting;
  final String? nearbyLabel;
  final VoidCallback onSearch;
  final VoidCallback onLocate;
  final List<RecentPlace> recents;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 36, end: 0),
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: Opacity(
              opacity: (1 - value / 36).clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'home_locate',
            onPressed: onLocate,
            backgroundColor: AppColors.surfaceLight,
            foregroundColor: AppColors.ink,
            child: const Icon(Icons.my_location_rounded),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              gradient: AppColors.sheetGradient,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.dividerLight.withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                ),
                const SizedBox(height: 14),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSearch,
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.45),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.homeTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  if (nearbyLabel != null)
                                    Text(
                                      nearbyLabel!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            const AnimatedVehicleImage(
                              vehicleType: 'standard',
                              size: 42,
                              animate: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (recents.isEmpty)
                  Text(
                    l10n.noRecentDestinations,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  )
                else
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recents.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final place = recents[index];
                        return Material(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: onSearch,
                            child: Container(
                              width: 220,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.dividerLight
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.history_rounded,
                                    color: AppColors.accentDeep,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          place.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          place.address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
