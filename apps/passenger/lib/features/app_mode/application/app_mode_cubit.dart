import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppMode { passenger, driver }

class AppModeCubit extends Cubit<AppMode> {
  AppModeCubit(this._prefs) : super(AppMode.passenger) {
    _load();
  }

  static const _storageKey = 'taxigo_app_mode';

  final SharedPreferences _prefs;

  void _load() {
    final saved = _prefs.getString(_storageKey);
    if (saved == AppMode.driver.name) {
      emit(AppMode.driver);
    }
  }

  Future<void> switchToDriver({required bool isApproved}) async {
    if (!isApproved) return;
    await _prefs.setString(_storageKey, AppMode.driver.name);
    emit(AppMode.driver);
  }

  Future<void> switchToPassenger() async {
    await _prefs.setString(_storageKey, AppMode.passenger.name);
    emit(AppMode.passenger);
  }
}
