import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Material 3 themes — TaxiGo night signal aesthetic.
abstract final class AppThemes {
  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.ink,
      onPrimary: AppColors.accent,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.accentSoft,
      secondary: AppColors.accent,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.accentSoft,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.info,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      onSurface: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      surfaceContainerHighest:
          isLight ? AppColors.mist : AppColors.inkSoft,
      outline: isLight ? AppColors.dividerLight : AppColors.dividerDark,
    );

    final display = GoogleFonts.soraTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
    final body = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );

    final textTheme = body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: colorScheme.onSurface,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: colorScheme.onSurface,
      ),
      displaySmall: display.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: colorScheme.onSurface,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: colorScheme.onSurface,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: colorScheme.onSurface,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleLarge: display.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleSmall: body.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        height: 1.45,
        color: colorScheme.onSurface,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        height: 1.45,
        color: isLight
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryDark,
      ),
      bodySmall: body.bodySmall?.copyWith(
        color: isLight
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryDark,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.35),
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: AppColors.ink, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : AppColors.inkSoft,
        hintStyle: textTheme.bodyMedium,
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: isLight
              ? AppColors.textSecondaryLight
              : AppColors.textSecondaryDark,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outline, space: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: AppColors.accentDeep,
        unselectedItemColor: isLight
            ? AppColors.textSecondaryLight
            : AppColors.textSecondaryDark,
        backgroundColor: isLight ? AppColors.surfaceLight : AppColors.ink,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.accent,
        elevation: 2,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? AppColors.mist : AppColors.inkSoft,
        selectedColor: AppColors.accent.withValues(alpha: 0.25),
        labelStyle: textTheme.labelLarge!,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
    );
  }
}
