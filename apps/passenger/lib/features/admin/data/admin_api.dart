import 'package:shared_preferences/shared_preferences.dart';

import 'local_admin_store.dart';

/// Admin data access for the in-app Super Admin console.
class AdminApi {
  AdminApi(this._prefs) : _store = LocalAdminStore(_prefs);

  final SharedPreferences _prefs;
  final LocalAdminStore _store;

  String? adminName;
  String? adminEmail;
  bool isSuperAdmin = true;
  bool get usingLocalData => true;

  Future<void> bootstrap({String? name, String? email}) async {
    await _store.ensureSeeded();
    adminName = name ?? 'Erhan';
    adminEmail = email ?? 'erhan@taxigo.app';
    isSuperAdmin = true;
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
  }

  Future<void> resetDemoData() async {
    await _prefs.remove('taxigo_admin_local_v2');
    await _prefs.remove('taxigo_admin_local_v1');
    _store.users = [];
    _store.drivers = [];
    _store.rides = [];
    _store.modules = {};
    await _store.ensureSeeded();
  }
}
