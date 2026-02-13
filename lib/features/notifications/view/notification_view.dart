import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/state/selected_student_state.dart';
import '../../main_wrapper/viewmodel/main_wrapper_view_model.dart';
import '../viewmodel/notification_viewmodel.dart';
import '../data/notification_model.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().loadNotifications(refresh: true);
      context.read<NotificationViewModel>().fetchUnreadCount();
    });
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    final notificationViewModel = context.read<NotificationViewModel>();
    if (!notification.isRead) {
      await notificationViewModel.markAsRead(notification.id);
      if (!mounted) {
        return;
      }
    }

    final studentId = notification.studentId?.trim();
    if (studentId != null && studentId.isNotEmpty) {
      final selectedStudentState = context.read<SelectedStudentState>();
      await selectedStudentState.loadStudents();
      if (!mounted) {
        return;
      }
      selectedStudentState.selectStudentById(studentId);
    }

    if (!mounted) {
      return;
    }

    final targetTab = notification.targetTab ?? _defaultTargetTab(notification);
    AnalyticsService().logEvent(
      'notification_opened',
      parameters: <String, Object?>{
        'notification_type': notification.notificationType,
        'target_tab': targetTab,
        'student_id': notification.studentId ?? '',
        'event_id': notification.eventId ?? '',
      },
    );

    context.read<MainWrapperViewModel>().setIndexByTabKey(targetTab);
  }

  String _defaultTargetTab(NotificationModel notification) {
    switch (notification.notificationType) {
      case 'eve_varis_eta':
      case 'evden_alim_eta':
        return 'map';
      case 'okula_varis':
      case 'eve_birakildi':
        return 'home';
      default:
        return 'notifications';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, vm, _) {
              if (vm.unreadCount > 0) {
                return TextButton(
                  onPressed: () => vm.markAllAsRead(),
                  child: const Text(
                    'Tümünü Oku',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null && vm.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(vm.error!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.loadNotifications(refresh: true),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (vm.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz bildirim yok',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => vm.loadNotifications(refresh: true),
            child: ListView.builder(
              itemCount: vm.notifications.length,
              itemBuilder: (context, index) {
                final notification = vm.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  _getTypeIcon(),
                  color: _getTypeColor(),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        notification.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unread dot
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (notification.notificationType) {
      case 'eve_varis_eta':
      case 'evden_alim_eta':
        return Icons.directions_bus;
      case 'okula_varis':
        return Icons.school;
      case 'eve_birakildi':
        return Icons.home;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor() {
    switch (notification.notificationType) {
      case 'eve_varis_eta':
      case 'evden_alim_eta':
        return Colors.orange;
      case 'okula_varis':
        return Colors.green;
      case 'eve_birakildi':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }
}
