import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/network_manager.dart';
import '../models/home_status_model.dart';

class StudentService {
  final Dio _dio;
  final NetworkManager _networkManager;

  StudentService({Dio? dio, NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager(),
        _dio = dio ?? (networkManager ?? NetworkManager()).dio;

  Future<List<Student>> fetchStudents() async {
    try {
      final response = await _dio.get(ApiConstants.parentStudentsEndpoint);

      if (response.statusCode == 200 && response.data is List) {
        final rawList = response.data as List;
        return rawList
            .whereType<Map>()
            .map((e) => Student.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw Exception('Öğrenci listesi alınamadı.');
    } catch (e) {
      throw _networkManager.mapError(
        e,
        fallbackMessage: 'Öğrenci listesi alınamadı.',
      );
    }
  }
}
