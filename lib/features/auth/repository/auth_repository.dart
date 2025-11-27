import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

import '../../../core/utils/token_manager.dart';

abstract class AuthRepository {
  Future<bool> login(String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

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
        final token = response.data['access_token'];
        if (token != null) {
          TokenManager().setToken(token);
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
