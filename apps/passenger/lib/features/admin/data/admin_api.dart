import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../di/locator.dart';
import 'local_admin_store.dart';

/// Admin data access for the in-app Super Admin console.
class AdminApi {
  AdminApi(this._prefs) : _store = LocalAdminStore(_prefs);

  final SharedPreferences _prefs;
  final LocalAdminStore _store;

  static const _opsKeyPref = 'taxigo_ops_api_key';
  static const defaultOpsKey = 'taxigo-ops-sos';

  String? adminName;
  String? adminEmail;
  bool isSuperAdmin = true;
  bool get usingLocalData => true;

  String get opsApiKey =>
      _prefs.getString(_opsKeyPref)?.trim().isNotEmpty == true
          ? _prefs.getString(_opsKeyPref)!.trim()
          : defaultOpsKey;

  Future<void> setOpsApiKey(String key) async {
    await _prefs.setString(_opsKeyPref, key.trim());
  }

  Future<void> bootstrap({String? name, String? email}) async {
    await _store.ensureSeeded();
    adminName = name ?? 'Erhan';
    adminEmail = email ?? 'erhan@taxigo.app';
    isSuperAdmin = true;
    try {
      final modules = passengerGetIt<FeatureModulesService>();
      for (final e in _store.modules.entries) {
        await modules.setOverride(e.key, e.value);
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>> dashboard() async {
    await _store.ensureSeeded();
    return _store.dashboard();
  }

  Future<Map<String, dynamic>> users({String? search, String? role}) async {
    await _store.ensureSeeded();
    return _store.listUsers(search: search, role: role);
  }

  Future<Map<String, dynamic>> drivers({String? search, String? status}) async {
    await _store.ensureSeeded();
    return _store.listDrivers(search: search, status: status);
  }

  Future<Map<String, dynamic>> driverDetail(int id) async {
    await _store.ensureSeeded();
    return _store.driverDetail(id);
  }

  Future<void> approveDriver(int id, {bool force = false}) async {
    await _store.approveDriver(id);
  }

  Future<void> rejectDriver(int id, String reason) async {
    await _store.rejectDriver(id, reason);
  }

  Future<void> banDriver(int id, String reason) async {
    await _store.banDriver(id, reason);
  }

  Future<void> verifyDocument(int driverId, int documentId) async {
    await _store.verifyDocument(driverId, documentId);
  }

  Future<void> rejectDocument(
    int driverId,
    int documentId,
    String reason,
  ) async {
    await _store.rejectDocument(driverId, documentId, reason);
  }

  Future<Map<String, dynamic>> rides({String? search, String? tab}) async {
    await _store.ensureSeeded();
    return _store.listRides(search: search, tab: tab);
  }

  Future<void> completeRide(int id) async {
    await _store.completeRide(id);
  }

  Future<void> cancelRide(int id) async {
    await _store.cancelRide(id);
  }

  Future<void> setUserActive(int id, bool active) async {
    await _store.setUserActive(id, active);
  }

  Future<Map<String, bool>> modules() async {
    await _store.ensureSeeded();
    return Map<String, bool>.from(_store.modules);
  }

  Future<void> setModule(String key, bool enabled) async {
    await _store.setModule(key, enabled);
    try {
      await passengerGetIt<FeatureModulesService>().setOverride(key, enabled);
    } catch (_) {
      // Locator may be unavailable in pure unit tests.
    }
    // HomeBloc listens to FeatureModulesService for demo_login refresh.
  }

  Future<void> resetDemoData() async {
    await _prefs.remove('taxigo_admin_local_v3');
    await _prefs.remove('taxigo_admin_local_v2');
    await _prefs.remove('taxigo_admin_local_v1');
    try {
      await passengerGetIt<FeatureModulesService>().clearOverrides();
    } catch (_) {}
    _store.users = [];
    _store.drivers = [];
    _store.rides = [];
    _store.modules = {};
    await _store.ensureSeeded();
  }

  Future<Map<String, dynamic>> fetchSosNotifySettings() async {
    try {
      final res = await passengerGetIt<ApiClient>().dio.get<Map<String, dynamic>>(
        '/ops/sos-notify',
        options: Options(headers: {'X-TaxiGo-Ops-Key': opsApiKey}),
      );
      final settings = res.data?['settings'];
      return settings is Map
          ? Map<String, dynamic>.from(settings)
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> saveSosNotifySettings(
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await passengerGetIt<ApiClient>().dio.put<Map<String, dynamic>>(
        '/ops/sos-notify',
        data: payload,
        options: Options(headers: {'X-TaxiGo-Ops-Key': opsApiKey}),
      );
      final settings = res.data?['settings'];
      return settings is Map
          ? Map<String, dynamic>.from(settings)
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchSosAlerts() async {
    try {
      final res = await passengerGetIt<ApiClient>().dio.get<Map<String, dynamic>>(
        '/ops/sos-alerts',
        options: Options(headers: {'X-TaxiGo-Ops-Key': opsApiKey}),
      );
      final data = res.data?['data'];
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
