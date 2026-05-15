import '../services/auth_service.dart';
import '../models/auth_action_result.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<AuthActionResult> forgotPassword(String email);
  Future<AuthActionResult> resetPassword({
    required String token,
    required String newPassword,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({AuthService? authService})
      : _authService = authService ?? AuthService();

  @override
  Future<void> login(String email, String password) async {
    await _authService.login(email: email, password: password);
  }

  @override
  Future<AuthActionResult> forgotPassword(String email) async {
    return _authService.forgotPassword(email: email);
  }

  @override
  Future<AuthActionResult> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return _authService.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }
}
