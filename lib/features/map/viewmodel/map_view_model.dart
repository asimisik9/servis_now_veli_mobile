import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  LatLng? _busLocation;
  LatLng? get busLocation => _busLocation;

  final Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  List<Student> get students => _selectedStudentState.students;
  bool get hasMultipleStudents => _selectedStudentState.hasMultipleStudents;
  String? get selectedStudentId => _selectedStudentState.selectedStudent?.id;

  Timer? _serviceStatusTimer;
  StreamSubscription<LatLng>? _locationSubscription;

  String? _currentStudentId;
  String? _activeBusId;
  DateTime? _trackingStartedAt;
  String? _firstLocationLoggedStudentId;

  void init() {
    _initializeData();
    _startServiceStatusPolling();
  }

  void selectStudent(String studentId) {
    _selectedStudentState.selectStudentById(studentId);
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _selectedStudentState.loadStudents();
      _currentStudentId = _selectedStudentState.selectedStudent?.id;
      await _syncServiceState(initialLoad: true);
    } catch (e) {
      debugPrint('Error initializing map data: $e');
      _isServiceActive = false;
      _clearBusLocation(clearSubscription: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLocation() async {
    if (_currentStudentId == null) {
      return;
    }
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
    if (studentId == null) {
      _isServiceActive = false;
      _clearBusLocation(clearSubscription: true);
      return;
    }

    try {
      final active = await _mapService.checkServiceStatus(studentId);
      if (_currentStudentId != studentId) {
        return;
      }

      final stateChanged = active != _isServiceActive;
      _isServiceActive = active;

      if (!active) {
        _clearBusLocation(clearSubscription: true);
        return;
      }

      if (stateChanged || initialLoad) {
        await _startLiveTracking(studentId);
      } else if (_busLocation == null) {
        await _fetchLiveLocation(studentId);
      }
    } catch (e) {
      debugPrint('Error checking service status: $e');
      _isServiceActive = false;
      _clearBusLocation(clearSubscription: true);
    }
  }

  Future<void> _startLiveTracking(String studentId) async {
    await _fetchLiveLocation(studentId);
    if (_currentStudentId != studentId) {
      return;
    }

    final busId = await _mapService.getBusId(studentId);
    if (_currentStudentId != studentId) {
      return;
    }

    if (busId == null || busId.trim().isEmpty) {
      _clearBusLocation(clearSubscription: true);
      return;
    }

    if (_activeBusId == busId && _locationSubscription != null) {
      return;
    }

    _activeBusId = busId;
    _trackingStartedAt = DateTime.now();
    await _locationSubscription?.cancel();
    final stream = _mapService.connectToBusLocationStream(busId);
    _locationSubscription = stream?.listen(
      (location) {
        _updateBusLocation(location);
      },
      onError: (error) {
        debugPrint('WebSocket error in MapViewModel: $error');
      },
      onDone: () {
        debugPrint('WebSocket connection closed');
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

    _markers.removeWhere((m) => m.markerId.value == 'bus');
    _markers.add(
      Marker(
        markerId: const MarkerId('bus'),
        position: location,
        infoWindow: const InfoWindow(title: 'Servis'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );

    notifyListeners();
  }

  Future<void> _fetchLiveLocation(String studentId) async {
    try {
      final location = await _mapService.getLiveLocation(studentId);
      if (_currentStudentId != studentId) {
        return;
      }
      if (location != null) {
        _updateBusLocation(location);
      }
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

  Future<void> _pollServiceStatus() async {
    if (_currentStudentId == null) {
      return;
    }

    final previousState = _isServiceActive;
    await _syncServiceState(initialLoad: false);

    if (previousState != _isServiceActive) {
      notifyListeners();
    }
  }

  void _onSelectedStudentChanged() {
    final newStudentId = _selectedStudentState.selectedStudent?.id;
    if (newStudentId == _currentStudentId) {
      return;
    }

    _switchStudent(newStudentId);
  }

  Future<void> _switchStudent(String? studentId) async {
    _currentStudentId = studentId;
    _isLoading = true;
    _isServiceActive = false;
    _trackingStartedAt = null;
    _firstLocationLoggedStudentId = null;
    _clearBusLocation(clearSubscription: true);
    notifyListeners();

    try {
      await _syncServiceState(initialLoad: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearBusLocation({required bool clearSubscription}) {
    if (clearSubscription) {
      _locationSubscription?.cancel();
      _locationSubscription = null;
      _activeBusId = null;
    }

    _busLocation = null;
    _markers.removeWhere((marker) => marker.markerId.value == 'bus');
  }

  @override
  void dispose() {
    _selectedStudentState.removeListener(_onSelectedStudentChanged);
    _locationSubscription?.cancel();
    _serviceStatusTimer?.cancel();
    super.dispose();
  }
}
