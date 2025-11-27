import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../home/data/models/home_status_model.dart';

class ProfileService {
  final Dio _dio;

  ProfileService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

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

  Future<bool> reportAbsence(String studentId) async {
    try {
      final token = TokenManager().accessToken;
      final response = await _dio.post(
        '/parent/students/$studentId/absent',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Student?> updateStudentAddress(String studentId, String newAddress) async {
    try {
      final token = TokenManager().accessToken;
      final response = await _dio.put(
        '/parent/students/$studentId/address',
        data: {'address': newAddress},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
