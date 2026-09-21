import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../../shell/presentation/widgets/section_header.dart';
import '../../application/booking_bloc.dart';

class DestinationPage extends StatefulWidget {
  const DestinationPage({super.key});

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _pickupFocus = FocusNode();
  final _dropoffFocus = FocusNode();
  GoogleMapController? _mapController;
  LatLng? _pickup;
  LatLng? _dropoff;
  String _pickupAddress = '';
  String _dropoffAddress = '';
  bool _editingPickup = false;
  bool _showMapPicker = false;
  List<PlacePrediction> _predictions = [];
  List<SavedAddress> _saved = [];
  List<RecentPlace> _recents = [];
  Timer? _debounce;
  bool _searching = false;
  bool _locating = true;

  @override
  void initState() {
    super.initState();
    _saved = passengerGetIt<SavedAddressService>().list();
    _recents = passengerGetIt<RecentPlacesService>().list();
    MapMarkerIcons.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
    _initPickup();
    _dropoffFocus.requestFocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocus.dispose();
    _dropoffFocus.dispose();
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
          : const LatLng(
              AppConstants.defaultLatitude,
              AppConstants.defaultLongitude,
            );
      final address = await _reverseGeocode(pickup);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _pickup = pickup;
        _pickupAddress = address.isEmpty
            ? (position != null
                ? l10n.currentLocation
                : l10n.podgoricaMontenegro)
            : address;
        _pickupController.text = _pickupAddress;
        _locating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        if (_pickupAddress.isEmpty) {
          _pickupAddress =
              AppLocalizations.of(context)!.locationUnavailableMapSelect;
          _pickupController.text = _pickupAddress;
        }
      });
    }
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

  void _onQueryChanged(String value) {
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
        latitude: _pickup?.latitude ?? AppConstants.defaultLatitude,
        longitude: _pickup?.longitude ?? AppConstants.defaultLongitude,
        languageCode: Localizations.localeOf(context).languageCode,
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      },
      (place) async {
        final point = LatLng(place.latitude, place.longitude);
        final address =
            place.address.isNotEmpty ? place.address : prediction.description;
        final name = place.name ?? prediction.mainText ?? address;
        setState(() {
          _predictions = [];
          if (_editingPickup) {
            _pickup = point;
            _pickupAddress = address;
            _pickupController.text = address;
          } else {
            _dropoff = point;
            _dropoffAddress = address;
            _dropoffController.text = address;
          }
        });
        await passengerGetIt<RecentPlacesService>().add(
          RecentPlace(
            id: prediction.placeId,
            name: name,
            address: address,
            latitude: place.latitude,
            longitude: place.longitude,
          ),
        );
        setState(() => _recents = passengerGetIt<RecentPlacesService>().list());
        _pickupFocus.unfocus();
        _dropoffFocus.unfocus();
      },
    );
  }

  void _swap() {
    setState(() {
      final p = _pickup;
      final pa = _pickupAddress;
      _pickup = _dropoff;
      _pickupAddress = _dropoffAddress;
      _dropoff = p;
      _dropoffAddress = pa;
      _pickupController.text = _pickupAddress;
      _dropoffController.text = _dropoffAddress;
    });
  }

  void _applySaved(SavedAddress saved) {
    final point = LatLng(saved.latitude, saved.longitude);
    setState(() {
      if (_editingPickup) {
        _pickup = point;
        _pickupAddress = saved.address;
        _pickupController.text = saved.address;
      } else {
        _dropoff = point;
        _dropoffAddress = saved.address;
        _dropoffController.text = saved.address;
      }
    });
  }

  SavedAddress? _byLabel(String label) {
    final lower = label.toLowerCase();
    for (final s in _saved) {
      if (s.label.toLowerCase() == lower ||
          s.id == lower ||
          s.id == 'home' && lower == 'home' ||
          s.id == 'work' && lower == 'work') {
        return s;
      }
    }
    // Prefer id-based home/work slots.
    for (final s in _saved) {
      if (s.id == label) return s;
    }
    return null;
  }

  Future<void> _onMapTap(LatLng point) async {
    final address = await _reverseGeocode(point);
    setState(() {
      if (_editingPickup) {
        _pickup = point;
        _pickupAddress = address;
        _pickupController.text = address;
      } else {
        _dropoff = point;
        _dropoffAddress = address;
        _dropoffController.text = address;
      }
    });
  }

  Future<void> _showOutOfServiceDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(l10n.outOfServiceTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.outOfServiceBody),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flight, color: AppColors.ink),
              title: Text(AppConstants.podgoricaAirportLabel),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _pickup = const LatLng(
                    AppConstants.podgoricaAirportLat,
                    AppConstants.podgoricaAirportLng,
                  );
                  _pickupAddress = AppConstants.podgoricaAirportLabel;
                  _pickupController.text = _pickupAddress;
                });
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flight, color: AppColors.ink),
              title: Text(AppConstants.tivatAirportLabel),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _pickup = const LatLng(
                    AppConstants.tivatAirportLat,
                    AppConstants.tivatAirportLng,
                  );
                  _pickupAddress = AppConstants.tivatAirportLabel;
                  _pickupController.text = _pickupAddress;
                });
              },
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _continue(BuildContext context) {
    if (_pickup == null || _dropoff == null) return;
    if (!AppConstants.isInsideServiceArea(
      _pickup!.latitude,
      _pickup!.longitude,
    )) {
      _showOutOfServiceDialog();
      return;
    }
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
    final home = _byLabel('home') ?? _byLabel(l10n.homeLabel);
    final work = _byLabel('work') ?? _byLabel(l10n.workLabel);

    return BlocProvider(
      create: (_) => passengerGetIt<BookingBloc>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: Text(l10n.searchDestination),
              backgroundColor: AppColors.backgroundLight,
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _AddressField(
                            controller: _pickupController,
                            focusNode: _pickupFocus,
                            icon: Icons.circle,
                            iconColor: AppColors.success,
                            hint: l10n.pickup,
                            loading: _locating,
                            onChanged: (v) {
                              setState(() => _editingPickup = true);
                              _onQueryChanged(v);
                            },
                            onTap: () =>
                                setState(() => _editingPickup = true),
                          ),
                          const SizedBox(height: 10),
                          _AddressField(
                            controller: _dropoffController,
                            focusNode: _dropoffFocus,
                            icon: Icons.location_on_rounded,
                            iconColor: AppColors.error,
                            hint: l10n.arrivalAddress,
                            onChanged: (v) {
                              setState(() => _editingPickup = false);
                              _onQueryChanged(v);
                            },
                            onTap: () =>
                                setState(() => _editingPickup = false),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 8,
                        top: 36,
                        child: Material(
                          color: AppColors.surfaceLight,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: IconButton(
                            tooltip: l10n.swapLocations,
                            onPressed: _swap,
                            icon: const Icon(Icons.swap_vert_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _ShortcutChip(
                        icon: Icons.home_outlined,
                        label: '+ ${l10n.homeLabel}',
                        onTap: () {
                          if (home != null) {
                            _applySaved(home);
                          } else {
                            context.push('/favorites');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _ShortcutChip(
                        icon: Icons.work_outline_rounded,
                        label: '+ ${l10n.workLabel}',
                        onTap: () {
                          if (work != null) {
                            _applySaved(work);
                          } else {
                            context.push('/favorites');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _ShortcutChip(
                        icon: Icons.add_rounded,
                        label: '+ ${l10n.othersLabel}',
                        onTap: () => context.push('/favorites'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _showMapPicker
                      ? GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _pickup ??
                                const LatLng(
                                  AppConstants.defaultLatitude,
                                  AppConstants.defaultLongitude,
                                ),
                            zoom: 14,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          onTap: _onMapTap,
                          onMapCreated: (c) => _mapController = c,
                          markers: {
                            if (_pickup != null)
                              Marker(
                                markerId: const MarkerId('pickup'),
                                position: _pickup!,
                                icon: MapMarkerIcons.pickupOrDefault,
                              ),
                            if (_dropoff != null)
                              Marker(
                                markerId: const MarkerId('dropoff'),
                                position: _dropoff!,
                                icon: MapMarkerIcons.dropoffOrDefault,
                              ),
                          },
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          children: [
                            if (_predictions.isNotEmpty) ...[
                              SectionHeader(title: l10n.searchResults),
                              ..._predictions.map(
                                (p) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.place_outlined,
                                    color: AppColors.accentDeep,
                                  ),
                                  title: Text(p.mainText ?? p.description),
                                  subtitle: p.secondaryText == null
                                      ? null
                                      : Text(p.secondaryText!),
                                  onTap: () => _selectPrediction(p),
                                ),
                              ),
                              if (_searching)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            ] else ...[
                              SectionHeader(title: l10n.searchPlace),
                              if (_recents.isEmpty)
                                Text(
                                  l10n.noRecentDestinations,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondaryLight,
                                      ),
                                )
                              else
                                ..._recents.map(
                                  (r) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.history_rounded,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                    title: Text(
                                      r.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(r.address),
                                    onTap: () {
                                      setState(() {
                                        final point =
                                            LatLng(r.latitude, r.longitude);
                                        if (_editingPickup) {
                                          _pickup = point;
                                          _pickupAddress = r.address;
                                          _pickupController.text = r.address;
                                        } else {
                                          _dropoff = point;
                                          _dropoffAddress = r.address;
                                          _dropoffController.text = r.address;
                                        }
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ],
                        ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _showMapPicker = !_showMapPicker),
                        icon: const Icon(Icons.map_outlined),
                        label: Text(l10n.selectFromMap),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(color: AppColors.ink),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.onChanged,
    required this.onTap,
    this.loading = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData icon;
  final Color iconColor;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceLight,
        prefixIcon: loading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Icon(icon, color: iconColor, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.dividerLight.withValues(alpha: 0.8),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.dividerLight.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.accentDeep),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surfaceLight,
      side: BorderSide(color: AppColors.dividerLight.withValues(alpha: 0.8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
