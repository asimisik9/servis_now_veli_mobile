import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _baseUrlFromDefine = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const bool _hasApiBaseUrlDefine = bool.hasEnvironment('API_BASE_URL');

  static void ensureBuildConfig() {
    final fromDefine = _normalizeUrl(_baseUrlFromDefine);
    if (kReleaseMode && (!_hasApiBaseUrlDefine || fromDefine == null)) {
      throw StateError(
        'Release build requires --dart-define=API_BASE_URL=<https://api.example.com>',
      );
    }
  }

  static String get baseUrl {
    ensureBuildConfig();
    final fromDefine = _normalizeUrl(_baseUrlFromDefine);
    if (fromDefine != null) {
      return fromDefine;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static String get wsBaseUrl {
    if (baseUrl.startsWith('https://')) {
      return baseUrl.replaceFirst('https://', 'wss://');
    }
    if (baseUrl.startsWith('http://')) {
      return baseUrl.replaceFirst('http://', 'ws://');
    }
    return baseUrl;
  }

  static const String authLoginEndpoint = '/api/auth/login';
  static const String authRefreshEndpoint = '/api/auth/refresh';
  static const String authLogoutEndpoint = '/api/auth/logout';
  static const String authMeEndpoint = '/api/auth/me';

  static const String parentStudentsEndpoint = '/api/parent/me/students';
  static String parentStudentDashboardEndpoint(String studentId) =>
      '/api/parent/students/$studentId/dashboard';
  static String parentStudentBusLocationEndpoint(String studentId) =>
      '/api/parent/students/$studentId/bus/location';
  static String parentStudentAddressEndpoint(String studentId) =>
      '/api/parent/students/$studentId/address';
  static String parentStudentAbsenceEndpoint(String studentId) =>
      '/api/parent/students/$studentId/absent';
  static String parentStudentAbsenceStatusEndpoint(String studentId) =>
      '/api/parent/students/$studentId/absence/status';
  static String parentStudentAttendanceHistoryEndpoint(String studentId) =>
      '/api/parent/students/$studentId/attendance/history';

  static const String notificationsEndpoint = '/api/notifications/';
  static const String notificationsUnreadCountEndpoint =
      '/api/notifications/unread-count';
  static String notificationReadEndpoint(String notificationId) =>
      '/api/notifications/$notificationId/read';
  static const String notificationsReadAllEndpoint =
      '/api/notifications/read-all';
  static const String notificationFcmTokenEndpoint =
      '/api/notifications/fcm-token';

  static String busLocationWsEndpoint(String busId) =>
      '/ws/bus/$busId/location';

  static String? _normalizeUrl(String value) {
    var trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('/api')) {
      trimmed = trimmed.substring(0, trimmed.length - 4);
    }
    return trimmed;
  }
}
