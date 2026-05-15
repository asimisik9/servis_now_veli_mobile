import 'package:flutter/material.dart';

import '../../../core/network/api_exceptions.dart';
import '../models/auth_action_result.dart';
import '../repository/auth_repository.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  ResetPasswordViewModel({
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ?? AuthRepositoryImpl();

  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<AuthActionResult?> submit({
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.resetPassword(
        token: token,
        newPassword: newPassword,
      );
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
