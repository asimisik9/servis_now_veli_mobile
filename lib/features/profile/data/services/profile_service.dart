import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/network_manager.dart';
import '../../../home/data/models/home_status_model.dart';

class ProfileService {
  final Dio _dio;

  ProfileService({Dio? dio}) : _dio = dio ?? NetworkManager().dio;

  Future<List<Student>> fetchStudents() async {
    try {
      final response = await _dio.get('/parent/me/students');

      if (response.statusCode == 200) {
        return (response.data as List).map((e) => Student.fromJson(e)).toList();
      }
      throw Exception('Failed to load students');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> reportAbsence(String studentId) async {
    try {
      final response = await _dio.post('/parent/students/$studentId/absent');

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Student?> updateStudentAddress(String studentId, String newAddress) async {
    try {
      final response = await _dio.put(
        '/parent/students/$studentId/address',
        data: {'address': newAddress},
      );

      if (response.statusCode == 200) {
        return Student.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
