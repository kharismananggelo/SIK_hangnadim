import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sik_hangnadim_mobile/model/user_model.dart';
import 'package:sik_hangnadim_mobile/utils/constants.dart';
import 'package:sik_hangnadim_mobile/utils/storage.dart';

/// Exception used by services to carry a user-friendly message and optional
/// field-level errors returned by the API.
class ApiException implements Exception {
  final String userMessage;
  final Map<String, dynamic>? errors;
  ApiException(this.userMessage, [this.errors]);
  @override
  String toString() => 'ApiException: $userMessage';
}

class AuthService {
  //register user baru
  /// Register a new user. On success this saves the token (if provided)
  /// into secure storage and returns nothing. UI should handle navigation
  /// (e.g., redirect to login) after this completes.
  /// Register a new user. Returns the parsed JSON response map from the
  /// backend. If an `access_token` is present it will be saved into secure
  /// storage. On validation errors this throws [ApiException].
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String? vendorName,
    String password,
    String confirm,
  ) async {
    final Map<String, dynamic> bodyPayload = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': confirm,
    };
    // include vendor_name if provided
    if (vendorName != null && vendorName.trim().isNotEmpty) {
      bodyPayload['vendor_name'] = vendorName.trim();
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyPayload),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // Some backends may reply 201 but include an errors/message that
      // indicate the email is already taken or other validation issues.
      // Treat those as failures rather than silent successes.
      if (data is Map) {
        // If an `errors` object exists, surface it as an ApiException
        if (data.containsKey('errors') && data['errors'] is Map && (data['errors'] as Map).isNotEmpty) {
          final errorsMap = Map<String, dynamic>.from(data['errors']);
          final first = errorsMap.values.first;
          var userMessage = 'Gagal melakukan pendaftaran';
          if (first is List && first.isNotEmpty) userMessage = first.first.toString();
          else if (first is String) userMessage = first;
          userMessage = _localizeMessage(userMessage);
          throw ApiException(userMessage, errorsMap);
        }

        // Some APIs return a success HTTP code but include a message like
        // "The email has already been taken" — detect and convert to an error.
        if (data.containsKey('message')) {
          final msg = data['message'].toString();
          final lower = msg.toLowerCase();
          if (lower.contains('already been taken') || lower.contains('already taken') || lower.contains('already exists')) {
            throw ApiException(_localizeMessage(msg), {'email': [msg]});
          }
        }
      }

      if (data is Map && data.containsKey('access_token')) {
        await Storage.saveToken(data['access_token']);
      }

      // Return the parsed response so callers can inspect whether an
      // access_token was provided or if the server expects an email
      // verification flow.
      if (data is Map<String, dynamic>) return data;
      return {'raw': data};
    } else {
      // Try to parse backend validation errors and provide a friendly message
      String userMessage = 'Gagal melakukan pendaftaran';
      Map<String, dynamic>? errorsMap;
      try {
        final parsed = jsonDecode(response.body);
        if (parsed is Map) {
          // prefer `message` if present
          if (parsed.containsKey('message')) {
            userMessage = parsed['message'].toString();
          }
          // extract `errors` map if present
          if (parsed.containsKey('errors') && parsed['errors'] is Map) {
            errorsMap = Map<String, dynamic>.from(parsed['errors']);
            // take first error message for a concise user message
            final first = errorsMap.values.first;
            if (first is List && first.isNotEmpty) {
              userMessage = first.first.toString();
            } else if (first is String) {
              userMessage = first;
            }
          }
        }
      } catch (_) {
        // ignore parse errors and fall back to default
      }

      // Map some common backend English messages to Indonesian for better UX
      userMessage = _localizeMessage(userMessage);

      throw ApiException(userMessage, errorsMap);
    }
  }

  // Localize some frequent backend messages to more user-friendly Indonesian
  String _localizeMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('email') && lower.contains('already been taken')) {
      return 'Email Sudah Ada!';
    }
    if (lower.contains('password') &&
        lower.contains('confirmation does not match')) {
      return 'Konfirmasi password tidak cocok';
    }
    if (lower.contains('password') && lower.contains('at least')) {
      return 'Password terlalu pendek';
    }
    // If message already feels user-friendly (non-json), return it
    return raw;
  }

  /// Check whether an email exists / is deliverable using backend API.
  ///
  /// NOTE: This requires a server endpoint like `/auth/check-email?email=...`
  /// that returns JSON: { "exists": true } or { "exists": false }.
  Future<bool> checkEmailExists(String email) async {
    final uri = Uri.parse('$baseUrl/auth/check-email?email=${Uri.encodeComponent(email)}');
    final resp = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (resp.statusCode == 200) {
      try {
        final parsed = jsonDecode(resp.body);
        if (parsed is Map && parsed.containsKey('exists')) {
          return parsed['exists'] == true;
        }
        return false;
      } catch (_) {
        return false;
      }
    }
    throw Exception('CHECK_EMAIL_FAILED: ${resp.statusCode} ${resp.body}');
  }

  /// Request backend to resend verification email for provided address.
  /// Expects endpoint POST /auth/resend-verification { email }
  Future<void> resendVerification(String email) async {
    final uri = Uri.parse('$baseUrl/auth/resend-verification');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (resp.statusCode == 200) return;
    throw Exception('RESEND_VERIFICATION_FAILED: ${resp.statusCode} ${resp.body}');
  }

  /// Ask backend whether the email has been verified. Requires endpoint
  /// GET /auth/check-verification?email=... which returns { "verified": true }
  Future<bool> checkVerificationStatus(String email) async {
    final uri = Uri.parse('$baseUrl/auth/check-verification?email=${Uri.encodeComponent(email)}');
    final resp = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (resp.statusCode == 200) {
      try {
        final parsed = jsonDecode(resp.body);
        if (parsed is Map && parsed.containsKey('verified')) return parsed['verified'] == true;
        return false;
      } catch (_) {
        return false;
      }
    }
    throw Exception('CHECK_VERIFICATION_FAILED: ${resp.statusCode} ${resp.body}');
  }

  //login
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = response.body;
    final contentType = response.headers['content-type'] ?? '';

    bool _isHtml(String s) =>
        s.trimLeft().startsWith('<') ||
        s.toLowerCase().contains('<!doctype') ||
        s.toLowerCase().contains('<html');

    if (response.statusCode == 200) {
      if (!contentType.contains('application/json') && _isHtml(body)) {
        throw Exception(
          'INVALID_RESPONSE: Server returned HTML when JSON expected (status 200)',
        );
      }

      try {
        final data = jsonDecode(body);
        await Storage.saveToken(data['access_token']);
        return User.fromJson(data['user']);
      } on FormatException catch (_) {
        throw Exception(
          'INVALID_RESPONSE: Server returned invalid JSON for login',
        );
      }
    } else {
      // Non-200: detect HTML error pages first
      if (_isHtml(body)) {
        if (response.statusCode == 404) {
          throw Exception(
            'ENDPOINT_NOT_FOUND: Login endpoint not found (status 404)',
          );
        }
        if (response.statusCode >= 500) {
          throw Exception(
            'SERVER_ERROR: Server error during login (status ${response.statusCode})',
          );
        }
        throw Exception(
          'INVALID_RESPONSE: Server returned non-JSON error page (status ${response.statusCode})',
        );
      }

      // Try to parse JSON error message
      try {
        final err = jsonDecode(body);
        final msg = err is Map && err.containsKey('message')
            ? err['message']
            : body;
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
