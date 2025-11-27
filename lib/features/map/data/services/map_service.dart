import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../home/data/models/home_status_model.dart';

class MapService {
  final Dio _dio;

  MapService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

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

  Future<bool> checkServiceStatus(String studentId) async {
    try {
      final token = TokenManager().accessToken;
      final response = await _dio.get(
        '/parent/students/$studentId/dashboard',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final status = response.data['tripStatus'];
        return status == 'to_school' || status == 'to_home';
      }
      return false;
    } catch (e) {
      // If error, assume inactive or handle gracefully
      return false;
    }
  }

  Future<LatLng?> getLiveLocation(String studentId) async {
    try {
      final token = TokenManager().accessToken;
      final response = await _dio.get(
        '/parent/students/$studentId/bus/location',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final lat = response.data['latitude'];
        final lng = response.data['longitude'];
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
