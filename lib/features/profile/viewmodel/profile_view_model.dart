import 'package:flutter/material.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/state/selected_student_state.dart';
import '../../../core/utils/token_manager.dart';
import '../../auth/services/auth_service.dart';
import '../../home/data/models/home_status_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService;
  final NotificationService _notificationService;
  final SelectedStudentState _selectedStudentState;
  final TokenManager _tokenManager;

  ProfileViewModel({
    required SelectedStudentState selectedStudentState,
    AuthService? authService,
    NotificationService? notificationService,
    TokenManager? tokenManager,
  })  : _authService = authService ?? AuthService(),
        _notificationService = notificationService ?? NotificationService(),
        _selectedStudentState = selectedStudentState,
        _tokenManager = tokenManager ?? TokenManager() {
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

    _isAbsent = false;
    _absenceUpdatedAt = null;

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleAbsence(bool value) async {
    if (_isAbsenceUpdating) return false;
    _isAbsenceUpdating = true;
    notifyListeners();

    _isAbsent = !value;
    _absenceUpdatedAt = !value ? DateTime.now() : null;

    _isAbsenceUpdating = false;
    notifyListeners();
    return true;
  }

  Future<bool> updateAddress(String newAddress) async {
    final student = currentStudent;
    if (student == null || _isAddressUpdating) return false;

    _isAddressUpdating = true;
    notifyListeners();

    _selectedStudentState.updateStudent(
      student.copyWith(address: newAddress),
    );

    _isAddressUpdating = false;
    notifyListeners();
    return true;
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
      _errorMessage = 'Çıkış yapılamadı.';
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
    _isAbsent = false;
    _absenceUpdatedAt = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _selectedStudentState.removeListener(_onSelectedStudentChanged);
    super.dispose();
  }
}
