import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecentPlace {
  const RecentPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory RecentPlace.fromJson(Map<String, dynamic> json) => RecentPlace(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      );
}

class RecentPlacesService {
  RecentPlacesService(this._prefs);

  static const _key = 'taxigo_recent_places';
  final SharedPreferences _prefs;

  List<RecentPlace> list({int limit = 8}) {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => RecentPlace.fromJson(Map<String, dynamic>.from(e)))
          .take(limit)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(RecentPlace place) async {
    final items = list(limit: 20)
        .where((e) => e.id != place.id && e.address != place.address)
        .toList();
    items.insert(0, place);
    await _prefs.setString(
      _key,
      jsonEncode(items.take(12).map((e) => e.toJson()).toList()),
    );
  }
}
