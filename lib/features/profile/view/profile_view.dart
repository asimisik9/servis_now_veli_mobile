import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/state/selected_student_state.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/action_tile.dart';
import '../../../core/widgets/surface_card.dart';
import '../../auth/view/forgot_password_view.dart';
import '../../auth/view/login_view.dart';
import '../viewmodel/profile_view_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(
        selectedStudentState: context.read<SelectedStudentState>(),
      )..init(),
      child: const _ProfileViewContent(),
    );
  }
}

class _ProfileViewContent extends StatefulWidget {
  const _ProfileViewContent();

  @override
  State<_ProfileViewContent> createState() => _ProfileViewContentState();
}

class _ProfileViewContentState extends State<_ProfileViewContent> {
  bool _notifyServiceApproaching = true;
  bool _notifyArrivalToSchool = true;
  bool _notifyDelayAlerts = true;

  Future<void> _showLogoutDialog(
    BuildContext context,
    ProfileViewModel viewModel,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Uygulamadan çıkış yapmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return;
    }

    final success = await viewModel.logout();
    if (!context.mounted) {
      return;
    }

    if (success) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'Çıkış yapılırken bir hata oluştu.',
        ),
      ),
    );
  }

  void _openForgotPassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordView()),
    );
  }

  Future<void> _showHelpSupportSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.lg,
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
              const Text(
                'Yardım ve Destek',
                style: AppTextStyles.titleLg,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Destek için okulunuzla veya ServisNow Veli destek ekibiyle iletişime geçebilirsiniz.',
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

  Widget _buildStudentsSection(ProfileViewModel viewModel) {
    final students = viewModel.students;

    if (students.isEmpty) {
      return SurfaceCard(
        color: Colors.white,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'Kayıtlı öğrenci bulunamadı.',
          style: AppTextStyles.bodyMd.copyWith(color: const Color(0xFF374151)),
        ),
      );
    }

    return Column(
      children: students.map((student) {
        final isSelected = student.id == viewModel.selectedStudentId;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: ActionTile(
            title: student.fullName,
            subtitle: student.schoolName ?? student.schoolId ?? 'Okul bilgisi yok',
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 20,
                color: AppColors.primaryDark,
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryDark,
                  )
                : const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9CA3AF),
                  ),
            onTap: () => viewModel.selectStudent(student.id),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final student = viewModel.currentStudent;

    if (viewModel.isLoading && student == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryDark),
        ),
      );
    }

    if (student == null && viewModel.errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: SurfaceCard(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: viewModel.reload,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      child: const Text('Tekrar Dene'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryDark,
          onRefresh: viewModel.reload,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.md,
              AppSpacing.screenHorizontal,
              128,
            ),
            children: [
              Text(
                'Profil',
                style: AppTextStyles.headlineMd.copyWith(color: AppColors.primaryDark),
              ),
              const SizedBox(height: AppSpacing.xxxs),
              Text(
                viewModel.parentDisplayName,
                style: AppTextStyles.bodyMd.copyWith(color: const Color(0xFF4B5563)),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                viewModel.hasMultipleStudents ? 'Çocuklarım' : 'Çocuğum',
                style: AppTextStyles.titleMd.copyWith(color: AppColors.primaryDark),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildStudentsSection(viewModel),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Bildirim Ayarları',
                style: AppTextStyles.titleMd.copyWith(color: AppColors.primaryDark),
              ),
              const SizedBox(height: AppSpacing.sm),
              SurfaceCard(
                color: Colors.white,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  children: [
                    _SwitchRow(
                      title: 'Servis yaklaştığında',
                      value: _notifyServiceApproaching,
                      onChanged: (value) {
                        setState(() {
                          _notifyServiceApproaching = value;
                        });
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    _SwitchRow(
                      title: 'Okula varış',
                      value: _notifyArrivalToSchool,
                      onChanged: (value) {
                        setState(() {
                          _notifyArrivalToSchool = value;
                        });
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    _SwitchRow(
                      title: 'Gecikme uyarıları',
                      value: _notifyDelayAlerts,
                      onChanged: (value) {
                        setState(() {
                          _notifyDelayAlerts = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Genel Ayarlar',
                style: AppTextStyles.titleMd.copyWith(color: AppColors.primaryDark),
              ),
              const SizedBox(height: AppSpacing.sm),
              ActionTile(
                title: 'Şifre Değiştir',
                subtitle: 'Şifrenizi güvenli şekilde yenileyin',
                leading: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primaryDark,
                ),
                onTap: () => _openForgotPassword(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Yardım ve Destek',
                style: AppTextStyles.titleMd.copyWith(color: AppColors.primaryDark),
              ),
              const SizedBox(height: AppSpacing.sm),
              ActionTile(
                title: 'Yardım Merkezi',
                subtitle: 'Sık sorulan sorular ve destek kanalları',
                leading: const Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primaryDark,
                ),
                onTap: () => _showHelpSupportSheet(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: viewModel.isLoggingOut
                      ? null
                      : () => _showLogoutDialog(context, viewModel),
                  icon: viewModel.isLoggingOut
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout_rounded),
                  label: Text(
                    viewModel.isLoggingOut ? 'Çıkış yapılıyor...' : 'Çıkış Yap',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    textStyle: AppTextStyles.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyMd.copyWith(color: const Color(0xFF374151)),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primaryDark,
          inactiveThumbColor: const Color(0xFF9CA3AF),
          inactiveTrackColor: const Color(0xFFE5E7EB),
        ),
      ],
    );
  }
}
