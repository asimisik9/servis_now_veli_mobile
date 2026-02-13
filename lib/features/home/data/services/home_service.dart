import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/network_manager.dart';
import '../models/home_status_model.dart';
import 'student_service.dart';

class HomeService {
  final Dio _dio;
  final NetworkManager _networkManager;
  final StudentService _studentService;

  HomeService({Dio? dio, NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager(),
        _dio = dio ?? (networkManager ?? NetworkManager()).dio,
        _studentService = StudentService(
          dio: dio ?? (networkManager ?? NetworkManager()).dio,
          networkManager: networkManager ?? NetworkManager(),
        );

  Future<List<Student>> fetchStudents() {
    return _studentService.fetchStudents();
  }

  Future<HomeStatusModel?> fetchStudentDashboard(String studentId) async {
    try {
      final response = await _dio.get(
        ApiConstants.parentStudentDashboardEndpoint(studentId),
      );

      if (response.statusCode == 200 && response.data is Map) {
        return HomeStatusModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw Exception('Özet bilgisi alınamadı.');
    } catch (e) {
      throw _networkManager.mapError(
        e,
        fallbackMessage: 'Özet bilgisi alınamadı.',
      );
    }
  }
}
