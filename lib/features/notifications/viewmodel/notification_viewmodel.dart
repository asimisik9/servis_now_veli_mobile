import 'package:flutter/foundation.dart';
import '../data/notification_model.dart';
import '../data/notification_repository.dart';

enum NotificationCategory { all, servis, okul, gecikme }

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationViewModel({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  NotificationCategory _selectedCategory = NotificationCategory.all;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  NotificationCategory get selectedCategory => _selectedCategory;

  static const _servisTypes = {
    'sabah_servis_geliyor',
    'evden_alindi',
    'okuldan_bindi',
    'eve_servis_geliyor',
    'eve_birakildi',
    // eski tipler
    'eve_varis_eta',
    'evden_alim_eta',
  };

  static const _okulTypes = {
    'okula_varildi',
    'okula_varis',
  };

  static const _gecikmeTypes = {
    'gecikme',
  };

  List<NotificationModel> get filteredNotifications {
    switch (_selectedCategory) {
      case NotificationCategory.all:
        return _notifications;
      case NotificationCategory.servis:
        return _notifications
            .where((n) => _servisTypes.contains(n.notificationType))
            .toList();
      case NotificationCategory.okul:
        return _notifications
            .where((n) => _okulTypes.contains(n.notificationType))
            .toList();
      case NotificationCategory.gecikme:
        return _notifications
            .where((n) => _gecikmeTypes.contains(n.notificationType))
            .toList();
    }
  }

  void setCategory(NotificationCategory category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

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
        // TODO: remove mock fallback when backend returns real data
        _notifications = newNotifications.isEmpty
            ? _mockNotifications()
            : newNotifications;
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      } else {
        _notifications.addAll(newNotifications);
        if (_unreadCount == 0) {
          _unreadCount = _notifications.where((n) => !n.isRead).length;
        }
      }
    } catch (e) {
      debugPrint('Notification load error: $e');
      // TODO: remove mock fallback when backend is connected
      if (refresh && _notifications.isEmpty) {
        _notifications = _mockNotifications();
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Unread count error: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    _unreadCount = (_unreadCount - 1).clamp(0, 999);
    notifyListeners();

    try {
      await _repository.markAsRead(notificationId);
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  List<NotificationModel> _mockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'm1', recipientId: 'mock', status: 'sent', isRead: false,
        title: 'Servis 5 dk sonra kapınızda',
        message: 'Sabah servisi evinize yaklaşıyor. Hazır olun!',
        notificationType: 'sabah_servis_geliyor',
        createdAt: now.subtract(const Duration(minutes: 3)),
      ),
      NotificationModel(
        id: 'm2', recipientId: 'mock', status: 'sent', isRead: false,
        title: 'Eve geldi, çocuk bindi',
        message: 'Servis evinize geldi. Ali servise güvenle bindi.',
        notificationType: 'evden_alindi',
        createdAt: now.subtract(const Duration(minutes: 20)),
      ),
      NotificationModel(
        id: 'm3', recipientId: 'mock', status: 'sent', isRead: false,
        title: 'Okula vardı',
        message: 'Ali bugün saat 08:15\'te okula güvenle ulaştı.',
        notificationType: 'okula_varildi',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'm4', recipientId: 'mock', status: 'sent', isRead: true,
        title: 'Okuldan servise bindi',
        message: 'Ali okuldan servise bindi. Dönüş yolculuğu başladı.',
        notificationType: 'okuldan_bindi',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'm5', recipientId: 'mock', status: 'sent', isRead: true,
        title: 'Servis 5 dk sonra kapınızda',
        message: 'Akşam servisi evinize yaklaşıyor.',
        notificationType: 'eve_servis_geliyor',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      NotificationModel(
        id: 'm6', recipientId: 'mock', status: 'sent', isRead: true,
        title: 'Servisten indi',
        message: 'Ali saat 16:48\'de servisten güvenle indi.',
        notificationType: 'eve_birakildi',
        createdAt: now.subtract(const Duration(hours: 6, minutes: 30)),
      ),
      NotificationModel(
        id: 'm7', recipientId: 'mock', status: 'sent', isRead: true,
        title: 'Gecikme bildirimi',
        message: 'Dün sabah servisi yaklaşık 10 dakika gecikmeli kaldı.',
        notificationType: 'gecikme',
        createdAt: now.subtract(const Duration(days: 1, hours: 7)),
      ),
    ];
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _repository.markAllAsRead();
    } catch (e) {
      debugPrint('Mark all as read error: $e');
    }
  }
}
