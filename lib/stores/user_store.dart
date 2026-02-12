import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class UserStore extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  User? _user;
  bool _loading = false;

  String? get accessToken => _accessToken;
  User? get user => _user;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  bool get loading => _loading;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    _accessToken = sp.getString('accessToken');
    _refreshToken = sp.getString('refreshToken');
    final userJson = sp.getString('user');
    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson));
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _loading = true;
    notifyListeners();

    try {
      final resp = await ApiService.post(
        '/api/v1/auth/login',
        {'email': email, 'password': password},
        throwOn401: false, // Não lançar exceção no login
      );

      _loading = false;
      notifyListeners();

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        await _saveTokensAndUser(data);
        return {'ok': true, 'data': data};
      } else {
        try {
          final err = jsonDecode(resp.body);
          return {'ok': false, 'status': resp.statusCode, 'error': err};
        } catch (e) {
          return {'ok': false, 'status': resp.statusCode, 'error': resp.body};
        }
      }
    } catch (e) {
      _loading = false;
      notifyListeners();
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    _loading = true;
    notifyListeners();

    try {
      final resp = await ApiService.post(
        '/api/v1/auth/register',
        body,
        throwOn401: false, // Não lançar exceção no registro
      );

      _loading = false;
      notifyListeners();

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        await _saveTokensAndUser(data);
        return {'ok': true, 'data': data};
      } else {
        try {
          final err = jsonDecode(resp.body);
          return {'ok': false, 'status': resp.statusCode, 'error': err};
        } catch (e) {
          return {'ok': false, 'status': resp.statusCode, 'error': resp.body};
        }
      }
    } catch (e) {
      _loading = false;
      notifyListeners();
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<void> _saveTokensAndUser(Map<String, dynamic> data) async {
    _accessToken = data['accessToken'] ?? data['access_token'] ?? '';
    _refreshToken = data['refreshToken'] ?? data['refresh_token'] ?? '';
    final u = data['user'] ?? {};
    try {
      _user = User.fromJson(Map<String, dynamic>.from(u));
    } catch (e) {
      _user = null;
    }
    final sp = await SharedPreferences.getInstance();
    await sp.setString('accessToken', _accessToken ?? '');
    await sp.setString('refreshToken', _refreshToken ?? '');
    if (_user != null) {
      await sp.setString('user', jsonEncode(_user!.toJson()));
    }
  }

  Future<void> logout() async {
    // call backend logout optionally
    try {
      await ApiService.post('/api/v1/auth/logout', {}, token: _accessToken);
    } catch (_) {}
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    final sp = await SharedPreferences.getInstance();
    await sp.remove('accessToken');
    await sp.remove('refreshToken');
    await sp.remove('user');
    notifyListeners();
  }

  Future<Map<String, dynamic>> refresh() async {
    if (_refreshToken == null)
      return {'ok': false, 'error': 'no refresh token'};
    final resp = await ApiService.post('/api/v1/auth/refresh', {});
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      await _saveTokensAndUser(data);
      notifyListeners();
      return {'ok': true, 'data': data};
    }
    return {'ok': false, 'status': resp.statusCode};
  }

  Future<Map<String, dynamic>> loadProfile() async {
    if (!isAuthenticated) return {'ok': false, 'error': 'not authenticated'};
    final resp = await ApiService.get(
      '/api/v1/auth/profile',
      token: _accessToken,
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      _user = User.fromJson(Map<String, dynamic>.from(data));
      final sp = await SharedPreferences.getInstance();
      await sp.setString('user', jsonEncode(_user!.toJson()));
      notifyListeners();
      return {'ok': true, 'data': data};
    }
    return {'ok': false, 'status': resp.statusCode};
  }
}
