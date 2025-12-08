import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/network_manager.dart';
import '../../../core/utils/token_manager.dart';

abstract class AuthRepository {
  Future<bool> login(String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl({Dio? dio}) : _dio = dio ?? NetworkManager().dio;

  @override
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'username': email, // OAuth2PasswordRequestForm expects 'username'
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];
        
        if (accessToken != null && refreshToken != null) {
          await TokenManager().setTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      // Handle error (log it, etc.)
      return false;
    }
  }
}
