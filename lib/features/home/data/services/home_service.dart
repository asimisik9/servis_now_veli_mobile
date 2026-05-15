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

  Future<void> markAbsent(
    String studentId, {
    List<String>? serviceTypes,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (serviceTypes != null && serviceTypes.isNotEmpty) {
        data['service_types'] = serviceTypes;
      }
      if (note != null && note.isNotEmpty) {
        data['note'] = note;
      }
      await _dio.post(
        ApiConstants.parentStudentAbsenceEndpoint(studentId),
        data: data.isEmpty ? null : data,
      );
    } catch (e) {
      throw _networkManager.mapError(
        e,
        fallbackMessage: 'Devamsızlık bildirimi gönderilemedi.',
      );
    }
  }

  Future<bool> getAbsenceStatus(String studentId) async {
    try {
      final response = await _dio.get(
        ApiConstants.parentStudentAbsenceStatusEndpoint(studentId),
      );
      if (response.statusCode == 200 && response.data is Map) {
        return (response.data as Map)['is_absent'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateAddress(
    String studentId,
    String address, {
    DateTime? startDate,
    DateTime? endDate,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final data = <String, dynamic>{'address': address};
      if (startDate != null) {
        data['start_date'] = _formatIsoDate(startDate);
      }
      if (endDate != null) {
        data['end_date'] = _formatIsoDate(endDate);
      }
      if (note != null && note.isNotEmpty) {
        data['note'] = note;
      }
      if (latitude != null) {
        data['latitude'] = latitude;
      }
      if (longitude != null) {
        data['longitude'] = longitude;
      }
      await _dio.patch(
        ApiConstants.parentStudentAddressEndpoint(studentId),
        data: data,
      );
    } catch (e) {
      throw _networkManager.mapError(
        e,
        fallbackMessage: 'Adres güncellenemedi.',
      );
    }
  }

  static String _formatIsoDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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
