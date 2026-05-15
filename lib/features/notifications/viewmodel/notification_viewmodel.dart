import 'package:flutter/foundation.dart';
import '../data/notification_model.dart';
import '../data/notification_repository.dart';

enum NotificationCategory { all, servis, guvenlik, okul }

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

  List<NotificationModel> get filteredNotifications {
    switch (_selectedCategory) {
      case NotificationCategory.all:
        return _notifications;
      case NotificationCategory.servis:
        return _notifications
            .where((n) =>
                n.notificationType == 'eve_varis_eta' ||
                n.notificationType == 'evden_alim_eta')
            .toList();
      case NotificationCategory.guvenlik:
        return _notifications
            .where((n) => n.notificationType == 'eve_birakildi')
            .toList();
      case NotificationCategory.okul:
        return _notifications
            .where((n) => n.notificationType == 'okula_varis')
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
        title: 'Servis 5 dakika uzakta',
        message: 'Ali\'nin servisi evinize yaklaşıyor. Hazır olun!',
        notificationType: 'eve_varis_eta',
        createdAt: now.subtract(const Duration(minutes: 4)),
      ),
      NotificationModel(
        id: 'm2', recipientId: 'mock', status: 'sent', isRead: false,
        title: 'Okula güvenle ulaştı',
        message: 'Ali bugün saat 08:12\'de okula ulaştı.',
        notificationType: 'okula_varis',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'm3', recipientId: 'mock', status: 'sent', isRead: false,
        title: 'Eve bırakıldı',
        message: 'Ali saat 16:45\'te evinize güvenle bırakıldı.',
        notificationType: 'eve_birakildi',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'm4', recipientId: 'mock', status: 'sent', isRead: true,
        title: 'Servis yola çıktı',
        message: 'Sabah servisi güzergaha çıktı, tahmini varış 07:50.',
        notificationType: 'evden_alim_eta',
        createdAt: now.subtract(const Duration(hours: 7)),
      ),
      NotificationModel(
        id: 'm5', recipientId: 'mock', status: 'sent', isRead: true,
        title: 'Okula güvenle ulaştı',
        message: 'Ali dün saat 08:09\'da okula ulaştı.',
        notificationType: 'okula_varis',
        createdAt: now.subtract(const Duration(days: 1, hours: 8)),
      ),
      NotificationModel(
        id: 'm6', recipientId: 'mock', status: 'sent', isRead: true,
        title: 'Eve bırakıldı',
        message: 'Ali dün saat 17:02\'de evinize güvenle bırakıldı.',
        notificationType: 'eve_birakildi',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      NotificationModel(
        id: 'm7', recipientId: 'mock', status: 'sent', isRead: true,
        title: 'Servis 10 dakika uzakta',
        message: 'Öğleden sonra servisi evinize yaklaşıyor.',
        notificationType: 'eve_varis_eta',
        createdAt: now.subtract(const Duration(days: 2)),
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
