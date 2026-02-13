import 'package:flutter/foundation.dart';
import '../data/notification_model.dart';
import '../data/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Bildirimleri yükle
  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getNotifications(
        skip: refresh ? 0 : _notifications.length,
        limit: 20,
      );
      final newNotifications =
          data.map((json) => NotificationModel.fromJson(json)).toList();

      if (refresh) {
        _notifications = newNotifications;
      } else {
        _notifications.addAll(newNotifications);
      }
    } catch (e) {
      _error = 'Bildirimler yüklenemedi';
      debugPrint('Notification load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Okunmamış sayısını güncelle
  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Unread count error: $e');
    }
  }

  /// Bildirimi okundu işaretle
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = (_unreadCount - 1).clamp(0, 999);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  /// Tümünü okundu işaretle
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Mark all as read error: $e');
    }
  }
}
