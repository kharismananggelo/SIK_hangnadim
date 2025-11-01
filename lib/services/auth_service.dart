import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sik_hangnadim_mobile/model/user_model.dart';
import 'package:sik_hangnadim_mobile/utils/constants.dart';
import 'package:sik_hangnadim_mobile/utils/storage.dart';

class AuthService {
  get Storage => null;

  // Register user baru
  Future<User> register(
    String name,
    String email,
    String password,
    String confirm,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirm,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await Storage.saveToken(data['access_token']);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Register gagal: ${response.body}');
    }
  }

  // Login
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = response.body;
    final contentType = response.headers['content-type'] ?? '';

    bool _isHtml(String s) => s.trimLeft().startsWith('<') || s.toLowerCase().contains('<!doctype') || s.toLowerCase().contains('<html');

    if (response.statusCode == 200) {
      // If content-type isn't JSON and body looks like HTML, treat as invalid response
      if (!contentType.contains('application/json') && _isHtml(body)) {
        throw Exception('INVALID_RESPONSE: Server returned HTML when JSON expected (status 200)');
      }

      try {
        final data = jsonDecode(body);
        await Storage.saveToken(data['access_token']);
        return User.fromJson(data['user']);
      } on FormatException catch (_) {
        throw Exception('INVALID_RESPONSE: Server returned invalid JSON for login');
      }
    } else {
      // Non-200: detect HTML error pages first
      if (_isHtml(body)) {
        if (response.statusCode == 404) {
          throw Exception('ENDPOINT_NOT_FOUND: Login endpoint not found (status 404)');
        }
        if (response.statusCode >= 500) {
          throw Exception('SERVER_ERROR: Server error during login (status ${response.statusCode})');
        }
        throw Exception('INVALID_RESPONSE: Server returned non-JSON error page (status ${response.statusCode})');
      }

      // Try to parse JSON error message
      try {
        final err = jsonDecode(body);
        final msg = err is Map && err.containsKey('message') ? err['message'] : body;
        throw Exception('LOGIN_FAILED: $msg');
      } catch (_) {
        throw Exception('LOGIN_FAILED: ${response.body}');
      }
    }
  }

  // Ambil data user (GET /auth/me)
  Future<User> getMe() async {
    final token = await Storage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Gagal ambil user: ${response.body}');
    }
  }

  // Logout
  Future<void> logout() async {
    final token = await Storage.getToken();
    await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    await Storage.clearToken();
  }
}
