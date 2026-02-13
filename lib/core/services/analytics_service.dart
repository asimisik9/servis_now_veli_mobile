import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._internal();

  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  void logEvent(String name, {Map<String, Object?>? parameters}) {
    debugPrint('[analytics] $name ${parameters ?? const {}}');
  }
}
