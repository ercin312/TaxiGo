import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
        id: json['id']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      );
}

class SavedAddressService {
  SavedAddressService(this._prefs);

  static const _key = 'taxigo_saved_addresses';

  final SharedPreferences _prefs;

  List<SavedAddress> list() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => SavedAddress.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(SavedAddress address) async {
    final items = list();
    final existing = items.indexWhere((a) => a.id == address.id);
    if (existing >= 0) {
      items[existing] = address;
    } else {
      items.insert(0, address);
    }
    await _prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> remove(String id) async {
    final items = list().where((a) => a.id != id).toList();
    await _prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
