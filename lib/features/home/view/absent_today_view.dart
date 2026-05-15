import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/models/home_status_model.dart';

class AbsentTodayView extends StatefulWidget {
  const AbsentTodayView({
    super.key,
    required this.student,
    required this.onSubmit,
  });

  final Student student;
  final Future<String?> Function(List<String> serviceTypes, String? note)
      onSubmit;

  @override
  State<AbsentTodayView> createState() => _AbsentTodayViewState();
}

class _AbsentTodayViewState extends State<AbsentTodayView> {
  bool _morningSelected = true;
  bool _eveningSelected = false;
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  static const List<String> _monthsTR = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const List<String> _dayNamesTR = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  String _formatTodayTR() {
    final now = DateTime.now();
    final day = now.day;
    final month = _monthsTR[now.month - 1];
    // weekday: 1=Monday … 7=Sunday
    final dayName = _dayNamesTR[now.weekday - 1];
    return '$day $month $dayName (Bugün)';
  }

  List<String> get _selectedServiceTypes {
    final types = <String>[];
    if (_morningSelected) types.add('morning');
    if (_eveningSelected) types.add('evening');
    return types;
  }

  bool get _canSubmit => _morningSelected || _eveningSelected;

  Future<void> _submit() async {
    if (!_canSubmit || _isLoading) return;
    setState(() => _isLoading = true);
    final note = _noteController.text.trim();
    final error = await widget.onSubmit(
      _selectedServiceTypes,
      note.isEmpty ? null : note,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    // Header row with close button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Bugün Servise Binmeyecek',
                      style: AppTextStyles.headlineMd.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Lütfen öğrenci ve servis bilgisini seçin.',
                      style: AppTextStyles.bodySm.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ÖĞRENCİ section
                    const _SectionLabel(label: 'ÖĞRENCİ'),
                    const SizedBox(height: AppSpacing.xxs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: AppColors.primaryDark,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                AppColors.primaryDark.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.person_rounded,
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
                                  widget.student.fullName,
                                  style: AppTextStyles.titleMd.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.student.studentNumber,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryDark,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // TARİH section
                    const _SectionLabel(label: 'TARİH'),
                    const SizedBox(height: AppSpacing.xxs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryDark.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.primaryDark,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _formatTodayTR(),
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // İPTAL EDİLECEK SERVİSLER section
                    const _SectionLabel(label: 'İPTAL EDİLECEK SERVİSLER'),
                    const SizedBox(height: AppSpacing.xxs),
                    _ServiceCard(
                      title: 'Sabah Servisi',
                      subtitle: 'Okula Gidiş',
                      icon: Icons.wb_sunny_rounded,
                      isSelected: _morningSelected,
                      onTap: () =>
                          setState(() => _morningSelected = !_morningSelected),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    _ServiceCard(
                      title: 'Akşam Servisi',
                      subtitle: 'Okuldan Dönüş',
                      icon: Icons.nightlight_round,
                      isSelected: _eveningSelected,
                      onTap: () =>
                          setState(() => _eveningSelected = !_eveningSelected),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // NOT (İSTEĞE BAĞLI) section
                    const _SectionLabel(label: 'NOT (İSTEĞE BAĞLI)'),
                    const SizedBox(height: AppSpacing.xxs),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.primaryDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Örn: Hastaneye gideceğiz',
                        hintStyle: AppTextStyles.bodyMd.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.all(AppSpacing.sm),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide: const BorderSide(
                            color: AppColors.primaryDark,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom button — outside scroll, above safe area
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                MediaQuery.of(context).padding.bottom + AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: PrimaryButton(
                label: 'Okula ve Sürücüye Bildir',
                icon: Icons.send_rounded,
                isLoading: _isLoading,
                onPressed: _canSubmit ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryDark.withValues(alpha: 0.08)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                icon,
                color:
                    isSelected ? AppColors.primaryDark : const Color(0xFF9CA3AF),
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMd.copyWith(
                      color: isSelected
                          ? AppColors.primaryDark
                          : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryDark : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(
                        color: const Color(0xFFD1D5DB),
                        width: 1.5,
                      ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
