import 'package:flutter/material.dart';
import '../repository/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.login(email, password);
      if (!success) {
        _errorMessage = "Giriş başarısız. Lütfen bilgilerinizi kontrol edin.";
      }
      return success;
    } catch (e) {
      _errorMessage = "Bir hata oluştu: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
