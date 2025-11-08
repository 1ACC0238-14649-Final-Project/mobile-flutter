import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../common/constants.dart';
import 'user_dto.dart';

class AuthService {
  final http.Client _client;
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<void> signUp(UserDto dto, String password) async {
    final uri = Uri.parse('${Constants.baseUrl}${Constants.signUpEndpoint}');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
      body: jsonEncode(dto.toJsonForSignUp(password: password)),
    );
    if (res.statusCode == 201) return;
    if (res.statusCode == 409) {
      throw Exception(jsonDecodeSafe(res.body) ?? 'Email already taken.');
    }
    throw Exception('HTTP ${res.statusCode}: ${jsonDecodeSafe(res.body) ?? 'Sign-up failed.'}');
  }

  Future<String> login({required String email, required String password}) async {
    final uri = Uri.parse('${Constants.baseUrl}${Constants.loginEndpoint}');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final body = res.body.trim();
      if (body.startsWith('{')) {
        final map = jsonDecode(body) as Map<String, dynamic>;
        final token = (map['token'] ?? map['accessToken'] ?? map['jwt'])?.toString();
        if (token == null || token.isEmpty) throw Exception('No token in response.');
        return token;
      }
      return body.replaceAll('"', '');
    }
    if (res.statusCode == 401) {
      throw Exception(jsonDecodeSafe(res.body) ?? 'Invalid credentials.');
    }
    throw Exception('HTTP ${res.statusCode}: ${jsonDecodeSafe(res.body) ?? 'Login failed.'}');
  }

  Future<UserDto> me(String token) async {
    final uri = Uri.parse('${Constants.baseUrl}${Constants.meEndpoint}');
    final res = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      final body = res.body.trim();
      if (body.startsWith('{')) {
        return UserDto.fromJson(jsonDecode(body));
      }
      return UserDto(email: body.replaceAll('"', ''));
    }
    if (res.statusCode == 401) throw Exception('Unauthorized.');
    if (res.statusCode == 404) throw Exception('User not found.');
    throw Exception('HTTP ${res.statusCode}: ${jsonDecodeSafe(res.body) ?? 'Failed to fetch current user.'}');
  }

  String? jsonDecodeSafe(String? body) {
    if (body == null) return null;
    final t = body.trim();
    if (t.isEmpty) return null;
    try {
      final v = jsonDecode(t);
      if (v is Map && v['message'] is String) return v['message'] as String;
      if (v is String) return v;
      return t;
    } catch (_) {
      return t;
    }
  }
}
