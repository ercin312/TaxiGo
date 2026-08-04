import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../l10n/supported_locales.dart';

// Events
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

class LoadLanguage extends LanguageEvent {
  const LoadLanguage();
}

class ChangeLanguage extends LanguageEvent {
  const ChangeLanguage(this.locale);

  final Locale locale;

  @override
  List<Object?> get props => [locale];
}

// States
class LanguageState extends Equatable {
  const LanguageState({required this.locale});

  final Locale locale;

  @override
  List<Object?> get props => [locale];
}

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const LanguageState(locale: SupportedLocales.defaultLocale)) {
    on<LoadLanguage>(_onLoad);
    on<ChangeLanguage>(_onChange);
  }

  final SharedPreferences _prefs;

  Future<void> _onLoad(LoadLanguage event, Emitter<LanguageState> emit) async {
    final code = _prefs.getString(AppConstants.localeKey);
    if (code != null) {
      final locale = SupportedLocales.findByCode(code);
      if (locale != null) {
        emit(LanguageState(locale: locale));
      }
    }
  }

  Future<void> _onChange(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    await _prefs.setString(AppConstants.localeKey, event.locale.languageCode);
    emit(LanguageState(locale: event.locale));
  }
}
