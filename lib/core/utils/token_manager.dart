import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_user.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  String? _accessToken;
  String? _refreshToken;
  AuthUser? _user;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  AuthUser? get user => _user;
  bool get hasSession => _accessToken != null && _refreshToken != null;

  Future<void> init() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
    final userJson = await _storage.read(key: 'auth_user');
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
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    if (_user != null) {
      await _storage.write(key: 'auth_user', value: jsonEncode(_user!.toJson()));
    }
  }

  Future<void> setUser(AuthUser user) async {
    _user = user;
    await _storage.write(key: 'auth_user', value: jsonEncode(user.toJson()));
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
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'auth_user');
  }

  Future<void> clearTokens() async {
    await clearSession();
  }
}
