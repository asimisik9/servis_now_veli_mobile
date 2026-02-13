import 'package:flutter/material.dart';
import '../../../core/services/phone_launcher_service.dart';
import '../../../core/network/api_exceptions.dart';
import '../data/models/home_status_model.dart';
import '../data/services/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeService _homeService;
  final PhoneLauncherService _phoneLauncherService;

  HomeViewModel({
    HomeService? homeService,
    PhoneLauncherService? phoneLauncherService,
  })  : _homeService = homeService ?? HomeService(),
        _phoneLauncherService = phoneLauncherService ?? PhoneLauncherService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeStatusModel? _homeStatus;
  HomeStatusModel? get homeStatus => _homeStatus;

  Student? _currentStudent;
  Student? get currentStudent => _currentStudent;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch Students
      final students = await _homeService.fetchStudents();

      if (students.isEmpty) {
        _errorMessage = "Kayıtlı öğrenci bulunamadı.";
      } else {
        // 2. Fetch Dashboard for the first student
        final firstStudent = students.first;
        _currentStudent = firstStudent;
        _homeStatus = await _homeService.fetchStudentDashboard(firstStudent.id);
      }
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage =
            "Veri yüklenirken bir hata oluştu. Lütfen tekrar deneyin.";
      }
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> callDriver(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return 'Sürücü telefon numarası bulunamadı.';
    }

    try {
      final launched = await _phoneLauncherService.call(phoneNumber);
      if (!launched) {
        return 'Sürücü aranamadı.';
      }
      return null;
    } catch (_) {
      return 'Sürücü aranırken hata oluştu.';
    }
  }
}
