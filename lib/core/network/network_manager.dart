import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../../features/auth/services/auth_service.dart';
import '../utils/token_manager.dart';
import 'api_exceptions.dart';
import 'error_message_parser.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;

  late Dio _dio;
  Dio get dio => _dio;
  final TokenManager _tokenManager = TokenManager();
  final AuthService _authService = AuthService();
  Future<bool>? _refreshInFlight;

  NetworkManager._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _tokenManager.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final statusCode = error.response?.statusCode;
          final alreadyRetried = request.extra['_retried401'] == true;

          if (statusCode != 401 ||
              alreadyRetried ||
              _isAuthEndpoint(request.path)) {
            handler.next(error);
            return;
          }

          final refreshed = await _refreshSessionSingleFlight();
          if (!refreshed) {
            await _authService.handleSessionExpired();
            handler.reject(
              DioException(
                requestOptions: request,
                response: error.response,
                type: DioExceptionType.badResponse,
                error: const AuthExpiredException(
                  'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
                ),
              ),
            );
            return;
          }

          final newAccessToken = _tokenManager.accessToken;
          if (newAccessToken == null || newAccessToken.isEmpty) {
            await _authService.handleSessionExpired();
            handler.reject(
              DioException(
                requestOptions: request,
                response: error.response,
                type: DioExceptionType.badResponse,
                error: const AuthExpiredException(
                  'Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.',
                ),
              ),
            );
            return;
          }

          final retryRequest = request.copyWith(
            headers: {
              ...request.headers,
              'Authorization': 'Bearer $newAccessToken',
            },
            extra: {
              ...request.extra,
              '_retried401': true,
            },
          );

          try {
            final response = await _dio.fetch<dynamic>(retryRequest);
            handler.resolve(response);
          } catch (e) {
            if (e is DioException) {
              handler.reject(e);
            } else {
              handler.reject(
                DioException(
                  requestOptions: retryRequest,
                  type: DioExceptionType.unknown,
                  error: e,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<bool> _refreshSessionSingleFlight() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final completer = Completer<bool>();
    _refreshInFlight = completer.future;

    () async {
      try {
        final refreshed = await _authService.refreshSession();
        completer.complete(refreshed);
      } catch (_) {
        completer.complete(false);
      } finally {
        _refreshInFlight = null;
      }
    }();

    return _refreshInFlight!;
  }

  bool _isAuthEndpoint(String path) {
    final normalizedPath = path.split('?').first;
    return normalizedPath == ApiConstants.authLoginEndpoint ||
        normalizedPath == ApiConstants.authRefreshEndpoint ||
        normalizedPath == ApiConstants.authLogoutEndpoint ||
        normalizedPath == ApiConstants.authMeEndpoint;
  }

  ApiException mapError(
    Object error, {
    required String fallbackMessage,
  }) {
    if (error is ApiException) {
      return error;
    }
    if (error is DioException) {
      return _mapDioException(error, fallbackMessage: fallbackMessage);
    }
    final text = error.toString().replaceAll('Exception: ', '').trim();
    if (text.isNotEmpty) {
      return ApiException(text);
    }
    return ApiException(fallbackMessage);
  }

  ApiException _mapDioException(
    DioException error, {
    required String fallbackMessage,
  }) {
    final wrapped = error.error;
    if (wrapped is ApiException) {
      return wrapped;
    }
    if (wrapped is AuthExpiredException) {
      return wrapped;
    }

    final response = error.response;
    final message = extractErrorMessage(
      response,
      fallbackMessage: fallbackMessage,
    );
    return ApiException(
      message,
      statusCode: response?.statusCode,
      responseBody: response?.data?.toString(),
    );
  }

  String extractErrorMessage(
    Response<dynamic>? response, {
    required String fallbackMessage,
  }) {
    if (response == null) {
      return fallbackMessage;
    }

    final data = response.data;
    if (data == null) {
      return '$fallbackMessage (${response.statusCode})';
    }

    return parseErrorMessage(
      data,
      fallbackMessage: '$fallbackMessage (${response.statusCode})',
    );
  }
}
