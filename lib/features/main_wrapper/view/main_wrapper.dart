import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/state/selected_student_state.dart';
import '../../notifications/view/notification_view.dart';
import '../../notifications/viewmodel/notification_viewmodel.dart';
import '../../home/view/home_view.dart';
import '../../map/view/map_view.dart';
import '../../profile/view/profile_view.dart';
import '../viewmodel/main_wrapper_view_model.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainWrapperViewModel(),
      child: const _MainWrapperContent(),
    );
  }
}

class _MainWrapperContent extends StatefulWidget {
  const _MainWrapperContent({Key? key}) : super(key: key);

  @override
  State<_MainWrapperContent> createState() => _MainWrapperContentState();
}

class _MainWrapperContentState extends State<_MainWrapperContent> {
  StreamSubscription<Map<String, dynamic>>? _notificationTapSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<SelectedStudentState>().loadStudents();
      context.read<NotificationViewModel>().fetchUnreadCount();
      _notificationTapSubscription = NotificationService()
          .tapPayloadStream
          .listen(_handleNotificationTapPayload);

      final pendingPayload =
          NotificationService().takePendingNavigationPayload();
      if (pendingPayload != null) {
        _handleNotificationTapPayload(pendingPayload);
      }
    });
  }

  Future<void> _handleNotificationTapPayload(
    Map<String, dynamic> payload,
  ) async {
    if (!mounted) {
      return;
    }

    final selectedStudentState = context.read<SelectedStudentState>();
    final studentId = payload['student_id']?.toString();
    if (studentId != null && studentId.trim().isNotEmpty) {
      await selectedStudentState.loadStudents();
      if (!mounted) {
        return;
      }
      selectedStudentState.selectStudentById(studentId.trim());
    }

    if (!mounted) {
      return;
    }

    final targetTab = payload['target_tab']?.toString();
    AnalyticsService().logEvent(
      'notification_opened',
      parameters: <String, Object?>{
        'notification_type':
            payload['notification_type']?.toString() ?? 'genel',
        'target_tab': targetTab ?? 'notifications',
        'student_id': payload['student_id']?.toString() ?? '',
        'event_id': payload['event_id']?.toString() ?? '',
      },
    );
    context.read<MainWrapperViewModel>().setIndexByTabKey(targetTab);
    await context.read<NotificationViewModel>().fetchUnreadCount();
  }

  @override
  void dispose() {
    _notificationTapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainWrapperViewModel>(context);
    final unreadCount = context.select<NotificationViewModel, int>(
      (vm) => vm.unreadCount,
    );
    final size = MediaQuery.of(context).size;

    const List<Widget> pages = [
      HomeView(),
      MapView(),
      NotificationView(),
      ProfileView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: viewModel.currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viewModel.currentIndex,
        onTap: viewModel.setIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        iconSize: size.width * 0.07,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Harita',
          ),
          BottomNavigationBarItem(
            icon: _NotificationBadgeIcon(unreadCount: unreadCount),
            label: 'Bildirimler',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _NotificationBadgeIcon extends StatelessWidget {
  const _NotificationBadgeIcon({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    if (unreadCount <= 0) {
      return const Icon(Icons.notifications);
    }

    final badgeText = unreadCount > 99 ? '99+' : unreadCount.toString();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications),
        Positioned(
          right: -8,
          top: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              badgeText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
