import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/polyline_decoder.dart';
import '../data/network/api_client.dart';
import '../data/network/api_endpoints.dart';
import '../data/network/api_exception.dart';

class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.description,
    this.mainText,
    this.secondaryText,
  });

  final String placeId;
  final String description;
  final String? mainText;
  final String? secondaryText;
}

class PlaceDetails {
  const PlaceDetails({
    required this.placeId,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.name,
  });

  final String placeId;
  final double latitude;
  final double longitude;
  final String address;
  final String? name;
}

class DirectionsResult {
  const DirectionsResult({
    required this.points,
    this.distanceMeters,
    this.durationSeconds,
    this.fallback = false,
  });

  final List<LatLng> points;
  final int? distanceMeters;
  final int? durationSeconds;
  final bool fallback;
}

class MapsService {
  MapsService(this._apiClient);

  final ApiClient _apiClient;

  static final Dio _routingDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  /// Popular places for offline / demo autocomplete (TR).
  static const _localPlaces = <({
    String name,
    String city,
    double lat,
    double lng,
  })>[
    (name: 'Taksim Meydanı', city: 'Beyoğlu, İstanbul', lat: 41.0370, lng: 28.9850),
    (name: 'Kadıköy Rıhtım', city: 'Kadıköy, İstanbul', lat: 40.9905, lng: 29.0250),
    (name: 'Beşiktaş İskele', city: 'Beşiktaş, İstanbul', lat: 41.0422, lng: 29.0067),
    (name: 'Levent Metro', city: 'Şişli, İstanbul', lat: 41.0814, lng: 29.0120),
    (name: 'Mecidiyeköy', city: 'Şişli, İstanbul', lat: 41.0670, lng: 28.9930),
    (name: 'İstanbul Havalimanı', city: 'Arnavutköy, İstanbul', lat: 41.2753, lng: 28.7519),
    (name: 'Sabiha Gökçen Havalimanı', city: 'Pendik, İstanbul', lat: 40.8986, lng: 29.3092),
    (name: 'Kapalıçarşı', city: 'Fatih, İstanbul', lat: 41.0106, lng: 28.9681),
    (name: 'Sultanahmet', city: 'Fatih, İstanbul', lat: 41.0054, lng: 28.9768),
    (name: 'Üsküdar Meydanı', city: 'Üsküdar, İstanbul', lat: 41.0255, lng: 29.0150),
    (name: 'Bakırköy Özgürlük Meydanı', city: 'Bakırköy, İstanbul', lat: 40.9798, lng: 28.8724),
    (name: 'Ataşehir Brandium', city: 'Ataşehir, İstanbul', lat: 40.9847, lng: 29.1280),
    (name: 'Maslak', city: 'Sarıyer, İstanbul', lat: 41.1085, lng: 29.0204),
    (name: 'Nişantaşı', city: 'Şişli, İstanbul', lat: 41.0503, lng: 28.9930),
    (name: 'Ortaköy', city: 'Beşiktaş, İstanbul', lat: 41.0553, lng: 29.0269),
    (name: 'Kızılay Meydanı', city: 'Çankaya, Ankara', lat: 39.9208, lng: 32.8541),
    (name: 'Ankara Tren Garı', city: 'Altındağ, Ankara', lat: 39.9360, lng: 32.8439),
    (name: 'Konak Meydanı', city: 'Konak, İzmir', lat: 38.4192, lng: 27.1287),
    (name: 'Alsancak', city: 'Konak, İzmir', lat: 38.4370, lng: 27.1420),
  ];

  Future<Either<String, DirectionsResult>> getDirections({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    // 1) Backend (if online)
    final fromApi = await _directionsFromBackend(
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
    if (fromApi != null && fromApi.points.length > 2 && !fromApi.fallback) {
      return Right(fromApi);
    }

    // 2) Google Directions (same key as Maps SDK)
    final fromGoogle = await _directionsFromGoogle(
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
    if (fromGoogle != null && fromGoogle.points.length > 2) {
      return Right(fromGoogle);
    }

    // 3) OSRM public router — real road geometry, no API key
    final fromOsrm = await _directionsFromOsrm(
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
    if (fromOsrm != null && fromOsrm.points.length > 2) {
      return Right(fromOsrm);
    }

    // Last resort — never preferred
    return Right(
      DirectionsResult(
        points: [
          LatLng(originLat, originLng),
          LatLng(destinationLat, destinationLng),
        ],
        fallback: true,
      ),
    );
  }

  Future<DirectionsResult?> _directionsFromBackend({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.mapsDirections,
        data: {
          'origin_lat': originLat,
          'origin_lng': originLng,
          'destination_lat': destinationLat,
          'destination_lng': destinationLng,
        },
      );
      final data = response.data ?? {};
      final points = <LatLng>[];
      final rawPoints = data['points'];
      if (rawPoints is List) {
        for (final p in rawPoints) {
          if (p is Map) {
            final lat = (p['lat'] as num?)?.toDouble();
            final lng = (p['lng'] as num?)?.toDouble();
            if (lat != null && lng != null) points.add(LatLng(lat, lng));
          }
        }
      }
      if (points.isEmpty) return null;
      return DirectionsResult(
        points: points,
        distanceMeters: (data['distance_meters'] as num?)?.toInt(),
        durationSeconds: (data['duration_seconds'] as num?)?.toInt(),
        fallback: data['fallback'] == true,
      );
    } on ApiException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<DirectionsResult?> _directionsFromGoogle({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final key = AppConstants.googleMapsApiKey.trim();
    if (key.isEmpty || key.contains('YOUR_')) return null;

    try {
      final response = await _routingDio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '$originLat,$originLng',
          'destination': '$destinationLat,$destinationLng',
          'mode': 'driving',
          'language': 'tr',
          'key': key,
        },
      );
      final data = response.data;
      if (data == null || data['status']?.toString() != 'OK') return null;
      final routes = data['routes'];
      if (routes is! List || routes.isEmpty) return null;
      final route = routes.first;
      if (route is! Map) return null;
      final overview = route['overview_polyline'];
      final encoded = overview is Map ? overview['points']?.toString() : null;
      if (encoded == null || encoded.isEmpty) return null;

      final points = PolylineDecoder.decode(encoded);
      if (points.length < 2) return null;

      final legs = route['legs'];
      int? distance;
      int? duration;
      if (legs is List && legs.isNotEmpty && legs.first is Map) {
        final leg = Map<String, dynamic>.from(legs.first as Map);
        distance = (leg['distance'] is Map)
            ? (leg['distance']['value'] as num?)?.toInt()
            : null;
        duration = (leg['duration'] is Map)
            ? (leg['duration']['value'] as num?)?.toInt()
            : null;
      }

      return DirectionsResult(
        points: points,
        distanceMeters: distance,
        durationSeconds: duration,
      );
    } catch (_) {
      return null;
    }
  }

  Future<DirectionsResult?> _directionsFromOsrm({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    try {
      final path =
          '$originLng,$originLat;$destinationLng,$destinationLat';
      final response = await _routingDio.get<Map<String, dynamic>>(
        'https://router.project-osrm.org/route/v1/driving/$path',
        queryParameters: {
          'overview': 'full',
          'geometries': 'polyline',
          'steps': 'false',
        },
      );
      final data = response.data;
      if (data == null || data['code']?.toString() != 'Ok') return null;
      final routes = data['routes'];
      if (routes is! List || routes.isEmpty) return null;
      final route = routes.first;
      if (route is! Map) return null;
      final encoded = route['geometry']?.toString();
      if (encoded == null || encoded.isEmpty) return null;

      final points = PolylineDecoder.decode(encoded);
      if (points.length < 2) return null;

      return DirectionsResult(
        points: points,
        distanceMeters: (route['distance'] as num?)?.round(),
        durationSeconds: (route['duration'] as num?)?.round(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<Either<String, List<PlacePrediction>>> autocomplete({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    final q = query.trim();
    if (q.length < 2) return const Right([]);

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.mapsPlaces,
        queryParameters: {
          'query': q,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );
      final list = response.data?['predictions'];
      if (list is List && list.isNotEmpty) {
        final parsed = list.whereType<Map>().map((p) {
          final map = Map<String, dynamic>.from(p);
          return PlacePrediction(
            placeId: map['place_id']?.toString() ?? '',
            description: map['description']?.toString() ?? '',
            mainText: map['main_text']?.toString(),
            secondaryText: map['secondary_text']?.toString(),
          );
        }).where((p) => p.placeId.isNotEmpty).toList();
        if (parsed.isNotEmpty) return Right(parsed);
      }
    } catch (_) {
      // Fall through to offline suggestions.
    }

    return Right(await _localAutocomplete(q));
  }

  Future<List<PlacePrediction>> _localAutocomplete(String query) async {
    final lower = query.toLowerCase();
    final matched = _localPlaces
        .where(
          (p) =>
              p.name.toLowerCase().contains(lower) ||
              p.city.toLowerCase().contains(lower),
        )
        .take(8)
        .map(
          (p) => PlacePrediction(
            placeId: 'local:${p.lat},${p.lng}',
            description: '${p.name}, ${p.city}',
            mainText: p.name,
            secondaryText: p.city,
          ),
        )
        .toList();

    if (matched.isNotEmpty) return matched;

    try {
      final locations = await locationFromAddress('$query, Türkiye');
      return locations.take(5).map((loc) {
        return PlacePrediction(
          placeId: 'local:${loc.latitude},${loc.longitude}',
          description: query,
          mainText: query,
          secondaryText:
              '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
        );
      }).toList();
    } catch (_) {
      return matched;
    }
  }

  Future<Either<String, PlaceDetails>> placeDetails(String placeId) async {
    if (placeId.startsWith('local:')) {
      final coords = placeId.substring(6).split(',');
      if (coords.length >= 2) {
        final lat = double.tryParse(coords[0]);
        final lng = double.tryParse(coords[1]);
        if (lat != null && lng != null) {
          final known = _localPlaces.where(
            (p) =>
                (p.lat - lat).abs() < 0.0002 && (p.lng - lng).abs() < 0.0002,
          );
          final name = known.isNotEmpty ? known.first.name : null;
          final city = known.isNotEmpty ? known.first.city : null;
          return Right(
            PlaceDetails(
              placeId: placeId,
              latitude: lat,
              longitude: lng,
              address: name != null ? '$name, $city' : '$lat, $lng',
              name: name,
            ),
          );
        }
      }
      return const Left('Geçersiz konum');
    }

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.mapsPlaceDetails,
        queryParameters: {'place_id': placeId},
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) {
        return const Left('Invalid place coordinates');
      }
      return Right(
        PlaceDetails(
          placeId: placeId,
          latitude: lat,
          longitude: lng,
          address: data['address']?.toString() ?? '',
          name: data['name']?.toString(),
        ),
      );
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
