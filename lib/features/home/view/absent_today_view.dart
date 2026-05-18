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
  final Future<String?> Function(
    List<String> serviceTypes,
    String? note,
    DateTime startDate,
    DateTime? endDate,
  ) onSubmit;

  @override
  State<AbsentTodayView> createState() => _AbsentTodayViewState();
}

enum _DateMode { single, range }

class _AbsentTodayViewState extends State<AbsentTodayView> {
  bool _morningSelected = true;
  bool _eveningSelected = false;
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  _DateMode _dateMode = _DateMode.single;
  late DateTime _selectedDate;
  late DateTime _startDate;
  DateTime? _endDate;

  static const List<String> _monthsTR = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const List<String> _dayNamesTR = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar',
  ];
  static const List<String> _dayAbbrTR = [
    'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz',
  ];

  @override
  void initState() {
    super.initState();
    final today = _today();
    _selectedDate = today;
    _startDate = today;
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  String _formatDateTR(DateTime dt, {bool showToday = true}) {
    final today = _today();
    final day = dt.day;
    final month = _monthsTR[dt.month - 1];
    final dayName = _dayNamesTR[dt.weekday - 1];
    final suffix = (showToday && dt == today) ? ' (Bugün)' : '';
    return '$day $month, $dayName$suffix';
  }

  List<String> get _selectedServiceTypes {
    final types = <String>[];
    if (_morningSelected) types.add('morning');
    if (_eveningSelected) types.add('evening');
    return types;
  }

  bool get _canSubmit {
    if (!_morningSelected && !_eveningSelected) return false;
    if (_dateMode == _DateMode.range && _endDate == null) return false;
    return true;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final today = _today();
    final initialDate = isStart ? _startDate : (_endDate ?? _startDate);
    final firstDate = isStart ? today : _startDate;
    final lastDate = today.add(const Duration(days: 60));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('tr'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryDark,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.primaryDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isLoading) return;
    setState(() => _isLoading = true);
    final note = _noteController.text.trim();
    final startDate = _dateMode == _DateMode.single ? _selectedDate : _startDate;
    final endDate = _dateMode == _DateMode.range ? _endDate : null;
    final error = await widget.onSubmit(
      _selectedServiceTypes,
      note.isEmpty ? null : note,
      startDate,
      endDate,
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
                      'Servise Binmeyecek',
                      style: AppTextStyles.headlineMd.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Lütfen tarih ve servis bilgisini seçin.',
                      style: AppTextStyles.bodySm.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ÖĞRENCİ
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

                    // TARİH
                    const _SectionLabel(label: 'TARİH'),
                    const SizedBox(height: AppSpacing.xxs),

                    // Mode toggle
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        children: [
                          _ModeTab(
                            label: 'Tek Gün',
                            isSelected: _dateMode == _DateMode.single,
                            onTap: () =>
                                setState(() => _dateMode = _DateMode.single),
                          ),
                          _ModeTab(
                            label: 'Tarih Aralığı',
                            isSelected: _dateMode == _DateMode.range,
                            onTap: () =>
                                setState(() => _dateMode = _DateMode.range),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (_dateMode == _DateMode.single) ...[
                      _SingleDatePicker(
                        selectedDate: _selectedDate,
                        dayAbbrTR: _dayAbbrTR,
                        onDateSelected: (d) =>
                            setState(() => _selectedDate = d),
                      ),
                    ] else ...[
                      _DateRangeRow(
                        label: 'Başlangıç',
                        date: _startDate,
                        formattedDate: _formatDateTR(_startDate),
                        onTap: () => _pickDate(isStart: true),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      _DateRangeRow(
                        label: 'Bitiş',
                        date: _endDate,
                        formattedDate:
                            _endDate != null ? _formatDateTR(_endDate!) : null,
                        onTap: () => _pickDate(isStart: false),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),

                    // İPTAL EDİLECEK SERVİSLER
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

                    // NOT
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

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryDark
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleDatePicker extends StatelessWidget {
  const _SingleDatePicker({
    required this.selectedDate,
    required this.dayAbbrTR,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final List<String> dayAbbrTR;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final days = List.generate(
      7,
      (i) => todayDate.add(Duration(days: i)),
    );

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xxs),
        itemBuilder: (context, i) {
          final day = days[i];
          final isSelected = day == selectedDate;
          final isToday = day == todayDate;
          return GestureDetector(
            onTap: () => onDateSelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 58,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryDark : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryDark
                      : const Color(0xFFE5E7EB),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'Bugün' : dayAbbrTR[day.weekday - 1],
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DateRangeRow extends StatelessWidget {
  const _DateRangeRow({
    required this.label,
    required this.date,
    required this.formattedDate,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final String? formattedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: hasDate ? AppColors.primaryDark : const Color(0xFFE5E7EB),
            width: hasDate ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primaryDark,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    formattedDate ?? 'Tarih seçin',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hasDate
                          ? AppColors.primaryDark
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
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
            color:
                isSelected ? AppColors.primaryDark : const Color(0xFFE5E7EB),
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
                color: isSelected
                    ? AppColors.primaryDark
                    : const Color(0xFF9CA3AF),
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
