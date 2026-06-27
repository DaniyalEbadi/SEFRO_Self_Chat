import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalDataSource {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  LocalDataSource(this._prefs, this._secureStorage);

  // Shared Preferences
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);
  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);
  double? getDouble(String key) => _prefs.getDouble(key);
  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> setStringList(String key, List<String> values) =>
      _prefs.setStringList(key, values);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<void> setJson(String key, dynamic value) =>
      _prefs.setString(key, jsonEncode(value));
  T? getJson<T>(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as T;
    } catch (_) {
      return null;
    }
  }

  // Secure Storage
  Future<void> setSecure(String key, String value) =>
      _secureStorage.write(key: key, value: value);
  Future<String?> getSecure(String key) => _secureStorage.read(key: key);
  Future<void> removeSecure(String key) => _secureStorage.delete(key: key);
  Future<void> clearSecure() => _secureStorage.deleteAll();

  // Generic cache methods
  Future<void> cacheData(String key, dynamic data) async {
    final json = jsonEncode(data);
    await _prefs.setString('cache_$key', json);
    await _prefs.setString('cache_${key}_ts', DateTime.now().toIso8601String());
  }

  T? getCachedData<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson, {
    Duration? maxAge,
  }) {
    final json = _prefs.getString('cache_$key');
    if (json == null) return null;
    if (maxAge != null) {
      final ts = _prefs.getString('cache_${key}_ts');
      if (ts != null) {
        final cachedTime = DateTime.parse(ts);
        if (DateTime.now().difference(cachedTime) > maxAge) return null;
      }
    }
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('cache_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  // Auth token management
  Future<void> saveToken(String token) => setSecure('auth_token', token);
  Future<String?> getToken() => getSecure('auth_token');
  Future<void> clearToken() => removeSecure('auth_token');
}
