import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Decodes Google / OSRM encoded polylines into [LatLng] points.
abstract final class PolylineDecoder {
  static List<LatLng> decode(String encoded, {int precision = 5}) {
    final coordinates = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;
    final factor = _pow10(precision);

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      coordinates.add(LatLng(lat / factor, lng / factor));
    }

    return coordinates;
  }

  static double _pow10(int precision) {
    var v = 1.0;
    for (var i = 0; i < precision; i++) {
      v *= 10;
    }
    return v;
  }
}
