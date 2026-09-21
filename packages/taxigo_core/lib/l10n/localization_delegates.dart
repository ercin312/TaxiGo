import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';

/// Material / Cupertino do not ship every custom app locale (e.g. `cnr`).
/// These delegates keep [AppLocalizations] on the selected language while
/// falling back to a close Material-supported locale for framework widgets.
abstract final class TaxiGoLocalization {
  static const List<LocalizationsDelegate<dynamic>> delegates =
      <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    _FallbackMaterialLocalizationsDelegate(),
    _FallbackCupertinoLocalizationsDelegate(),
    GlobalWidgetsLocalizations.delegate,
  ];

  static Locale materialFallback(Locale locale) {
    switch (locale.languageCode) {
      case 'cnr':
        return const Locale('sr');
      default:
        return locale;
    }
  }
}

class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final fallback = TaxiGoLocalization.materialFallback(locale);
    if (GlobalMaterialLocalizations.delegate.isSupported(fallback)) {
      return GlobalMaterialLocalizations.delegate.load(fallback);
    }
    return GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}

class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final fallback = TaxiGoLocalization.materialFallback(locale);
    if (GlobalCupertinoLocalizations.delegate.isSupported(fallback)) {
      return GlobalCupertinoLocalizations.delegate.load(fallback);
    }
    return GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) => false;
}
