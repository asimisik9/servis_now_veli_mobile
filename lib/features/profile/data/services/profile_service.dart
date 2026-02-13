import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/network_manager.dart';
import '../../../home/data/models/home_status_model.dart';
import '../../../home/data/services/student_service.dart';

class ProfileService {
  final Dio _dio;
  final NetworkManager _networkManager;
  final StudentService _studentService;

  ProfileService({Dio? dio, NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager(),
        _dio = dio ?? (networkManager ?? NetworkManager()).dio,
        _studentService = StudentService(
          dio: dio ?? (networkManager ?? NetworkManager()).dio,
          networkManager: networkManager ?? NetworkManager(),
        );

  Future<List<Student>> fetchStudents() {
    return _studentService.fetchStudents();
  }

  Future<bool> reportAbsence(String studentId) async {
    try {
      final response = await _dio.post(
        ApiConstants.parentStudentAbsenceEndpoint(studentId),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw _networkManager.mapError(
        e,
        fallbackMessage: 'Yoklama bildirimi gönderilemedi.',
      );
    }
  }

  Future<Student?> updateStudentAddress(
      String studentId, String newAddress) async {
    try {
      final response = await _dio.put(
        ApiConstants.parentStudentAddressEndpoint(studentId),
        data: {'address': newAddress},
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Student.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
      return null;
    } catch (e) {
      throw _networkManager.mapError(
        e,
        fallbackMessage: 'Adres güncellenemedi.',
      );
    }
  }
}
