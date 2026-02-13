import '../services/auth_service.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({AuthService? authService})
      : _authService = authService ?? AuthService();

  @override
  Future<void> login(String email, String password) async {
    await _authService.login(email: email, password: password);
  }
}
