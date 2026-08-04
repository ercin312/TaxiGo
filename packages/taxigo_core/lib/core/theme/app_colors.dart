import 'package:flutter/material.dart';

/// TaxiGo visual language — night asphalt + taxi amber signal.
abstract final class AppColors {
  // Brand
  static const Color ink = Color(0xFF0B1220);
  static const Color inkSoft = Color(0xFF151E32);
  static const Color primary = Color(0xFF132A4A);
  static const Color primaryLight = Color(0xFF2A4166);
  static const Color primaryDark = Color(0xFF07111F);

  static const Color accent = Color(0xFFF5B400);
  static const Color accentSoft = Color(0xFFFFD36A);
  static const Color accentDeep = Color(0xFFC48A00);

  /// Alias kept for call sites that used secondary as highlight.
  static const Color secondary = accent;
  static const Color secondaryLight = accentSoft;
  static const Color secondaryDark = accentDeep;

  static const Color success = Color(0xFF1F8A5B);
  static const Color warning = Color(0xFFE08900);
  static const Color error = Color(0xFFD14343);
  static const Color info = Color(0xFF3B82A0);

  static const Color backgroundLight = Color(0xFFF3F1EC);
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surfaceLight = Color(0xFFFAF9F7);
  static const Color surfaceDark = Color(0xFF151E32);
  static const Color mist = Color(0xFFE8E4DC);
  static const Color glass = Color(0xE6FAF9F7);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF5B6475);
  static const Color textPrimaryDark = Color(0xFFF7F4EE);
  static const Color textSecondaryDark = Color(0xFFA8B0C0);

  static const Color dividerLight = Color(0xFFD9D3C8);
  static const Color dividerDark = Color(0xFF243044);

  static const Color mapRoute = Color(0xFFF5B400);
  static const Color mapPickup = Color(0xFF1F8A5B);
  static const Color mapDropoff = Color(0xFFD14343);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B1220),
      Color(0xFF152748),
      Color(0xFF1A3358),
      Color(0xFF0E1A2E),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF5B400), Color(0xFFFFC933)],
  );

  static const LinearGradient sheetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAF9F7), Color(0xFFF3F1EC)],
  );
}
