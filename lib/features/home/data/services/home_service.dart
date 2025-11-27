import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/home_status_model.dart';

class HomeService {
  final Dio _dio;

  HomeService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<List<Student>> fetchStudents() async {
    try {
      final token = TokenManager().accessToken;
      final response = await _dio.get(
        '/parent/me/students',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

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
      final token = TokenManager().accessToken;
      final response = await _dio.get(
        '/parent/students/$studentId/dashboard',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return HomeStatusModel.fromJson(response.data);
      }
      throw Exception('Failed to load dashboard');
    } catch (e) {
      rethrow;
    }
  }
}
