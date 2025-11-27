import 'package:flutter/material.dart';
import '../../home/data/models/home_status_model.dart';
import '../data/services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService;

  ProfileViewModel({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Student? _currentStudent;
  Student? get currentStudent => _currentStudent;

  bool _isAbsent = false;
  bool get isAbsent => _isAbsent;

  void init() {
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final students = await _profileService.fetchStudents();
      if (students.isNotEmpty) {
        _currentStudent = students.first;
      }
    } catch (e) {
      debugPrint("Error fetching profile data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleAbsence(bool value) async {
    if (_currentStudent == null) return false;

    // If user wants to mark as absent (value is false because switch is "Going")
    // Wait, let's clarify the switch logic.
    // Switch ON = Gidiyor (Going) -> isAbsent = false
    // Switch OFF = Gelmeyecek (Not Coming) -> isAbsent = true
    
    if (!value) { // User turned switch OFF (Not coming)
      _isLoading = true;
      notifyListeners();
      
      try {
        final success = await _profileService.reportAbsence(_currentStudent!.id);
        if (success) {
          _isAbsent = true;
        }
        return success;
      } catch (e) {
        debugPrint("Error reporting absence: $e");
        return false;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      // User turned switch ON (Going)
      // Currently no endpoint to cancel absence, so just update local state
      _isAbsent = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateAddress(String newAddress) async {
    if (_currentStudent == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedStudent = await _profileService.updateStudentAddress(
        _currentStudent!.id,
        newAddress,
      );

      if (updatedStudent != null) {
        _currentStudent = updatedStudent;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error updating address: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
