import 'package:flutter/material.dart';

import '../../../core/services/phone_launcher_service.dart';
import '../../../core/state/selected_student_state.dart';
import '../../../core/utils/token_manager.dart';
import '../data/models/home_status_model.dart';
import '../data/services/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeService _homeService;
  final PhoneLauncherService _phoneLauncherService;
  final SelectedStudentState _selectedStudentState;

  HomeViewModel({
    required SelectedStudentState selectedStudentState,
    HomeService? homeService,
    PhoneLauncherService? phoneLauncherService,
  })  : _homeService = homeService ?? HomeService(),
        _phoneLauncherService = phoneLauncherService ?? PhoneLauncherService(),
        _selectedStudentState = selectedStudentState {
    _selectedStudentState.addListener(_onSelectedStudentChanged);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeStatusModel? _homeStatus;
  HomeStatusModel? get homeStatus => _homeStatus;

  bool _isAbsent = false;
  bool get isAbsent => _isAbsent;

  bool _isAbsenceLoading = false;
  bool get isAbsenceLoading => _isAbsenceLoading;

  Student? get currentStudent => _selectedStudentState.selectedStudent;
  List<Student> get students => _selectedStudentState.students;
  bool get hasMultipleStudents => _selectedStudentState.hasMultipleStudents;
  String? get selectedStudentId => _selectedStudentState.selectedStudent?.id;

  String get parentDisplayName {
    final fullName = TokenManager().user?.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return 'Ayşe Hanım'; // TODO: remove mock fallback
  }

  String? _loadedStudentId;

  void init() {
    fetchHomeData();
  }

  Future<void> fetchHomeData({bool refreshStudents = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _loadMockData();

    _isLoading = false;
    notifyListeners();
  }

  // TODO: remove when backend is connected
  void _loadMockData() {
    _selectedStudentState.setMockStudents([
      Student(
        id: 'mock_1',
        fullName: 'Efe Yılmaz',
        studentNumber: '2024001',
        schoolName: 'Bahçeşehir Koleji',
        address: 'Bahçeşehir Mah. Birinci Cad. No:5 İstanbul',
      ),
      Student(
        id: 'mock_2',
        fullName: 'Zeynep Yılmaz',
        studentNumber: '2024002',
        schoolName: 'Bahçeşehir Koleji',
        address: 'Bahçeşehir Mah. Birinci Cad. No:5 İstanbul',
      ),
      Student(
        id: 'mock_3',
        fullName: 'Ali Yılmaz',
        studentNumber: '2024003',
        schoolName: 'Acıbadem İlkokulu',
        address: 'Acıbadem Mah. Akasyalı Sok. No:12 İstanbul',
      ),
    ]);
    _homeStatus = _mockHomeStatus();
    _loadedStudentId = _selectedStudentState.selectedStudent?.id;
  }

  HomeStatusModel _mockHomeStatus() => HomeStatusModel(
        tripStatus: 'to_school',
        minutesLeft: 15,
        driverName: 'Ahmet Yılmaz',
        driverPhone: '0532 123 45 67',
        plateNumber: '34 AB 1234',
        busId: 'mock_bus',
      );

  void selectStudent(String studentId) {
    _selectedStudentState.selectStudentById(studentId);
  }

  Future<String?> callDriver(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return 'Sürücü telefon numarası bulunamadı.';
    }
    try {
      final launched = await _phoneLauncherService.call(phoneNumber);
      if (!launched) return 'Sürücü aranamadı.';
      return null;
    } catch (_) {
      return 'Sürücü aranırken hata oluştu.';
    }
  }

  Future<String?> markAbsent({
    List<String>? serviceTypes,
    String? note,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final student = currentStudent;
    if (student == null) return 'Öğrenci seçili değil.';
    _isAbsenceLoading = true;
    notifyListeners();
    try {
      await _homeService.markAbsent(
        student.id,
        serviceTypes: serviceTypes,
        note: note,
        startDate: startDate,
        endDate: endDate,
      );
      _isAbsent = true;
      return null;
    } catch (e) {
      return 'Devamsızlık bildirimi gönderilemedi.';
    } finally {
      _isAbsenceLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateAddress(
    String address, {
    DateTime? startDate,
    DateTime? endDate,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    final student = currentStudent;
    if (student == null) return 'Öğrenci seçili değil.';
    try {
      await _homeService.updateAddress(
        student.id,
        address,
        startDate: startDate,
        endDate: endDate,
        note: note,
        latitude: latitude,
        longitude: longitude,
      );
      return null;
    } catch (e) {
      return 'Adres güncellenemedi.';
    }
  }

  void _onSelectedStudentChanged() {
    final selectedId = _selectedStudentState.selectedStudent?.id;
    if (_isLoading || selectedId == _loadedStudentId) return;

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

    _loadedStudentId = studentId;
    _homeStatus = _mockHomeStatus();
    _isAbsent = false;

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _selectedStudentState.removeListener(_onSelectedStudentChanged);
    super.dispose();
  }
}
