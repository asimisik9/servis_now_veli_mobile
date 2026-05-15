import 'package:flutter/material.dart';

import '../../../core/network/api_exceptions.dart';
import '../models/auth_action_result.dart';
import '../repository/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepositoryImpl();

  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<AuthActionResult?> submit(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.forgotPassword(email);
      _successMessage = result.message;
      return result;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
