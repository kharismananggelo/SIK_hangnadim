import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized secure storage helper.
/// This stores the auth token using FlutterSecureStorage so the token is
/// kept in platform secure storage (Keychain on iOS, Keystore on Android).
class Storage {
  static const _keyToken = 'auth_token';
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  // Save token securely
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
    // Also remove any old SharedPreferences copy (migration cleanup)
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('token')) await prefs.remove('token');
    } catch (_) {
      // ignore migration errors
    }
  }

  // Read token
  static Future<String?> getToken() async {
    final token = await _secureStorage.read(key: _keyToken);
    if (token != null) return token;

    // Migration: if old SharedPreferences token exists, move it to secure storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final old = prefs.getString('token');
      if (old != null) {
        await _secureStorage.write(key: _keyToken, value: old);
        await prefs.remove('token');
        return old;
      }
    } catch (_) {
      // ignore migration errors
    }
    return null;
  }

  // Delete token
  static Future<void> clearToken() async {
    await _secureStorage.delete(key: _keyToken);
    // Also clear legacy SharedPreferences token if present
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('token')) await prefs.remove('token');
    } catch (_) {
      // ignore
    }
  }
}
