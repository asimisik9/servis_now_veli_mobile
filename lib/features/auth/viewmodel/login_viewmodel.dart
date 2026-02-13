import 'package:flutter/material.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/notification_service.dart';
import '../repository/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;
  final AnalyticsService _analyticsService;

  LoginViewModel({
    AuthRepository? authRepository,
    NotificationService? notificationService,
  })  : _authRepository = authRepository ?? AuthRepositoryImpl(),
        _notificationService = notificationService ?? NotificationService(),
        _analyticsService = AnalyticsService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(email, password);
      await _notificationService.getAndRegisterToken();
      _analyticsService.logEvent(
        'login_success',
        parameters: <String, Object?>{'role': 'parent'},
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "Bir hata oluştu: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
