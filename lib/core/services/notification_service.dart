import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/api_constants.dart';
import '../network/network_manager.dart';
import '../utils/token_manager.dart';

/// Background message handler — must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔔 Background notification: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'servis_now_notifications',
    'Servis Now Bildirimleri',
    description: 'Servis takip bildirimleri',
    importance: Importance.high,
    playSound: true,
  );

  /// Initialize notification service — call once in main()
  Future<void> init() async {
    if (_initialized) return;

    // Request permissions (iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('🔔 Notification permission denied');
      return;
    }

    // Setup local notifications
    await _setupLocalNotifications();

    // Listen foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen notification taps (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification (terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    _initialized = true;
    debugPrint('🔔 NotificationService initialized');
  }

  /// Setup flutter_local_notifications for foreground display
  Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap from local notification
        if (response.payload != null) {
          _handleLocalNotificationTap(response.payload!);
        }
      },
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// Get FCM token and register with backend
  Future<String?> getAndRegisterToken() async {
    try {
      // iOS: Get APNs token first
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('🔔 APNs token not available yet');
          return null;
        }
      }

      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('🔔 FCM Token: ${token.substring(0, 20)}...');
        await _registerTokenWithBackend(token);
      }
      return token;
    } catch (e) {
      debugPrint('🔔 FCM Token error: $e');
      return null;
    }
  }

  /// Register FCM token with backend API
  Future<void> _registerTokenWithBackend(String fcmToken) async {
    try {
      // Only register if user is logged in
      if (TokenManager().accessToken == null) return;

      await NetworkManager().dio.post(
        ApiConstants.notificationFcmTokenEndpoint,
        data: {'fcm_token': fcmToken},
      );
      debugPrint('🔔 FCM token registered with backend');
    } catch (e) {
      debugPrint('🔔 Failed to register FCM token: $e');
    }
  }

  /// Remove FCM token from backend (call on logout)
  Future<void> removeToken() async {
    try {
      await NetworkManager()
          .dio
          .delete(ApiConstants.notificationFcmTokenEndpoint);
      await _messaging.deleteToken();
      debugPrint('🔔 FCM token removed');
    } catch (e) {
      debugPrint('🔔 Failed to remove FCM token: $e');
    }
  }

  /// Handle foreground notification — show local notification
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 Foreground notification: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap when app is in background
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('🔔 Notification tapped: ${message.data}');
    // TODO: Navigate to specific screen based on notification_type
    // final type = message.data['notification_type'];
    // final studentId = message.data['student_id'];
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(String payload) {
    debugPrint('🔔 Local notification tapped: $payload');
    // TODO: Navigate to specific screen based on notification data
    // final data = jsonDecode(payload) as Map<String, dynamic>;
    // final type = data['notification_type'];
  }

  /// Token refresh callback
  void _onTokenRefresh(String token) {
    debugPrint('🔔 FCM token refreshed');
    _registerTokenWithBackend(token);
  }
}
