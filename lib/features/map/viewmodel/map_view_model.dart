import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/state/selected_student_state.dart';
import '../../home/data/models/home_status_model.dart';
import '../data/services/map_service.dart';

class MapViewModel extends ChangeNotifier {
  final MapService _mapService;
  final SelectedStudentState _selectedStudentState;
  final AnalyticsService _analyticsService;

  MapViewModel({
    required SelectedStudentState selectedStudentState,
    MapService? mapService,
  })  : _mapService = mapService ?? MapService(),
        _selectedStudentState = selectedStudentState,
        _analyticsService = AnalyticsService() {
    _selectedStudentState.addListener(_onSelectedStudentChanged);
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isServiceActive = false;
  bool get isServiceActive => _isServiceActive;

  HomeStatusModel? _serviceInfo;
  String? get driverName => _serviceInfo?.driverName;
  String? get driverPhone => _serviceInfo?.driverPhone;
  String? get plateNumber => _serviceInfo?.plateNumber;

  LatLng? _busLocation;
  LatLng? get busLocation => _busLocation;

  List<Student> get students => _selectedStudentState.students;
  bool get hasMultipleStudents => _selectedStudentState.hasMultipleStudents;
  String? get selectedStudentId => _selectedStudentState.selectedStudent?.id;

  Timer? _serviceStatusTimer;
  Timer? _wsReconnectTimer;
  StreamSubscription<LatLng>? _locationSubscription;

  String? _currentStudentId;
  String? _activeBusId;
  DateTime? _trackingStartedAt;
  String? _firstLocationLoggedStudentId;

  void init() {
    _initializeData();
  }

  void onTabActivated() {
    _startServiceStatusPolling();
    _pollServiceStatus();
  }

  void onTabDeactivated() {
    _serviceStatusTimer?.cancel();
    _serviceStatusTimer = null;
    _cancelWsReconnect(resetAttempt: true);
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _activeBusId = null;
    _busLocation = null;
    notifyListeners();
  }

  void selectStudent(String studentId) {
    _selectedStudentState.selectStudentById(studentId);
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    _currentStudentId = _selectedStudentState.selectedStudent?.id;
    if (_currentStudentId != null) {
      await _syncServiceState(initialLoad: true);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshLocation() async {
    if (_currentStudentId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _syncServiceState(initialLoad: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncServiceState({required bool initialLoad}) async {
    final studentId = _currentStudentId;
    if (studentId == null) return;

    try {
      final serviceInfo = await _mapService.getServiceInfo(studentId);
      _serviceInfo = serviceInfo;
      _isServiceActive = serviceInfo?.busId != null &&
          serviceInfo!.busId!.isNotEmpty &&
          serviceInfo.tripStatus != null &&
          serviceInfo.tripStatus != 'inactive';

      if (_isServiceActive && serviceInfo?.busId != null) {
        if (initialLoad) await _startLiveTracking(studentId);
      } else {
        _clearBusLocation(clearSubscription: true);
      }
    } catch (e) {
      _isServiceActive = false;
      _serviceInfo = null;
      _clearBusLocation(clearSubscription: true);
    }
  }

  Future<void> _startLiveTracking(String studentId) async {
    await _fetchLiveLocation(studentId);
    if (_currentStudentId != studentId) return;

    final busId = await _mapService.getBusId(studentId);
    if (_currentStudentId != studentId) return;

    if (busId == null || busId.trim().isEmpty) {
      _clearBusLocation(clearSubscription: true);
      return;
    }

    if (_activeBusId == busId && _locationSubscription != null) return;

    _activeBusId = busId;
    _trackingStartedAt = DateTime.now();
    _cancelWsReconnect();
    await _locationSubscription?.cancel();
    final stream = _mapService.connectToBusLocationStream(busId);
    _locationSubscription = stream?.listen(
      (location) {
        _cancelWsReconnect(resetAttempt: true);
        _updateBusLocation(location);
      },
      onError: (error) {
        debugPrint('WebSocket error in MapViewModel: $error');
        _scheduleWsReconnect(studentId);
      },
      onDone: () {
        debugPrint('WebSocket connection closed');
        _scheduleWsReconnect(studentId);
      },
    );
  }

  void _updateBusLocation(LatLng location) {
    _busLocation = location;

    if (_currentStudentId != null &&
        _trackingStartedAt != null &&
        _firstLocationLoggedStudentId != _currentStudentId) {
      final durationMs =
          DateTime.now().difference(_trackingStartedAt!).inMilliseconds;
      _analyticsService.logEvent(
        'map_first_location_ms',
        parameters: <String, Object?>{
          'role': 'parent',
          'student_id': _currentStudentId,
          'duration_ms': durationMs,
        },
      );
      _firstLocationLoggedStudentId = _currentStudentId;
    }

    notifyListeners();
  }

  Future<void> _fetchLiveLocation(String studentId) async {
    try {
      final location = await _mapService.getLiveLocation(studentId);
      if (_currentStudentId != studentId) return;
      if (location != null) _updateBusLocation(location);
    } catch (e) {
      debugPrint('Error fetching live location: $e');
    }
  }

  void _startServiceStatusPolling() {
    _serviceStatusTimer?.cancel();
    _serviceStatusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _pollServiceStatus();
    });
  }

  void _cancelWsReconnect({bool resetAttempt = false}) {
    _wsReconnectTimer?.cancel();
    _wsReconnectTimer = null;
    if (resetAttempt) _wsReconnectAttempt = 0;
  }

  int _wsReconnectAttempt = 0;

  void _scheduleWsReconnect(String studentId) {
    if (_currentStudentId != studentId || !_isServiceActive) return;
    if (_activeBusId == null || _wsReconnectTimer != null) return;

    final delaySeconds = math.min(30, math.pow(2, _wsReconnectAttempt).toInt());
    _wsReconnectAttempt = math.min(_wsReconnectAttempt + 1, 6);

    _wsReconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      _wsReconnectTimer = null;
      if (_currentStudentId != studentId || !_isServiceActive) return;
      await _startLiveTracking(studentId);
    });
  }

  Future<void> _pollServiceStatus() async {
    if (_currentStudentId == null) return;
    final previousState = _isServiceActive;
    await _syncServiceState(initialLoad: false);
    if (previousState != _isServiceActive) notifyListeners();
  }

  void _onSelectedStudentChanged() {
    final newStudentId = _selectedStudentState.selectedStudent?.id;
    if (newStudentId == _currentStudentId) return;
    _switchStudent(newStudentId);
  }

  Future<void> _switchStudent(String? studentId) async {
    _currentStudentId = studentId;
    _isLoading = true;
    _isServiceActive = false;
    _serviceInfo = null;
    _clearBusLocation(clearSubscription: true);
    notifyListeners();

    if (studentId != null) {
      await _syncServiceState(initialLoad: true);
    }

    _isLoading = false;
    notifyListeners();
  }

  void _clearBusLocation({required bool clearSubscription}) {
    if (clearSubscription) {
      _cancelWsReconnect(resetAttempt: true);
      _locationSubscription?.cancel();
      _locationSubscription = null;
      _activeBusId = null;
    }
    _busLocation = null;
  }

  @override
  void dispose() {
    _selectedStudentState.removeListener(_onSelectedStudentChanged);
    _locationSubscription?.cancel();
    _serviceStatusTimer?.cancel();
    _wsReconnectTimer?.cancel();
    super.dispose();
  }
}
