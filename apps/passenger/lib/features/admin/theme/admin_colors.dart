import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TaxiGo Super Admin visual system — graphite + taxi gold.
abstract final class AdminColors {
  static const ink = Color(0xFF0F1218);
  static const inkSoft = Color(0xFF1A2030);
  static const accent = Color(0xFFF5C518);
  static const accentDeep = Color(0xFFD4A017);
  static const surface = Color(0xFFEEF1F6);
  static const panel = Color(0xFFFFFFFF);
  static const muted = Color(0xFF64748B);
  static const rail = Color(0xFF11151F);
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  static const warning = Color(0xFFF59E0B);
  static const violet = Color(0xFF7C3AED);

  static LinearGradient get heroGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F1218), Color(0xFF1C2438), Color(0xFF12161F)],
      );

  static LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF5C518), Color(0xFFE0A800)],
      );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: ink.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static ThemeData theme(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        primary: ink,
        secondary: accent,
        surface: surface,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: panel,
        indicatorColor: accent.withValues(alpha: 0.28),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? ink : muted,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
