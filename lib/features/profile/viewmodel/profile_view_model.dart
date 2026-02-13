import 'package:flutter/material.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/state/selected_student_state.dart';
import '../../../core/utils/token_manager.dart';
import '../../auth/services/auth_service.dart';
import '../../home/data/models/home_status_model.dart';
import '../data/services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService;
  final AuthService _authService;
  final NotificationService _notificationService;
  final SelectedStudentState _selectedStudentState;
  final TokenManager _tokenManager;
  final AnalyticsService _analyticsService;

  ProfileViewModel({
    required SelectedStudentState selectedStudentState,
    ProfileService? profileService,
    AuthService? authService,
    NotificationService? notificationService,
    TokenManager? tokenManager,
  })  : _profileService = profileService ?? ProfileService(),
        _authService = authService ?? AuthService(),
        _notificationService = notificationService ?? NotificationService(),
        _selectedStudentState = selectedStudentState,
        _tokenManager = tokenManager ?? TokenManager(),
        _analyticsService = AnalyticsService() {
    _selectedStudentState.addListener(_onSelectedStudentChanged);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAbsenceUpdating = false;
  bool get isAbsenceUpdating => _isAbsenceUpdating;

  bool _isAddressUpdating = false;
  bool get isAddressUpdating => _isAddressUpdating;

  Student? get currentStudent => _selectedStudentState.selectedStudent;
  List<Student> get students => _selectedStudentState.students;
  bool get hasMultipleStudents => _selectedStudentState.hasMultipleStudents;
  String? get selectedStudentId => _selectedStudentState.selectedStudent?.id;

  bool _isAbsent = false;
  bool get isAbsent => _isAbsent;

  DateTime? _absenceUpdatedAt;
  DateTime? get absenceUpdatedAt => _absenceUpdatedAt;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;

  String get parentDisplayName {
    final fullName = _tokenManager.user?.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    return 'Sayın Veli';
  }

  Future<void> init() async {
    await _fetchProfileData();
  }

  Future<void> reload() async {
    await _fetchProfileData(refreshStudents: true);
  }

  void selectStudent(String studentId) {
    _selectedStudentState.selectStudentById(studentId);
  }

  Future<void> _fetchProfileData({bool refreshStudents = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _selectedStudentState.loadStudents(forceRefresh: refreshStudents);
      await _loadAbsenceStatusForSelectedStudent();
    } catch (e) {
      _errorMessage = _mapError(
        e,
        fallback: 'Profil bilgileri alınamadı.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAbsenceStatusForSelectedStudent() async {
    final student = currentStudent;
    if (student == null) {
      _isAbsent = false;
      _absenceUpdatedAt = null;
      return;
    }

    final status = await _profileService.getAbsenceStatus(student.id);
    _isAbsent = status.isAbsentToday;
    _absenceUpdatedAt = status.updatedAt;
  }

  Future<bool> toggleAbsence(bool value) async {
    final student = currentStudent;
    if (student == null || _isAbsenceUpdating) {
      return false;
    }

    _isAbsenceUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = value
          ? await _profileService.cancelAbsence(student.id)
          : await _profileService.reportAbsence(student.id);

      if (!success) {
        _errorMessage = value
            ? 'Devamsızlık kaydı geri alınamadı.'
            : 'Devamsızlık kaydı gönderilemedi.';
        return false;
      }

      await _loadAbsenceStatusForSelectedStudent();
      _analyticsService.logEvent(
        'attendance_marked',
        parameters: <String, Object?>{
          'role': 'parent',
          'student_id': student.id,
          'is_absent_today': _isAbsent,
        },
      );
      return true;
    } catch (e) {
      _errorMessage = _mapError(
        e,
        fallback: value
            ? 'Devamsızlık kaydı geri alınamadı.'
            : 'Devamsızlık kaydı gönderilemedi.',
      );
      return false;
    } finally {
      _isAbsenceUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(String newAddress) async {
    final student = currentStudent;
    if (student == null || _isAddressUpdating) {
      return false;
    }

    _isAddressUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedStudent = await _profileService.updateStudentAddress(
        student.id,
        newAddress,
      );

      if (updatedStudent == null) {
        _errorMessage = 'Adres güncellenemedi.';
        return false;
      }

      _selectedStudentState.updateStudent(updatedStudent);
      return true;
    } catch (e) {
      _errorMessage = _mapError(e, fallback: 'Adres güncellenemedi.');
      return false;
    } finally {
      _isAddressUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    if (_isLoggingOut) {
      return false;
    }

    _isLoggingOut = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _notificationService.removeToken();
      await _authService.logout();
      return true;
    } catch (e) {
      _errorMessage = _mapError(e, fallback: 'Çıkış yapılamadı.');
      return false;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }

  void _onSelectedStudentChanged() {
    _refreshForSelectedStudent();
  }

  Future<void> _refreshForSelectedStudent() async {
    final student = currentStudent;
    if (student == null) {
      _isAbsent = false;
      _absenceUpdatedAt = null;
      notifyListeners();
      return;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      await _loadAbsenceStatusForSelectedStudent();
    } catch (e) {
      _errorMessage = _mapError(e, fallback: 'Devamsızlık durumu alınamadı.');
    } finally {
      notifyListeners();
    }
  }

  String _mapError(Object error, {required String fallback}) {
    if (error is ApiException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    final text = error.toString().replaceAll('Exception: ', '').trim();
    return text.isEmpty ? fallback : text;
  }

  @override
  void dispose() {
    _selectedStudentState.removeListener(_onSelectedStudentChanged);
    super.dispose();
  }
}
