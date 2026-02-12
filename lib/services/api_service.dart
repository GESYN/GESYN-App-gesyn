import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://3.22.64.117:3100';

  static Map<String, String> defaultHeaders([String? token]) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> post(
    String path,
    Map body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(
      uri,
      headers: defaultHeaders(token),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: defaultHeaders(token));
  }

  static Future<http.Response> patch(
    String path,
    Map body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.patch(
      uri,
      headers: defaultHeaders(token),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.delete(uri, headers: defaultHeaders(token));
  }
}
