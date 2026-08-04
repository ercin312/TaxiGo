import 'package:shared_preferences/shared_preferences.dart';

import 'app_constants.dart';

/// Resolves the API base URL from saved prefs or compile-time define.
abstract final class ApiConfig {
  static const String prefsKey = 'taxigo_api_base_url';

  static String get compileTimeBaseUrl => AppConstants.baseUrl;

  static Future<String> resolveBaseUrl(SharedPreferences prefs) async {
    final saved = prefs.getString(prefsKey)?.trim();
    if (saved != null && saved.isNotEmpty) {
      final lower = saved.toLowerCase();
      // Never keep localhost or LAN/dev URLs on the phone — login is local.
      if (_isDevOrLanUrl(lower)) {
        await prefs.remove(prefsKey);
        return compileTimeBaseUrl;
      }
      return saved;
    }
    return compileTimeBaseUrl;
  }

  static bool _isDevOrLanUrl(String lower) {
    if (lower.contains('localhost') || lower.contains('127.0.0.1')) {
      return true;
    }
    // Private network ranges commonly used with `php artisan serve`
    final host = RegExp(r'https?://([^/:]+)').firstMatch(lower)?.group(1);
    if (host == null) return false;
    return host.startsWith('192.168.') ||
        host.startsWith('10.') ||
        RegExp(r'^172\.(1[6-9]|2\d|3[0-1])\.').hasMatch(host);
  }

  static Future<void> saveBaseUrl(
    SharedPreferences prefs,
    String url,
  ) async {
    await prefs.setString(prefsKey, normalizeUrl(url));
  }

  /// Ensures URL ends with `/api/v1`.
  static String normalizeUrl(String url) {
    var normalized = url.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    if (!normalized.endsWith('/api/v1')) {
      if (normalized.endsWith('/api')) {
        normalized = '$normalized/v1';
      } else {
        normalized = '$normalized/api/v1';
      }
    }
    return normalized;
  }

  /// `http://host:8000/api/v1` -> `http://host:8000`
  static String serverRootFromApiUrl(String apiUrl) {
    return apiUrl.replaceAll(RegExp(r'/api/v1/?$'), '');
  }
}
