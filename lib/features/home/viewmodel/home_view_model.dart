import 'package:flutter/material.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/phone_launcher_service.dart';
import '../../../core/state/selected_student_state.dart';
import '../data/models/home_status_model.dart';
import '../data/services/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeService _homeService;
  final PhoneLauncherService _phoneLauncherService;
  final SelectedStudentState _selectedStudentState;
  final AnalyticsService _analyticsService;

  HomeViewModel({
    required SelectedStudentState selectedStudentState,
    HomeService? homeService,
    PhoneLauncherService? phoneLauncherService,
  })  : _homeService = homeService ?? HomeService(),
        _phoneLauncherService = phoneLauncherService ?? PhoneLauncherService(),
        _selectedStudentState = selectedStudentState,
        _analyticsService = AnalyticsService() {
    _selectedStudentState.addListener(_onSelectedStudentChanged);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeStatusModel? _homeStatus;
  HomeStatusModel? get homeStatus => _homeStatus;

  Student? get currentStudent => _selectedStudentState.selectedStudent;
  List<Student> get students => _selectedStudentState.students;
  bool get hasMultipleStudents => _selectedStudentState.hasMultipleStudents;
  String? get selectedStudentId => _selectedStudentState.selectedStudent?.id;

  String? _loadedStudentId;

  void init() {
    fetchHomeData();
  }

  Future<void> fetchHomeData({bool refreshStudents = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _selectedStudentState.loadStudents(forceRefresh: refreshStudents);
      final student = _selectedStudentState.selectedStudent;
      if (student == null) {
        _loadedStudentId = null;
        _homeStatus = null;
        _errorMessage = 'Kayıtlı öğrenci bulunamadı.';
        return;
      }

      _loadedStudentId = student.id;
      _homeStatus = await _homeService.fetchStudentDashboard(student.id);
      _analyticsService.logEvent(
        'home_loaded',
        parameters: <String, Object?>{
          'role': 'parent',
          'student_id': student.id,
        },
      );
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage =
            'Veri yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';
      }
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectStudent(String studentId) {
    _selectedStudentState.selectStudentById(studentId);
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

  void _onSelectedStudentChanged() {
    final selectedId = _selectedStudentState.selectedStudent?.id;
    if (_isLoading || selectedId == _loadedStudentId) {
      return;
    }

    if (selectedId == null) {
      _loadedStudentId = null;
      _homeStatus = null;
      notifyListeners();
      return;
    }

    _refreshDashboardForSelectedStudent(selectedId);
  }

  Future<void> _refreshDashboardForSelectedStudent(String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loadedStudentId = studentId;
      _homeStatus = await _homeService.fetchStudentDashboard(studentId);
      _analyticsService.logEvent(
        'home_loaded',
        parameters: <String, Object?>{
          'role': 'parent',
          'student_id': studentId,
        },
      );
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Özet bilgiler güncellenemedi.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _selectedStudentState.removeListener(_onSelectedStudentChanged);
    super.dispose();
  }
}
