import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient(this.baseUrl);
  final String baseUrl;
  String? token;

  Uri uri(String path) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$base${path.startsWith('/') ? path : '/$path'}');
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<void> _saveToken() async {
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token!);
    }
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      uri('/users/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );
    if (response.statusCode >= 400) {
      final detail = jsonDecode(response.body)['detail']?.toString() ?? 'Login failed';
      throw Exception(detail);
    }
    final data = jsonDecode(response.body);
    token = data['access_token']?.toString();
    await _saveToken();
  }

  Future<void> register(String username, String email, String password) async {
    final response = await http.post(
      uri('/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );
    if (response.statusCode >= 400) {
      final detail = jsonDecode(response.body)['detail']?.toString() ?? 'Registration failed';
      throw Exception(detail);
    }
  }

  Future<dynamic> googleAuth(String idToken) async {
    final response = await http.post(
      uri('/users/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );
    if (response.statusCode >= 400) {
      final detail = jsonDecode(response.body)['detail']?.toString() ?? 'Google auth failed';
      throw Exception(detail);
    }
    final data = jsonDecode(response.body);
    token = data['access_token']?.toString();
    await _saveToken();
    return data;
  }

  Future<List<dynamic>> list(String path) async {
    final response = await http.get(uri(path), headers: headers);
    final raw = response.body.isEmpty ? '[]' : response.body;
    final parsed = jsonDecode(raw);
    if (response.statusCode >= 400) {
      throw Exception(parsed['detail']?.toString() ?? 'Request failed');
    }
    final List<dynamic> items = parsed is List ? parsed : (parsed['items'] as List? ?? []);
    return List<Map<String, dynamic>>.from(items);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(uri(path), headers: headers);
    if (response.statusCode >= 400) {
      throw Exception((jsonDecode(response.body)['detail'] ?? 'Request failed').toString());
    }
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<void> save(String path, Map<String, dynamic> payload, [int? id]) async {
    final target = id == null ? uri(path) : uri('$path/$id');
    final request = id == null ? http.post : http.put;
    final response = await request(target, headers: headers, body: jsonEncode(payload));
    if (response.statusCode >= 400) {
      throw Exception((jsonDecode(response.body)['detail'] ?? 'Request failed').toString());
    }
  }

  Future<void> delete(String path, int id) async {
    final response = await http.delete(uri('$path/$id'), headers: headers);
    if (response.statusCode >= 400) {
      throw Exception((jsonDecode(response.body)['detail'] ?? 'Request failed').toString());
    }
  }

  Future<String> askAi(String prompt) async {
    final response = await http.post(
      uri('/ai/chat'),
      headers: headers,
      body: jsonEncode({'prompt': prompt}),
    );
    if (response.statusCode >= 400) {
      throw Exception((jsonDecode(response.body)['detail'] ?? 'AI request failed').toString());
    }
    final data = jsonDecode(response.body);
    return data['reply']?.toString() ?? 'No reply returned.';
  }

  Future<void> clearToken() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
