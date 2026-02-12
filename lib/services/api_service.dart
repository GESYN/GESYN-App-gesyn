import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

class ApiService {
  static const String baseUrl = 'http://3.22.64.117:3100';

  static Map<String, String> defaultHeaders([String? token]) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static void _checkUnauthorized(
    http.Response response, {
    bool throwOn401 = true,
  }) {
    if (throwOn401 && response.statusCode == 401) {
      throw UnauthorizedException();
    }
  }

  static Future<http.Response> post(
    String path,
    Map body, {
    String? token,
    bool throwOn401 = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: defaultHeaders(token),
      body: jsonEncode(body),
    );
    _checkUnauthorized(response, throwOn401: throwOn401);
    return response;
  }

  static Future<http.Response> get(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.get(uri, headers: defaultHeaders(token));
    _checkUnauthorized(response);
    return response;
  }

  static Future<http.Response> patch(
    String path,
    Map body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.patch(
      uri,
      headers: defaultHeaders(token),
      body: jsonEncode(body),
    );
    _checkUnauthorized(response);
    return response;
  }

  static Future<http.Response> delete(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(uri, headers: defaultHeaders(token));
    _checkUnauthorized(response);
    return response;
  }
}
