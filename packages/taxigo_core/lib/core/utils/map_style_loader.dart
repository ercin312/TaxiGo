import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../theme/app_images.dart';

/// Loads Google Maps JSON style from bundled assets.
abstract final class MapStyleLoader {
  static Future<String?> loadForBrightness(Brightness brightness) async {
    final path = brightness == Brightness.dark
        ? AppImages.mapDarkStyle
        : AppImages.mapLightStyle;
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      return null;
    }
  }
}
