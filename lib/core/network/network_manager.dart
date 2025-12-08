import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/token_manager.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  
  late Dio _dio;
  Dio get dio => _dio;

  NetworkManager._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = TokenManager().accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Try to refresh token
          final refreshToken = TokenManager().refreshToken;
          if (refreshToken != null) {
            try {
              // Create a new Dio instance to avoid loop
              final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
              final response = await refreshDio.post('/auth/refresh', data: {
                'refresh_token': refreshToken
              });

              if (response.statusCode == 200) {
                final newAccessToken = response.data['access_token'];
                final newRefreshToken = response.data['refresh_token'];
                
                await TokenManager().setTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken
                );

                // Retry original request
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';
                
                final clonedRequest = await _dio.request(
                  opts.path,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                  ),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                
                return handler.resolve(clonedRequest);
              }
            } catch (refreshError) {
              // Refresh failed, logout
              await TokenManager().clearTokens();
              // TODO: Trigger logout navigation
            }
          } else {
             await TokenManager().clearTokens();
          }
        }
        return handler.next(e);
      },
    ));
  }
}
