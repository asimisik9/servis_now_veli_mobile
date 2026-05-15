import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/state/selected_student_state.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodel/home_view_model.dart';
import 'absent_today_view.dart';
import 'address_change_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;
  late String _currentTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      selectedStudentState: context.read<SelectedStudentState>(),
    );
    _currentTime = _formatTime(DateTime.now());
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _currentTime = _formatTime(DateTime.now()));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _viewModel.init());
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _clockTimer?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  _TripState _tripState(String? status) {
    switch (status) {
      case 'to_school':
        return const _TripState(
          label: 'Okula gidiliyor',
          caption: 'Çocuğunuz güvenli şekilde takip ediliyor.',
          chipLabel: 'CANLI TAKİP',
          isActive: true,
          progressFromLabel: 'Ev',
          progressToLabel: 'Okul',
        );
      case 'to_home':
        return const _TripState(
          label: 'Eve dönülüyor',
          caption: 'Dönüş servisi başladı, canlı takip devam ediyor.',
          chipLabel: 'CANLI TAKİP',
          isActive: true,
          progressFromLabel: 'Okul',
          progressToLabel: 'Ev',
        );
      default:
        return const _TripState(
          label: 'Servis Beklemede',
          caption: 'Servis şu anda aktif rota üzerinde görünmüyor.',
          chipLabel: 'BEKLEMEDE',
          isActive: false,
          progressFromLabel: 'Ev',
          progressToLabel: 'Okul',
        );
    }
  }

  void _showSupportSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Destek Al', style: AppTextStyles.titleLg),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Destek özelliği yakında hizmetinizde olacak. '
                'Acil durumlarda okulunuzla veya servis firmanızla iletişime geçebilirsiniz.',
                style: AppTextStyles.bodySm.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStudentSelector() {
    if (!_viewModel.hasMultipleStudents) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Öğrenci Seç', style: AppTextStyles.titleLg),
              const SizedBox(height: AppSpacing.sm),
              ..._viewModel.students.map((s) {
                final isSelected = s.id == _viewModel.selectedStudentId;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryDark
                        .withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryDark,
                      size: 20,
                    ),
                  ),
                  title: Text(s.fullName, style: AppTextStyles.titleMd),
                  subtitle: Text(
                    s.schoolName ?? s.schoolId ?? '',
                    style: AppTextStyles.bodySm,
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryDark,
                        )
                      : null,
                  onTap: () {
                    _viewModel.selectStudent(s.id);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading && _viewModel.homeStatus == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              );
            }

            if (_viewModel.errorMessage != null &&
                _viewModel.homeStatus == null) {
              return _HomeErrorState(
                message: _viewModel.errorMessage!,
                onRetry: _viewModel.fetchHomeData,
              );
            }

            final data = _viewModel.homeStatus;
            final student = _viewModel.currentStudent;
            if (data == null || student == null) {
              return const _HomeEmptyState();
            }

            final trip = _tripState(data.tripStatus);
            final safeMinutes = data.minutesLeft?.clamp(0, 999);
            final progress = safeMinutes == null
                ? 0.3
                : (1 - (safeMinutes / 60)).clamp(0.08, 0.95).toDouble();

            return RefreshIndicator(
              color: AppColors.primaryDark,
              onRefresh: () =>
                  _viewModel.fetchHomeData(refreshStudents: true),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                  AppSpacing.screenHorizontal,
                  120,
                ),
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Merhaba,',
                              style: AppTextStyles.bodySm.copyWith(
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              _viewModel.parentDisplayName,
                              style: AppTextStyles.headlineMd.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _showStudentSelector,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.primaryDark
                                    .withValues(alpha: 0.12),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 14,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                student.fullName.split(' ').first,
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              if (_viewModel.hasMultipleStudents) ...[
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Hero card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: trip.isActive
                                    ? const Color(0xFF16A34A).withValues(
                                        alpha: 0.25,
                                      )
                                    : Colors.white.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: trip.isActive
                                          ? const Color(0xFF4ADE80)
                                          : Colors.white
                                              .withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    trip.chipLabel,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: trip.isActive
                                          ? const Color(0xFF4ADE80)
                                          : Colors.white
                                              .withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl),
                              ),
                              child: const Icon(
                                Icons.directions_bus_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          trip.label,
                          style: AppTextStyles.headlineMd.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxs),
                        Text(
                          trip.caption,
                          style: AppTextStyles.bodySm.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.isActive
                                        ? 'Tahmini Varış'
                                        : 'Durum',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    trip.isActive
                                        ? (safeMinutes != null
                                            ? '$safeMinutes dk'
                                            : '— dk')
                                        : 'Beklemede',
                                    style: AppTextStyles.headlineMd.copyWith(
                                      color: Colors.white,
                                      fontSize: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saat',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentTime,
                                  style: AppTextStyles.headlineMd.copyWith(
                                    color: Colors.white,
                                    fontSize: 28,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                          child: SizedBox(
                            height: 6,
                            child: Stack(
                              children: [
                                Container(
                                  color:
                                      Colors.white.withValues(alpha: 0.18),
                                ),
                                FractionallySizedBox(
                                  widthFactor: trip.isActive ? progress : 0.3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.5),
                                          Colors.white,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              trip.progressFromLabel,
                              style: AppTextStyles.labelSm.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              trip.progressToLabel,
                              style: AppTextStyles.labelSm.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Quick actions
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.phone_rounded,
                        label: 'Şoförü\nAra',
                        iconColor: AppColors.primaryDark,
                        iconBg: AppColors.primaryDark.withValues(alpha: 0.08),
                        onTap: data.driverPhone == null
                            ? null
                            : () async {
                                final messenger =
                                    ScaffoldMessenger.of(context);
                                final err = await _viewModel
                                    .callDriver(data.driverPhone);
                                if (!mounted || err == null) return;
                                messenger.showSnackBar(
                                  SnackBar(content: Text(err)),
                                );
                              },
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      _QuickAction(
                        icon: Icons.location_on_rounded,
                        label: 'Adres\nDeğiştir',
                        iconColor: AppColors.primaryDark,
                        iconBg: AppColors.primaryDark.withValues(alpha: 0.08),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddressChangeView(
                              currentAddress:
                                  student.address ?? '',
                              onSubmit: ({
                                required address,
                                required startDate,
                                endDate,
                                note,
                                latitude,
                                longitude,
                              }) =>
                                  _viewModel.updateAddress(
                                address,
                                startDate: startDate,
                                endDate: endDate,
                                note: note,
                                latitude: latitude,
                                longitude: longitude,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      _QuickAction(
                        icon: Icons.event_busy_rounded,
                        label: _viewModel.isAbsent
                            ? 'Devamsız\nİşaretlendi'
                            : 'Binmeyecek\nBugün',
                        iconColor: _viewModel.isAbsent
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFFDC2626),
                        iconBg: _viewModel.isAbsent
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFFDC2626).withValues(alpha: 0.08),
                        onTap: _viewModel.isAbsent
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AbsentTodayView(
                                      student: student,
                                      onSubmit: (serviceTypes, note) =>
                                          _viewModel.markAbsent(
                                        serviceTypes: serviceTypes,
                                        note: note,
                                      ),
                                    ),
                                  ),
                                ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      _QuickAction(
                        icon: Icons.headset_mic_rounded,
                        label: 'Destek\nAl',
                        iconColor: AppColors.primaryDark,
                        iconBg: AppColors.primaryDark.withValues(alpha: 0.08),
                        onTap: _showSupportSheet,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // School card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: AppColors.primaryDark,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Okul',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                student.schoolName ??
                                    student.schoolId ??
                                    'Okul bilgisi yok',
                                style: AppTextStyles.titleMd.copyWith(
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Driver + Plate row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Şoför',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primaryDark
                                        .withValues(alpha: 0.1),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.primaryDark,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xxs),
                                  Expanded(
                                    child: Text(
                                      data.driverName ?? '—',
                                      style: AppTextStyles.titleMd.copyWith(
                                        color: AppColors.primaryDark,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plaka',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                    width: 1.5,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                ),
                                child: Text(
                                  data.plateNumber ?? '—',
                                  style: AppTextStyles.titleMd.copyWith(
                                    color: AppColors.primaryDark,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.45 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primaryDark,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.message, required this.onRetry});

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
              Icons.error_outline_rounded,
              color: Color(0xFF9CA3AF),
              size: 48,
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

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.school_outlined,
            color: Color(0xFF9CA3AF),
            size: 48,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Kayıtlı öğrenci bilgisi bulunamadı.',
            style: AppTextStyles.bodyMd.copyWith(
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TripState {
  const _TripState({
    required this.label,
    required this.caption,
    required this.chipLabel,
    required this.isActive,
    required this.progressFromLabel,
    required this.progressToLabel,
  });

  final String label;
  final String caption;
  final String chipLabel;
  final bool isActive;
  final String progressFromLabel;
  final String progressToLabel;
}
