import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../application/home_bloc.dart';
import '../widgets/destination_search_bar.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_styleLoaded) {
      _styleLoaded = true;
      _loadMapStyle();
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        final ride = state.activeRide;
        if (ride != null &&
            ride.isActive &&
            ride.status != RideStatus.pending) {
          context.go('/ride/${ride.id}');
        }
        final me = state.currentLatLng;
        if (me != null) {
          _centerOnUser(me);
        }
      },
      builder: (context, state) {
        // Prefer real GPS; avoid hardcoding Istanbul while locating.
        final position = state.currentLatLng;

        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position ?? const LatLng(0, 0),
                  zoom: position == null ? 2 : 15,
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
                      infoWindow: const InfoWindow(title: 'Sen'),
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
                      Material(
                        color: AppColors.glass,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => context.push('/account'),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.menu_rounded, color: AppColors.ink),
                                SizedBox(width: 8),
                                Text(
                                  'TaxiGo',
                                  style: TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
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
                left: 16,
                right: 16,
                bottom: 16 + bottomInset,
                child: DestinationSearchBar(
                  nearbyDriverCount: state.nearbyDriverCount,
                  isDemoFleet: state.isDemoFleet,
                  onTap: () => context.push('/destination'),
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
              if (state.status == HomeStatus.failure &&
                  state.errorMessage != null)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 80,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: bottomInset + 72),
            child: FloatingActionButton(
              onPressed: () {
                context.read<HomeBloc>().add(const HomeRefreshDrivers());
                final target = state.currentLatLng;
                if (target != null && _mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(target, 15),
                  );
                }
              },
              tooltip: l10n.currentLocation,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
        );
      },
    );
  }
}
