import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminApi {
  AdminApi(this._prefs);

  final SharedPreferences _prefs;
  static const _tokenKey = 'admin_token';
  static const _baseKey = 'admin_api_base';
  static const _nameKey = 'admin_name';
  static const _emailKey = 'admin_email';
  static const _superKey = 'admin_is_super';

  String? _token;
  String? adminName;
  String? adminEmail;
  bool isSuperAdmin = false;

  String get baseUrl {
    final raw = _prefs.getString(_baseKey) ?? 'http://127.0.0.1:8000/api/v1';
    return _normalizeBase(raw);
  }

  set baseUrl(String value) {
    _prefs.setString(_baseKey, _normalizeBase(value));
  }

  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<bool> restoreSession() async {
    _token = _prefs.getString(_tokenKey);
    adminName = _prefs.getString(_nameKey);
    adminEmail = _prefs.getString(_emailKey);
    isSuperAdmin = _prefs.getBool(_superKey) ?? false;
    if (!hasToken) return false;
    try {
      final me = await getJson('/admin/me');
      final user = me['user'] as Map<String, dynamic>?;
      adminName = user?['name']?.toString() ?? adminName;
      adminEmail = user?['email']?.toString() ?? adminEmail;
      isSuperAdmin = user?['is_super_admin'] == true;
      await _prefs.setBool(_superKey, isSuperAdmin);
      return true;
    } catch (_) {
      await clearSession();
      return false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required String apiBase,
  }) async {
    baseUrl = apiBase;
    final res = await http
        .post(
          Uri.parse('$baseUrl/admin/login'),
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    final body = _decode(res);
    if (res.statusCode >= 400) {
      throw AdminApiException(_messageFrom(body) ?? 'Giriş başarısız (${res.statusCode})');
    }

    _token = body['token']?.toString();
    final user = body['user'] as Map<String, dynamic>? ?? {};
    adminName = user['name']?.toString();
    adminEmail = user['email']?.toString();
    isSuperAdmin = user['is_super_admin'] == true;

    if (_token == null || _token!.isEmpty) {
      throw AdminApiException('Token alınamadı.');
    }

    await _prefs.setString(_tokenKey, _token!);
    if (adminName != null) await _prefs.setString(_nameKey, adminName!);
    if (adminEmail != null) await _prefs.setString(_emailKey, adminEmail!);
    await _prefs.setBool(_superKey, isSuperAdmin);
  }

  Future<void> logout() async {
    try {
      if (hasToken) {
        await postJson('/admin/logout');
      }
    } catch (_) {}
    await clearSession();
  }

  Future<void> clearSession() async {
    _token = null;
    adminName = null;
    adminEmail = null;
    isSuperAdmin = false;
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_superKey);
  }

  Future<Map<String, dynamic>> dashboard() => getJson('/admin/dashboard');

  Future<Map<String, dynamic>> users({String? search, String? role}) {
    final q = <String, String>{'per_page': '50'};
    if (search != null && search.isNotEmpty) q['search'] = search;
    if (role != null && role.isNotEmpty) q['role'] = role;
    return getJson('/admin/users', query: q);
  }

  Future<Map<String, dynamic>> drivers({String? search, String? status}) {
    final q = <String, String>{'per_page': '50'};
    if (search != null && search.isNotEmpty) q['search'] = search;
    if (status != null && status.isNotEmpty) q['status'] = status;
    return getJson('/admin/drivers', query: q);
  }

  Future<Map<String, dynamic>> driverDetail(int id) =>
      getJson('/admin/drivers/$id');

  Future<void> approveDriver(int id, {bool force = false}) => postJson(
        '/admin/drivers/$id/approve',
        body: force ? {'force': true} : null,
      );

  Future<void> rejectDriver(int id, String reason) => postJson(
        '/admin/drivers/$id/reject',
        body: {'rejection_reason': reason},
      );

  Future<void> banDriver(int id, String reason) => postJson(
        '/admin/drivers/$id/ban',
        body: {'rejection_reason': reason},
      );

  Future<void> verifyDocument(int driverId, int documentId) =>
      postJson('/admin/drivers/$driverId/documents/$documentId/verify');

  Future<void> rejectDocument(int driverId, int documentId, String reason) =>
      postJson(
        '/admin/drivers/$driverId/documents/$documentId/reject',
        body: {'rejection_reason': reason},
      );

  Future<Map<String, dynamic>> rides({String? search, String? tab}) {
    final q = <String, String>{'per_page': '50'};
    if (search != null && search.isNotEmpty) q['search'] = search;
    if (tab != null && tab.isNotEmpty) q['tab'] = tab;
    return getJson('/admin/rides', query: q);
  }

  Future<void> setUserActive(int id, bool active) => patchJson(
        '/admin/users/$id',
        body: {'is_active': active},
      );

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final res = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: _headers(json: true),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await http
        .patch(
          Uri.parse('$baseUrl$path'),
          headers: _headers(json: true),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  Map<String, String> _headers({bool json = false}) {
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (hasToken) 'Authorization': 'Bearer $_token',
    };
  }

  Map<String, dynamic> _handle(http.Response res) {
    final body = _decode(res);
    if (res.statusCode == 401) {
      clearSession();
      throw AdminApiException('Oturum sona erdi. Tekrar giriş yapın.');
    }
    if (res.statusCode >= 400) {
      throw AdminApiException(_messageFrom(body) ?? 'Hata (${res.statusCode})');
    }
    if (body.isEmpty) return {};
    return body;
  }

  Map<String, dynamic> _decode(http.Response res) {
    if (res.body.isEmpty) return {};
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {'data': decoded};
  }

  String? _messageFrom(Map<String, dynamic> body) {
    final msg = body['message']?.toString();
    if (msg != null && msg.isNotEmpty) return msg;
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    return null;
  }

  static String _normalizeBase(String raw) {
    var url = raw.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.contains('/api')) {
      url = '$url/api/v1';
    } else if (url.endsWith('/api')) {
      url = '$url/v1';
    }
    return url;
  }
}

class AdminApiException implements Exception {
  AdminApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
