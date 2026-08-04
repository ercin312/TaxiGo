import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../application/booking_bloc.dart';

class DestinationPage extends StatefulWidget {
  const DestinationPage({super.key});

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  GoogleMapController? _mapController;
  LatLng? _pickup;
  LatLng? _dropoff;
  String _pickupAddress = '';
  String _dropoffAddress = '';
  bool _selectingDropoff = true;
  List<PlacePrediction> _predictions = [];
  List<SavedAddress> _saved = [];
  Timer? _debounce;
  bool _searching = false;
  bool _locating = true;
  List<LatLng> _routePoints = [];
  bool _loadingRoute = false;

  @override
  void initState() {
    super.initState();
    _saved = passengerGetIt<SavedAddressService>().list();
    MapMarkerIcons.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
    _initPickup();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initPickup() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position? position;
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 8),
            ),
          );
        } catch (_) {
          position = await Geolocator.getLastKnownPosition();
        }
      }

      final pickup = position != null
          ? LatLng(position.latitude, position.longitude)
          : null;
      if (pickup == null) {
        if (!mounted) return;
        setState(() {
          _locating = false;
          _pickupAddress = 'Konum alınamadı — haritadan seçin';
        });
        return;
      }
      final address = await _reverseGeocode(pickup);
      if (!mounted) return;
      setState(() {
        _pickup = pickup;
        _pickupAddress = address.isEmpty ? 'Mevcut konum' : address;
        _locating = false;
      });
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(pickup, 15),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        if (_pickupAddress.isEmpty) {
          _pickupAddress = 'Konum alınamadı — haritadan seçin';
        }
      });
    }
  }

  Future<void> _refreshRoadRoute() async {
    final pickup = _pickup;
    final dropoff = _dropoff;
    if (pickup == null || dropoff == null) {
      setState(() => _routePoints = []);
      return;
    }
    setState(() => _loadingRoute = true);
    final result = await passengerGetIt<MapsService>().getDirections(
      originLat: pickup.latitude,
      originLng: pickup.longitude,
      destinationLat: dropoff.latitude,
      destinationLng: dropoff.longitude,
    );
    if (!mounted) return;
    final points = result.fold(
      (_) => <LatLng>[pickup, dropoff],
      (directions) =>
          directions.points.length >= 2 ? directions.points : [pickup, dropoff],
    );
    setState(() {
      _routePoints = points;
      _loadingRoute = false;
    });
    await _fitRoute();
  }

  Future<void> _fitRoute() async {
    final controller = _mapController;
    if (controller == null || _routePoints.length < 2) return;
    var minLat = _routePoints.first.latitude;
    var maxLat = minLat;
    var minLng = _routePoints.first.longitude;
    var maxLng = minLng;
    for (final p in _routePoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          64,
        ),
      );
    } catch (_) {}
  }

  Future<String> _reverseGeocode(LatLng point) async {
    try {
      final places = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (places.isEmpty) return '${point.latitude}, ${point.longitude}';
      final p = places.first;
          return [p.street, p.subLocality, p.locality, p.country]
              .whereType<String>()
              .where((e) => e.isNotEmpty)
              .join(', ');
    } catch (_) {
      return '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _predictions = [];
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 280), () async {
      if (!mounted) return;
      setState(() => _searching = true);
      final result = await passengerGetIt<MapsService>().autocomplete(
        query: value.trim(),
        latitude: _pickup?.latitude,
        longitude: _pickup?.longitude,
      );
      if (!mounted) return;
      result.fold(
        (_) => setState(() {
          _predictions = [];
          _searching = false;
        }),
        (list) => setState(() {
          _predictions = list;
          _searching = false;
        }),
      );
    });
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    final details =
        await passengerGetIt<MapsService>().placeDetails(prediction.placeId);
    if (!mounted) return;
    await details.fold(
      (error) async {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      },
      (place) async {
        final point = LatLng(place.latitude, place.longitude);
        final address =
            place.address.isNotEmpty ? place.address : prediction.description;
        setState(() {
          _searchController.clear();
          _predictions = [];
          if (_selectingDropoff) {
            _dropoff = point;
            _dropoffAddress = address;
          } else {
            _pickup = point;
            _pickupAddress = address;
          }
        });
        _searchFocus.unfocus();
        await _refreshRoadRoute();
        if (_dropoff == null) {
          await _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(point, 15),
          );
        }
      },
    );
  }

  Future<void> _onMapTap(LatLng point) async {
    final address = await _reverseGeocode(point);
    setState(() {
      if (_selectingDropoff) {
        _dropoff = point;
        _dropoffAddress = address;
      } else {
        _pickup = point;
        _pickupAddress = address;
      }
    });
    await _refreshRoadRoute();
  }

  void _applySaved(SavedAddress saved) {
    final point = LatLng(saved.latitude, saved.longitude);
    setState(() {
      if (_selectingDropoff) {
        _dropoff = point;
        _dropoffAddress = saved.address;
      } else {
        _pickup = point;
        _pickupAddress = saved.address;
      }
    });
    _refreshRoadRoute();
  }

  Future<void> _saveCurrentDropoff() async {
    if (_dropoff == null || _dropoffAddress.isEmpty) return;
    final labelController = TextEditingController(text: 'Ev');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adresi kaydet'),
        content: TextField(
          controller: labelController,
          decoration: const InputDecoration(labelText: 'Etiket (Ev, İş...)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await passengerGetIt<SavedAddressService>().save(
      SavedAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: labelController.text.trim().isEmpty
            ? 'Kayıtlı'
            : labelController.text.trim(),
        address: _dropoffAddress,
        latitude: _dropoff!.latitude,
        longitude: _dropoff!.longitude,
      ),
    );
    setState(() => _saved = passengerGetIt<SavedAddressService>().list());
  }

  void _continue(BuildContext context) {
    if (_pickup == null || _dropoff == null) return;
    context.read<BookingBloc>().add(
          BookingLocationsSet(
            pickupLat: _pickup!.latitude,
            pickupLng: _pickup!.longitude,
            pickupAddress: _pickupAddress,
            dropoffLat: _dropoff!.latitude,
            dropoffLng: _dropoff!.longitude,
            dropoffAddress: _dropoffAddress,
          ),
        );
    context.push('/confirm-booking', extra: context.read<BookingBloc>());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return BlocProvider(
      create: (_) => passengerGetIt<BookingBloc>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.searchDestination)),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Material(
                    color: AppColors.glass,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      leading: _locating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location,
                              color: AppColors.success),
                      title: Text(l10n.pickup),
                      subtitle: Text(
                        _pickupAddress.isEmpty
                            ? 'Konum alınıyor...'
                            : _pickupAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        tooltip: 'Konumu yenile',
                        onPressed: _initPickup,
                        icon: const Icon(Icons.refresh),
                      ),
                      onTap: () {
                        setState(() => _selectingDropoff = false);
                        if (_pickup != null) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(_pickup!, 15),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: _selectingDropoff
                          ? 'Varış noktası ara (örn. Taksim, Kadıköy...)'
                          : 'Alış noktası ara...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : (_searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _predictions = []);
                                  },
                                )
                              : null),
                    ),
                  ),
                ),
                if (_predictions.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Card(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _predictions.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final p = _predictions[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.place_outlined,
                                color: AppColors.accent),
                            title: Text(p.mainText ?? p.description),
                            subtitle: p.secondaryText == null
                                ? null
                                : Text(p.secondaryText!),
                            onTap: () => _selectPrediction(p),
                          );
                        },
                      ),
                    ),
                  ),
                if (_saved.isNotEmpty)
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      scrollDirection: Axis.horizontal,
                      itemCount: _saved.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final s = _saved[index];
                        return ActionChip(
                          avatar: const Icon(Icons.bookmark, size: 16),
                          label: Text(s.label),
                          onPressed: () => _applySaved(s),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(l10n.pickup),
                        selected: !_selectingDropoff,
                        onSelected: (_) =>
                            setState(() => _selectingDropoff = false),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(l10n.dropoff),
                        selected: _selectingDropoff,
                        onSelected: (_) {
                          setState(() => _selectingDropoff = true);
                          _searchFocus.requestFocus();
                        },
                      ),
                      const Spacer(),
                      Text(
                        _selectingDropoff
                            ? 'Haritaya dokun: varış'
                            : 'Haritaya dokun: alış',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _pickup ?? const LatLng(0, 0),
                          zoom: _pickup == null ? 2 : 14,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        onTap: _onMapTap,
                        onMapCreated: (controller) async {
                          _mapController = controller;
                          if (_pickup != null && _dropoff == null) {
                            await controller.animateCamera(
                              CameraUpdate.newLatLngZoom(_pickup!, 15),
                            );
                          } else if (_routePoints.length >= 2) {
                            await _fitRoute();
                          }
                        },
                        polylines: {
                          if (_routePoints.length >= 2)
                            Polyline(
                              polylineId: const PolylineId('road_route'),
                              points: _routePoints,
                              color: AppColors.primary,
                              width: 5,
                              jointType: JointType.round,
                              endCap: Cap.roundCap,
                              startCap: Cap.roundCap,
                            ),
                        },
                        markers: {
                          if (_pickup != null)
                            Marker(
                              markerId: const MarkerId('pickup'),
                              position: _pickup!,
                              icon: MapMarkerIcons.pickupOrDefault,
                              infoWindow: InfoWindow(
                                title: l10n.pickup,
                                snippet: _pickupAddress,
                              ),
                            ),
                          if (_dropoff != null)
                            Marker(
                              markerId: const MarkerId('dropoff'),
                              position: _dropoff!,
                              icon: MapMarkerIcons.dropoffOrDefault,
                              infoWindow: InfoWindow(
                                title: l10n.dropoff,
                                snippet: _dropoffAddress,
                              ),
                            ),
                        },
                      ),
                      if (_loadingRoute)
                        const Positioned(
                          top: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text('Yol tarifi çiziliyor…'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_dropoffAddress.isNotEmpty)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading:
                              const Icon(Icons.place, color: AppColors.error),
                          title: Text(l10n.dropoff),
                          subtitle: Text(_dropoffAddress),
                          trailing: IconButton(
                            tooltip: 'Kaydet',
                            onPressed: _saveCurrentDropoff,
                            icon: const Icon(Icons.bookmark_add_outlined),
                          ),
                        ),
                      PrimaryButton(
                        label: l10n.continueButton,
                        onPressed: _pickup != null && _dropoff != null
                            ? () => _continue(context)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
