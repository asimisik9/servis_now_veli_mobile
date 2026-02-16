import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../core/network/network_manager.dart';
import '../../../home/data/models/home_status_model.dart';
import '../../../home/data/services/student_service.dart';

class MapService {
  final Dio _dio;
  final StudentService _studentService;

  MapService({Dio? dio, NetworkManager? networkManager})
      : _dio = dio ?? (networkManager ?? NetworkManager()).dio,
        _studentService = StudentService(
          dio: dio ?? (networkManager ?? NetworkManager()).dio,
          networkManager: networkManager ?? NetworkManager(),
        );

  Future<List<Student>> fetchStudents() {
    return _studentService.fetchStudents();
  }

  Future<bool> checkServiceStatus(String studentId) async {
    try {
      final response = await _dio.get(
        ApiConstants.parentStudentDashboardEndpoint(studentId),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final status = (response.data as Map)['tripStatus'];
        return status == 'to_school' || status == 'to_home';
      }
      return false;
    } catch (e) {
      // If error, assume inactive or handle gracefully
      return false;
    }
  }

  Future<String?> getBusId(String studentId) async {
    try {
      // Use dashboard endpoint to get busId even if no location history exists
      final response = await _dio.get(
        ApiConstants.parentStudentDashboardEndpoint(studentId),
      );

      if (response.statusCode == 200 && response.data is Map) {
        return (response.data as Map)['busId']?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<LatLng>? connectToBusLocationStream(String busId) {
    final token = TokenManager().accessToken;
    if (token == null) return null;

    try {
      final wsUri = Uri.parse(
        '${ApiConstants.wsBaseUrl}${ApiConstants.busLocationWsEndpoint(busId)}',
      ).replace(
        queryParameters: {'token': token},
      );

      debugPrint("Connecting to WS: $wsUri");
      final channel = WebSocketChannel.connect(wsUri);
      return Stream<LatLng>.multi((controller) {
        final subscription = channel.stream.listen(
          (event) {
            final data = jsonDecode(event);
            if (data is! Map) {
              controller.addError(
                const FormatException('WS payload is not a JSON object'),
              );
              return;
            }
            final map = Map<String, dynamic>.from(data);
            final latRaw = map['latitude'];
            final lngRaw = map['longitude'];
            if (latRaw is! num || lngRaw is! num) {
              controller.addError(
                const FormatException('WS payload missing numeric coordinates'),
              );
              return;
            }
            controller.add(LatLng(latRaw.toDouble(), lngRaw.toDouble()));
          },
          onError: (error) {
            debugPrint("WS Error: $error");
            controller.addError(error);
          },
          onDone: controller.close,
          cancelOnError: true,
        );

        controller.onCancel = () async {
          await subscription.cancel();
          await channel.sink.close();
        };
      });
    } catch (e) {
      debugPrint("Error creating WS connection: $e");
      return null;
    }
  }

  Future<LatLng?> getLiveLocation(String studentId) async {
    try {
      final response = await _dio.get(
        ApiConstants.parentStudentBusLocationEndpoint(studentId),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final latRaw = map['latitude'];
        final lngRaw = map['longitude'];
        if (latRaw is num && lngRaw is num) {
          return LatLng(latRaw.toDouble(), lngRaw.toDouble());
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
