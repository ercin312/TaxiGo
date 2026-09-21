import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../../shell/presentation/widgets/soft_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<SavedAddress> _saved = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _saved = passengerGetIt<SavedAddressService>().list());
  }

  SavedAddress? _slot(String id, String label) {
    for (final s in _saved) {
      if (s.id == id) return s;
    }
    for (final s in _saved) {
      if (s.label.toLowerCase() == label.toLowerCase()) return s;
    }
    return null;
  }

  Future<void> _editSlot({
    required String id,
    required String defaultLabel,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final existing = _slot(id, defaultLabel);
    final labelCtrl = TextEditingController(text: existing?.label ?? defaultLabel);
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    double? lat = existing?.latitude;
    double? lng = existing?.longitude;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.saveAddress,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelCtrl,
                decoration: InputDecoration(labelText: l10n.addressLabelHint),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressCtrl,
                decoration: InputDecoration(labelText: l10n.arrivalAddress),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final pos = await Geolocator.getCurrentPosition();
                  final point = LatLng(pos.latitude, pos.longitude);
                  lat = point.latitude;
                  lng = point.longitude;
                  try {
                    final marks = await placemarkFromCoordinates(
                      point.latitude,
                      point.longitude,
                    );
                    if (marks.isNotEmpty) {
                      final p = marks.first;
                      addressCtrl.text = [
                        p.street,
                        p.locality,
                      ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
                    }
                  } catch (_) {}
                },
                icon: const Icon(Icons.my_location),
                label: Text(l10n.currentLocation),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: l10n.save,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );
      },
    );

    if (ok != true || !mounted) return;
    if (lat == null || lng == null) {
      lat ??= AppConstants.defaultLatitude;
      lng ??= AppConstants.defaultLongitude;
    }
    await passengerGetIt<SavedAddressService>().save(
      SavedAddress(
        id: id,
        label: labelCtrl.text.trim().isEmpty
            ? defaultLabel
            : labelCtrl.text.trim(),
        address: addressCtrl.text.trim().isEmpty
            ? defaultLabel
            : addressCtrl.text.trim(),
        latitude: lat!,
        longitude: lng!,
      ),
    );
    _reload();
  }

  Future<void> _addCustom() async {
    final l10n = AppLocalizations.of(context)!;
    await _editSlot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      defaultLabel: l10n.savedLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final home = _slot('home', l10n.homeLabel);
    final work = _slot('work', l10n.workLabel);
    final others = _saved
        .where((s) => s.id != 'home' && s.id != 'work')
        .where((s) =>
            s.label.toLowerCase() != l10n.homeLabel.toLowerCase() &&
            s.label.toLowerCase() != l10n.workLabel.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.favoriteLocations),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            l10n.favoriteLocationsHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            onTap: () => _editSlot(id: 'home', defaultLabel: l10n.homeLabel),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    AppImages.favoritesEmpty,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.home_rounded, color: AppColors.ink),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        home?.address ?? l10n.tapToAddAddress,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  home == null ? Icons.add_circle_outline : Icons.edit_outlined,
                  color: AppColors.accentDeep,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            onTap: () => _editSlot(id: 'work', defaultLabel: l10n.workLabel),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.work_rounded, color: AppColors.ink),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.workLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        work?.address ?? l10n.tapToAddAddress,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  work == null ? Icons.add_circle_outline : Icons.edit_outlined,
                  color: AppColors.accentDeep,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addCustom,
            icon: const Icon(Icons.add),
            label: Text(l10n.addMoreFavorites),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...others.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  onTap: () => _editSlot(id: s.id, defaultLabel: s.label),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_rounded, color: AppColors.ink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(s.address),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await passengerGetIt<SavedAddressService>()
                              .remove(s.id);
                          _reload();
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.mist.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.accentDeep),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.favoritesTip)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
