import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static String? token;

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 30));

    return handleResponse(response);
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 30));

    return handleResponse(response);
  }

  static dynamic handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data is Map
          ? data['detail'] ?? 'Server error'
          : 'Server error',
    );
  }

  static Future<void> sendCode(String email) async {
    await post('/auth/code', {'email': email});
  }

  static Future<void> login(String email, String code) async {
    final data = await post('/auth/login', {
      'email': email,
      'code': code,
    });

    token = data['token'] as String;
  }

  static Future<dynamic> getProfile() {
    return get('/auth/me');
  }

  static void logout() {
    token = null;
  }
}