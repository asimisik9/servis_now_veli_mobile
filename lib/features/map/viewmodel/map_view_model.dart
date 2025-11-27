import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/services/map_service.dart';

class MapViewModel extends ChangeNotifier {
  final MapService _mapService;
  
  MapViewModel({MapService? mapService}) : _mapService = mapService ?? MapService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isServiceActive = false;
  bool get isServiceActive => _isServiceActive;

  LatLng? _busLocation;
  LatLng? get busLocation => _busLocation;

  final Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  Timer? _timer;

  // Static locations for Home and School
  final LatLng _homeLocation = const LatLng(41.015137, 28.979530);
  final LatLng _schoolLocation = const LatLng(41.025137, 28.989530);

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
      _isServiceActive = await _mapService.checkServiceStatus(_currentStudentId!);
      if (_isServiceActive) {
        _setupStaticMarkers();
        _startLiveTracking();
      }
    } catch (e) {
      debugPrint("Error checking service status: $e");
      _isServiceActive = false;
    }
  }

  void _setupStaticMarkers() {
    _markers.add(
      Marker(
        markerId: const MarkerId('home'),
        position: _homeLocation,
        infoWindow: const InfoWindow(title: 'Ev'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('school'),
        position: _schoolLocation,
        infoWindow: const InfoWindow(title: 'Okul'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  void _startLiveTracking() {
    _timer?.cancel();
    _fetchLiveLocation(); // Fetch immediately
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchLiveLocation();
    });
  }

  Future<void> _fetchLiveLocation() async {
    if (_currentStudentId == null) return;

    try {
      final location = await _mapService.getLiveLocation(_currentStudentId!);
      if (location != null) {
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
    } catch (e) {
      debugPrint("Error fetching live location: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
