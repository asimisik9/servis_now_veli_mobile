import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _accessToken;
  String? _refreshToken;
  AuthUser? _user;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  AuthUser? get user => _user;
  bool get hasSession => _accessToken != null && _refreshToken != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    final userJson = prefs.getString('auth_user');
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(userJson);
        if (decoded is Map<String, dynamic>) {
          _user = AuthUser.fromJson(decoded);
        } else if (decoded is Map) {
          _user = AuthUser.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        _user = null;
      }
    }
  }

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    AuthUser? user,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    if (user != null) {
      _user = user;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    if (_user != null) {
      await prefs.setString('auth_user', jsonEncode(_user!.toJson()));
    }
  }

  Future<void> setUser(AuthUser user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', jsonEncode(user.toJson()));
  }

  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    required AuthUser user,
  }) async {
    await setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('auth_user');
  }

  Future<void> clearTokens() async {
    await clearSession();
  }
}
