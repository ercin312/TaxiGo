import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/app_images.dart';

/// Cached map marker bitmaps from bundled TaxiGo graphics.
///
/// Sized to stay compact on screen (similar to default Google pins).
abstract final class MapMarkerIcons {
  static BitmapDescriptor? _taxi;
  static BitmapDescriptor? _pickup;
  static BitmapDescriptor? _dropoff;
  static Future<void>? _loading;

  /// Compact top-down taxi (~default marker footprint).
  static const int taxiWidthPx = 42;

  /// Compact pickup / dropoff pins.
  static const int pinWidthPx = 36;

  static BitmapDescriptor get taxiOrDefault =>
      _taxi ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);

  static BitmapDescriptor get pickupOrDefault =>
      _pickup ??
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

  static BitmapDescriptor get dropoffOrDefault =>
      _dropoff ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

  static Future<void> ensureLoaded() {
    return _loading ??= _loadAll();
  }

  static Future<void> _loadAll() async {
    _taxi = await _fromAsset('assets/images/car.png', width: taxiWidthPx);
    _pickup = await _fromAsset('assets/images/pick_pin.png', width: pinWidthPx);
    _dropoff =
        await _fromAsset('assets/images/drop_pin.png', width: pinWidthPx);
    _taxi ??= await _fromAsset('assets/images/Taxi1.png', width: taxiWidthPx);
    _pickup ??=
        await _fromAsset('assets/images/pickLocation.png', width: pinWidthPx);
    _dropoff ??=
        await _fromAsset('assets/images/dropLocation.png', width: pinWidthPx);
  }

  static Future<BitmapDescriptor?> _fromAsset(
    String assetPath, {
    required int width,
  }) async {
    try {
      final data = await rootBundle.load('packages/taxigo_core/$assetPath');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: width,
      );
      final frame = await codec.getNextFrame();
      final bytes =
          await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;
      return BitmapDescriptor.bytes(
        bytes.buffer.asUint8List(),
        imagePixelRatio: 2.5,
      );
    } catch (_) {
      try {
        return BitmapDescriptor.asset(
          ImageConfiguration(
            devicePixelRatio: 2.5,
            size: Size(width / 2.5, width / 2.5),
          ),
          assetPath,
          package: 'taxigo_core',
        );
      } catch (_) {
        return null;
      }
    }
  }

  static const String taxiAsset = AppImages.car;
}
