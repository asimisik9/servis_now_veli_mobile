import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../core/network/network_manager.dart';
import '../../../home/data/models/home_status_model.dart';

class MapService {
  final Dio _dio;

  MapService({Dio? dio}) : _dio = dio ?? NetworkManager().dio;

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

  Future<bool> checkServiceStatus(String studentId) async {
    try {
      final response = await _dio.get('/parent/students/$studentId/dashboard');

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

  Future<String?> getBusId(String studentId) async {
    try {
      // Use dashboard endpoint to get busId even if no location history exists
      final response = await _dio.get('/parent/students/$studentId/dashboard');

      if (response.statusCode == 200 && response.data != null) {
        return response.data['busId'];
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
      final baseUri = Uri.parse(ApiConstants.baseUrl);
      final wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
      
      // Backend WS endpoint: /ws/bus/{busId}/location
      // ApiConstants.baseUrl genellikle /api ile biter, bunu eziyoruz.
      final wsUri = baseUri.replace(
        scheme: wsScheme,
        path: '/ws/bus/$busId/location',
        queryParameters: {'token': token},
      );
      
      debugPrint("Connecting to WS: $wsUri");
      final channel = WebSocketChannel.connect(wsUri);
      
      return channel.stream.map((event) {
        debugPrint("WS Received: $event");
        final data = jsonDecode(event);
        return LatLng(data['latitude'], data['longitude']);
      }).handleError((error) {
        debugPrint("WS Error: $error");
        throw error;
      });
    } catch (e) {
      debugPrint("Error creating WS connection: $e");
      return null;
    }
  }

  Future<LatLng?> getLiveLocation(String studentId) async {
    try {
      final response = await _dio.get('/parent/students/$studentId/bus/location');

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
