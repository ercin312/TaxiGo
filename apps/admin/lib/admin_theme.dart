import 'package:flutter/material.dart';

abstract final class AdminTheme {
  static const ink = Color(0xFF14161D);
  static const accent = Color(0xFFE8B923);
  static const surface = Color(0xFFF3F0E8);
  static const panel = Color(0xFFFFFFFF);
  static const muted = Color(0xFF6B7280);
  static const rail = Color(0xFF1C1F2A);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        primary: ink,
        secondary: accent,
        surface: surface,
      ),
      scaffoldBackgroundColor: surface,
      fontFamily: 'Segoe UI',
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: ink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: ink.withValues(alpha: 0.08)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(ink.withValues(alpha: 0.04)),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
    );
  }
}
