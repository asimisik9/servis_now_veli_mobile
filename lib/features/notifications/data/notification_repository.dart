import '../../../core/constants/api_constants.dart';
import '../../../core/network/network_manager.dart';

class NotificationRepository {
  final _networkManager = NetworkManager();

  get _dio => _networkManager.dio;

  /// Bildirimleri listele
  Future<List<Map<String, dynamic>>> getNotifications({
    int skip = 0,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.notificationsEndpoint,
        queryParameters: {
          'skip': skip,
          'limit': limit,
          'unread_only': unreadOnly,
        },
      );
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (e) {
      throw _networkManager.mapError(
        e,
        fallbackMessage: 'Bildirimler alınamadı.',
      );
    }
  }

  /// Okunmamış bildirim sayısı
  Future<int> getUnreadCount() async {
    try {
      final response =
          await _dio.get(ApiConstants.notificationsUnreadCountEndpoint);
      return (response.data['unread_count'] as num).toInt();
    } catch (e) {
      throw _networkManager.mapError(
        e,
        fallbackMessage: 'Okunmamış bildirim sayısı alınamadı.',
      );
    }
  }

  /// Bildirimi okundu işaretle
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.put(ApiConstants.notificationReadEndpoint(notificationId));
    } catch (e) {
      throw _networkManager.mapError(
        e,
        fallbackMessage: 'Bildirim okundu olarak işaretlenemedi.',
      );
    }
  }

  /// Tümünü okundu işaretle
  Future<void> markAllAsRead() async {
    try {
      await _dio.put(ApiConstants.notificationsReadAllEndpoint);
    } catch (e) {
      throw _networkManager.mapError(
        e,
        fallbackMessage: 'Tüm bildirimler güncellenemedi.',
      );
    }
  }
}
