import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/network_manager.dart';
import '../models/home_status_model.dart';

class HomeService {
  final Dio _dio;

  HomeService({Dio? dio}) : _dio = dio ?? NetworkManager().dio;

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

  Future<HomeStatusModel?> fetchStudentDashboard(String studentId) async {
    try {
      final response = await _dio.get('/parent/students/$studentId/dashboard');

      if (response.statusCode == 200 && response.data != null) {
        return HomeStatusModel.fromJson(response.data);
      }
      throw Exception('Failed to load dashboard');
    } catch (e) {
      rethrow;
    }
  }
}
