import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/state/selected_student_state.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../main_wrapper/viewmodel/main_wrapper_view_model.dart';
import '../data/notification_model.dart';
import '../viewmodel/notification_viewmodel.dart';

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
      if (!mounted) return;
    }

    final studentId = notification.studentId?.trim();
    if (studentId != null && studentId.isNotEmpty) {
      final selectedStudentState = context.read<SelectedStudentState>();
      await selectedStudentState.loadStudents();
      if (!mounted) return;
      selectedStudentState.selectStudentById(studentId);
    }

    if (!mounted) return;

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
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Consumer<NotificationViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading && vm.notifications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              );
            }

            if (vm.error != null && vm.notifications.isEmpty) {
              return _NotificationErrorState(
                message: vm.error!,
                onRetry: () => vm.loadNotifications(refresh: true),
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryDark,
              onRefresh: () => vm.loadNotifications(refresh: true),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        AppSpacing.md,
                        AppSpacing.screenHorizontal,
                        0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Bildirimler',
                            style: AppTextStyles.headlineMd.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const Spacer(),
                          if (vm.unreadCount > 0)
                            GestureDetector(
                              onTap: vm.markAllAsRead,
                              child: Text(
                                'Tümünü Oku',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _CategoryChips(
                      selected: vm.selectedCategory,
                      onSelect: vm.setCategory,
                    ),
                  ),
                  if (vm.filteredNotifications.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _NotificationEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        AppSpacing.xxs,
                        AppSpacing.screenHorizontal,
                        120,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final notification =
                                vm.filteredNotifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Dismissible(
                                key: ValueKey(
                                  '${notification.id}_${notification.isRead}',
                                ),
                                direction: notification.isRead
                                    ? DismissDirection.none
                                    : DismissDirection.startToEnd,
                                confirmDismiss: (_) async {
                                  await context
                                      .read<NotificationViewModel>()
                                      .markAsRead(notification.id);
                                  return false;
                                },
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.xl,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Okundu',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: _NotificationCard(
                                  notification: notification,
                                  onTap: () =>
                                      _handleNotificationTap(notification),
                                ),
                              ),
                            );
                          },
                          childCount: vm.filteredNotifications.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelect});

  final NotificationCategory selected;
  final ValueChanged<NotificationCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Row(
        children: NotificationCategory.values.map((category) {
          final isSelected = category == selected;
          final isLast = category == NotificationCategory.values.last;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : AppSpacing.xxs),
              child: GestureDetector(
                onTap: () => onSelect(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryDark
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    _label(category),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.all:
        return 'Tümü';
      case NotificationCategory.servis:
        return 'Servis';
      case NotificationCategory.guvenlik:
        return 'Güvenlik';
      case NotificationCategory.okul:
        return 'Okul';
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor;
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: isRead
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            children: [
              Container(
                color: isRead ? const Color(0xFFF9FAFB) : Colors.white,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(
                          alpha: isRead ? 0.07 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Icon(
                        _typeIcon,
                        color: typeColor.withValues(
                          alpha: isRead ? 0.45 : 1.0,
                        ),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: AppTextStyles.titleMd.copyWith(
                                    fontWeight: isRead
                                        ? FontWeight.w400
                                        : FontWeight.w600,
                                    color: isRead
                                        ? const Color(0xFF9CA3AF)
                                        : AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              if (!isRead) ...[
                                const SizedBox(width: AppSpacing.xxs),
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: typeColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxxs),
                          Text(
                            notification.message,
                            style: AppTextStyles.bodySm.copyWith(
                              color: isRead
                                  ? const Color(0xFFB0B7C3)
                                  : const Color(0xFF4B5563),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Row(
                            children: [
                              Text(
                                _categoryLabel,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: typeColor.withValues(
                                    alpha: isRead ? 0.45 : 1.0,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                notification.timeAgo,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 3, color: typeColor),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _typeColor {
    switch (notification.notificationType) {
      case 'eve_varis_eta':
      case 'evden_alim_eta':
        return AppColors.primaryDark;
      case 'okula_varis':
        return const Color(0xFF7C3AED);
      case 'eve_birakildi':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData get _typeIcon {
    switch (notification.notificationType) {
      case 'eve_varis_eta':
      case 'evden_alim_eta':
        return Icons.directions_bus_rounded;
      case 'okula_varis':
        return Icons.school_rounded;
      case 'eve_birakildi':
        return Icons.home_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  String get _categoryLabel {
    switch (notification.notificationType) {
      case 'eve_varis_eta':
        return 'Varış Tahmini';
      case 'evden_alim_eta':
        return 'Alım Tahmini';
      case 'okula_varis':
        return 'Okul Varışı';
      case 'eve_birakildi':
        return 'Eve Bırakıldı';
      default:
        return 'Genel';
    }
  }
}

class _NotificationErrorState extends StatelessWidget {
  const _NotificationErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_off_rounded,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Tekrar Dene',
              onPressed: () => onRetry(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            size: 52,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bu kategoride bildirim yok.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
