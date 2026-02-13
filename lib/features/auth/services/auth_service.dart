import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/models/auth_user.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/error_message_parser.dart';
import '../../../core/utils/token_manager.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final TokenManager _tokenManager = TokenManager();
  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  Dio _buildAuthDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

  Future<String?> getAccessToken() async => _tokenManager.accessToken;

  Future<String?> getRefreshToken() async => _tokenManager.refreshToken;

  AuthUser? get currentUser => _tokenManager.user;

  Future<bool> isLoggedIn() async => _tokenManager.hasSession;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final dio = _buildAuthDio();
    try {
      final response = await dio.post(
        ApiConstants.authLoginEndpoint,
        data: {
          'username': email,
          'password': password,
          'grant_type': 'password',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final data = _toMap(response.data);
      final accessToken = data['access_token']?.toString();
      final refreshToken = data['refresh_token']?.toString();
      final userMap = _toMap(data['user']);

      if (accessToken == null || refreshToken == null || userMap.isEmpty) {
        throw const ApiException('Giriş yanıtı geçersiz.');
      }

      final user = AuthUser.fromJson(userMap);
      if (!user.isParent) {
        await clearSession();
        throw const ApiException(
          'Bu uygulama sadece veli hesapları ile kullanılabilir.',
        );
      }

      await _tokenManager.setSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } on DioException catch (e) {
      throw ApiException(
        _extractMessage(
          e.response?.data,
          fallback: 'Giriş başarısız.',
        ),
        statusCode: e.response?.statusCode,
        responseBody: e.response?.data?.toString(),
      );
    }
  }

  Future<bool> refreshSession() async {
    final refreshToken = _tokenManager.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final dio = _buildAuthDio();
    try {
      final response = await dio.post(
        ApiConstants.authRefreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      final data = _toMap(response.data);
      final accessToken = data['access_token']?.toString();
      final newRefreshToken = data['refresh_token']?.toString();
      final userMap = _toMap(data['user']);

      if (accessToken == null || newRefreshToken == null || userMap.isEmpty) {
        return false;
      }

      final user = AuthUser.fromJson(userMap);
      if (!user.isParent) {
        await clearSession();
        return false;
      }

      await _tokenManager.setSession(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        user: user,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final accessToken = await getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      final dio = _buildAuthDio();
      try {
        await dio.post(
          ApiConstants.authLogoutEndpoint,
          options: Options(
            headers: {'Authorization': 'Bearer $accessToken'},
          ),
        );
      } catch (_) {
        // best-effort logout
      }
    }

    await clearSession();
  }

  Future<AuthUser?> fetchCurrentUser() async {
    final accessToken = _tokenManager.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    final dio = _buildAuthDio();
    try {
      final response = await dio.get(
        ApiConstants.authMeEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final userMap = _toMap(response.data);
      if (userMap.isEmpty) {
        return null;
      }

      final user = AuthUser.fromJson(userMap);
      if (!user.isParent) {
        await clearSession();
        return null;
      }

      await _tokenManager.setUser(user);
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _tokenManager.clearSession();
  }

  Future<void> handleSessionExpired() async {
    await clearSession();
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  String _extractMessage(dynamic raw, {required String fallback}) =>
      parseErrorMessage(raw, fallbackMessage: fallback);
}
