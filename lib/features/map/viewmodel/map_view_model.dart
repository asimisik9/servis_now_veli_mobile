import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/services/map_service.dart';

class MapViewModel extends ChangeNotifier {
  final MapService _mapService;

  MapViewModel({MapService? mapService})
      : _mapService = mapService ?? MapService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isServiceActive = false;
  bool get isServiceActive => _isServiceActive;

  LatLng? _busLocation;
  LatLng? get busLocation => _busLocation;

  final Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  Timer? _timer;
  StreamSubscription<LatLng>? _locationSubscription;

  // Static locations removed

  String? _currentStudentId;

  void init() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Students to get ID
      final students = await _mapService.fetchStudents();
      if (students.isNotEmpty) {
        _currentStudentId = students.first.id;
        // 2. Check Service Status
        await _checkServiceStatus();
      } else {
        _isServiceActive = false;
      }
    } catch (e) {
      debugPrint("Error initializing map data: $e");
      _isServiceActive = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkServiceStatus() async {
    if (_currentStudentId == null) return;

    try {
      // Check real service status from backend
      _isServiceActive =
          await _mapService.checkServiceStatus(_currentStudentId!);

      if (_isServiceActive) {
        await _startLiveTracking();
      }
    } catch (e) {
      debugPrint("Error checking service status: $e");
      _isServiceActive = false;
    }
  }

  // _setupStaticMarkers removed

  Future<void> _startLiveTracking() async {
    if (_currentStudentId == null) return;

    // Initial fetch
    await _fetchLiveLocation();

    // Get Bus ID for WebSocket
    final busId = await _mapService.getBusId(_currentStudentId!);
    if (busId != null) {
      debugPrint("Subscribing to Bus Location: $busId");
      final stream = _mapService.connectToBusLocationStream(busId);
      await _locationSubscription?.cancel();
      _locationSubscription = stream?.listen((location) {
        debugPrint("New Location Received: $location");
        _updateBusLocation(location);
      }, onError: (error) {
        debugPrint("WebSocket error in ViewModel: $error");
      }, onDone: () {
        debugPrint("WebSocket connection closed");
      });
    }
  }

  void _updateBusLocation(LatLng location) {
    _busLocation = location;

    // Update bus marker
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

  Future<void> refreshLocation() async {
    _isLoading = true;
    notifyListeners();
    await _fetchLiveLocation();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchLiveLocation() async {
    if (_currentStudentId == null) return;

    try {
      final location = await _mapService.getLiveLocation(_currentStudentId!);
      if (location != null) {
        _updateBusLocation(location);
      }
    } catch (e) {
      debugPrint("Error fetching live location: $e");
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
