import 'package:flutter/material.dart';

/// Supported app locales with display names for the language picker.
class SupportedLocale {
  const SupportedLocale({
    required this.locale,
    required this.displayName,
    required this.nativeName,
    this.flag = '',
    this.isRtl = false,
  });

  final Locale locale;
  final String displayName;
  final String nativeName;
  final String flag;
  final bool isRtl;
}

/// Registry of all supported TaxiGo locales.
abstract final class SupportedLocales {
  static const defaultLocale = Locale('tr');

  static const tr = SupportedLocale(
    locale: Locale('tr'),
    displayName: 'Turkish',
    nativeName: 'Türkçe',
    flag: '🇹🇷',
  );

  static const en = SupportedLocale(
    locale: Locale('en'),
    displayName: 'English',
    nativeName: 'English',
    flag: '🇬🇧',
  );

  static const ru = SupportedLocale(
    locale: Locale('ru'),
    displayName: 'Russian',
    nativeName: 'Русский',
    flag: '🇷🇺',
  );

  static const xh = SupportedLocale(
    locale: Locale('xh'),
    displayName: 'Karabakh Azerbaijani',
    nativeName: 'Qarabağ azərbaycancası',
    flag: '🇦🇿',
  );

  static const ar = SupportedLocale(
    locale: Locale('ar'),
    displayName: 'Arabic',
    nativeName: 'العربية',
    flag: '🇸🇦',
    isRtl: true,
  );

  static const List<SupportedLocale> all = [tr, en, ru, xh, ar];

  /// Alias used by UI components.
  static List<SupportedLocale> get options => all;

  static List<Locale> get locales =>
      all.map((entry) => entry.locale).toList(growable: false);

  static SupportedLocale? findEntryByCode(String languageCode) {
    for (final entry in all) {
      if (entry.locale.languageCode == languageCode) {
        return entry;
      }
    }
    return null;
  }

  static Locale? findByCode(String languageCode) =>
      findEntryByCode(languageCode)?.locale;

  static Locale resolveLocale(String? languageCode) {
    return findByCode(languageCode ?? '') ?? defaultLocale;
  }
}
