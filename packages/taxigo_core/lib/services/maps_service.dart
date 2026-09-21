import 'dart:ui' show PlatformDispatcher;

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

  /// Google Places / Directions language code for the app locale.
  static String googleLanguageFor(String? languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'tr';
      case 'ru':
        return 'ru';
      case 'ar':
        return 'ar';
      case 'cnr':
      case 'sr':
        return 'sr';
      default:
        return 'en';
    }
  }

  /// Popular places for offline / demo autocomplete (Montenegro).
  static const _localPlaces = <({
    String name,
    String city,
    double lat,
    double lng,
  })>[
    (name: 'Trg Republike', city: 'Podgorica', lat: 42.4410, lng: 19.2628),
    (name: 'Delta City', city: 'Podgorica', lat: 42.4428, lng: 19.2415),
    (name: 'Podgorica Airport (TGD)', city: 'Golubovci', lat: 42.3594, lng: 19.2519),
    (name: 'Budva Old Town', city: 'Budva', lat: 42.2864, lng: 18.8400),
    (name: 'Budva Marina', city: 'Budva', lat: 42.2850, lng: 18.8415),
    (name: 'Sveti Stefan', city: 'Budva', lat: 42.2566, lng: 18.8905),
    (name: 'Kotor Old Town', city: 'Kotor', lat: 42.4247, lng: 18.7712),
    (name: 'Porto Montenegro', city: 'Tivat', lat: 42.4340, lng: 18.7064),
    (name: 'Tivat Airport (TIV)', city: 'Tivat', lat: 42.4047, lng: 18.7233),
    (name: 'Herceg Novi', city: 'Herceg Novi', lat: 42.4511, lng: 18.5375),
    (name: 'Bar Port', city: 'Bar', lat: 42.0947, lng: 19.1003),
    (name: 'Ulcinj Old Town', city: 'Ulcinj', lat: 41.9297, lng: 19.2064),
    (name: 'Cetinje', city: 'Cetinje', lat: 42.3906, lng: 18.9142),
    (name: 'Nikšić Center', city: 'Nikšić', lat: 42.7731, lng: 18.9444),
    (name: 'Petrovac', city: 'Budva', lat: 42.2056, lng: 18.9456),
    (name: 'Žabljak', city: 'Žabljak', lat: 43.1544, lng: 19.1231),
    (name: 'Bijelo Polje', city: 'Bijelo Polje', lat: 43.0381, lng: 19.7475),
    (name: 'Becici Beach', city: 'Budva', lat: 42.2810, lng: 18.8680),
  ];

  Future<Either<String, DirectionsResult>> getDirections({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    String? languageCode,
  }) async {
    final language = googleLanguageFor(languageCode);
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
      language: language,
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
    String language = 'en',
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
          'language': language,
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
    String? languageCode,
  }) async {
    final q = query.trim();
    if (q.length < 2) return const Right([]);

    final lat = latitude ?? AppConstants.defaultLatitude;
    final lng = longitude ?? AppConstants.defaultLongitude;
    final language = googleLanguageFor(languageCode);

    // 1) Backend Places (if online)
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.mapsPlaces,
        queryParameters: {
          'query': q,
          'latitude': lat,
          'longitude': lng,
          'country': AppConstants.serviceCountryCode,
          'language': language,
        },
      );
      final list = response.data?['predictions'];
      if (list is List && list.isNotEmpty) {
        final parsed = _parsePredictions(list);
        if (parsed.isNotEmpty) return Right(parsed);
      }
    } catch (_) {
      // Fall through.
    }

    // 2) Google Places Autocomplete — restricted to Montenegro
    final fromGoogle = await _autocompleteFromGoogle(
      query: q,
      latitude: lat,
      longitude: lng,
      language: language,
    );
    if (fromGoogle.isNotEmpty) return Right(fromGoogle);

    // 3) Offline Montenegro landmarks + geocoder
    return Right(await _localAutocomplete(q));
  }

  List<PlacePrediction> _parsePredictions(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((p) {
          final map = Map<String, dynamic>.from(p);
          return PlacePrediction(
            placeId: map['place_id']?.toString() ?? '',
            description: map['description']?.toString() ?? '',
            mainText: map['main_text']?.toString(),
            secondaryText: map['secondary_text']?.toString(),
          );
        })
        .where((p) => p.placeId.isNotEmpty)
        .toList();
  }

  Future<List<PlacePrediction>> _autocompleteFromGoogle({
    required String query,
    required double latitude,
    required double longitude,
    String language = 'en',
  }) async {
    final key = AppConstants.googleMapsApiKey.trim();
    if (key.isEmpty || key.contains('YOUR_')) return const [];

    try {
      final response = await _routingDio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': key,
          'language': language,
          'components': 'country:${AppConstants.serviceCountryCode}',
          'location': '$latitude,$longitude',
          'radius': AppConstants.placesSearchRadiusMeters,
          'strictbounds': 'false',
        },
      );
      final data = response.data;
      if (data == null || data['status']?.toString() != 'OK') {
        return const [];
      }
      final predictions = data['predictions'];
      if (predictions is! List || predictions.isEmpty) return const [];
      return _parsePredictions(predictions.map((p) {
        if (p is! Map) return <String, dynamic>{};
        final structured = p['structured_formatting'];
        return {
          'place_id': p['place_id'],
          'description': p['description'],
          'main_text': structured is Map
              ? structured['main_text']
              : p['description'],
          'secondary_text':
              structured is Map ? structured['secondary_text'] : '',
        };
      }).toList());
    } catch (_) {
      return const [];
    }
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
            description: '${p.name}, ${p.city}, Montenegro',
            mainText: p.name,
            secondaryText: '${p.city}, Montenegro',
          ),
        )
        .toList();

    if (matched.isNotEmpty) return matched;

    try {
      final locations = await locationFromAddress(
        '$query, ${AppConstants.serviceCountryName}',
      );
      return locations.take(5).map((loc) {
        return PlacePrediction(
          placeId: 'local:${loc.latitude},${loc.longitude}',
          description: '$query, Montenegro',
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
              address: name != null
                  ? '$name, $city, Montenegro'
                  : '$lat, $lng',
              name: name,
            ),
          );
        }
      }
      return const Left('Geçersiz konum');
    }

    // Prefer Google Place Details directly (works when backend stub has no places).
    final fromGoogle = await _placeDetailsFromGoogle(placeId);
    if (fromGoogle != null) return Right(fromGoogle);

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

  Future<PlaceDetails?> _placeDetailsFromGoogle(String placeId) async {
    final key = AppConstants.googleMapsApiKey.trim();
    if (key.isEmpty || key.contains('YOUR_')) return null;
    try {
      final response = await _routingDio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry,formatted_address,name',
          'language': googleLanguageFor(
            PlatformDispatcher.instance.locale.languageCode,
          ),
          'key': key,
        },
      );
      final data = response.data;
      if (data == null || data['status']?.toString() != 'OK') return null;
      final result = data['result'];
      if (result is! Map) return null;
      final location = result['geometry'] is Map
          ? result['geometry']['location']
          : null;
      if (location is! Map) return null;
      final lat = (location['lat'] as num?)?.toDouble();
      final lng = (location['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return PlaceDetails(
        placeId: placeId,
        latitude: lat,
        longitude: lng,
        address: result['formatted_address']?.toString() ?? '',
        name: result['name']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }
}
