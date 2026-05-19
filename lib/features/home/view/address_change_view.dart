import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/map_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';

enum _InputMode { map, manual }

class AddressChangeView extends StatefulWidget {
  const AddressChangeView({
    super.key,
    required this.currentAddress,
    required this.onSubmit,
  });

  final String currentAddress;
  final Future<String?> Function({
    required String address,
    required DateTime startDate,
    DateTime? endDate,
    String? note,
    double? latitude,
    double? longitude,
  }) onSubmit;

  @override
  State<AddressChangeView> createState() => _AddressChangeViewState();
}

class _AddressChangeViewState extends State<AddressChangeView> {
  _InputMode _mode = _InputMode.map;

  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _mapController = MapController();

  LatLng _mapCenter = const LatLng(41.0082, 28.9784);
  LatLng? _confirmedLatLng;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;
  String? _errorMessage;

  static const List<String> _monthsTR = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_monthsTR[dt.month - 1]} ${dt.year}';

  bool get _canSubmit {
    if (_startDate == null) return false;
    if (_mode == _InputMode.map) return _confirmedLatLng != null;
    return _addressController.text.trim().isNotEmpty;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? (_startDate ?? now) : (_endDate ?? now);
    final first = isStart ? DateTime(2020) : (_startDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2100),
      helpText: isStart ? 'Başlangıç Tarihi' : 'Bitiş Tarihi',
      cancelText: 'İptal',
      confirmText: 'Seç',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryDark,
            onPrimary: Colors.white,
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
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      } else {
        _endDate = picked;
      }
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    if (_startDate == null) {
      setState(() {
        _errorMessage =
            'Başlangıç tarihi seçilmedi.\nÖrnek: ${_formatDate(DateTime.now())}';
      });
      return;
    }

    if (_mode == _InputMode.map && _confirmedLatLng == null) {
      setState(() => _errorMessage = 'Lütfen haritadan bir konum seçin.');
      return;
    }

    if (_mode == _InputMode.manual &&
        _addressController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Lütfen adres bilgisini girin.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final address = _mode == _InputMode.map
        ? '${_confirmedLatLng!.latitude.toStringAsFixed(6)}, ${_confirmedLatLng!.longitude.toStringAsFixed(6)}'
        : _addressController.text.trim();

    final note = _noteController.text.trim();

    final error = await widget.onSubmit(
      address: address,
      startDate: _startDate!,
      endDate: _endDate,
      note: note.isEmpty ? null : note,
      latitude: _mode == _InputMode.map ? _confirmedLatLng!.latitude : null,
      longitude: _mode == _InputMode.map ? _confirmedLatLng!.longitude : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Adres Değiştir', style: AppTextStyles.titleLg),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                AppSpacing.xl + bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mevcut adres
                  _SectionLabel(label: 'MEVCUT KAYITLI ADRES'),
                  const SizedBox(height: AppSpacing.xxs),
                  _CurrentAddressCard(address: widget.currentAddress),
                  const SizedBox(height: AppSpacing.md),

                  // Mod seçimi
                  _SectionLabel(label: 'YENİ ADRES GİRİŞ YÖNTEMİ'),
                  const SizedBox(height: AppSpacing.xxs),
                  _ModeSelector(
                    mode: _mode,
                    onChanged: (m) => setState(() {
                      _mode = m;
                      _errorMessage = null;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // İçerik
                  if (_mode == _InputMode.map) _buildMapSection(),
                  if (_mode == _InputMode.manual) _buildManualSection(),

                  const SizedBox(height: AppSpacing.md),

                  // Tarih seçimi
                  _SectionLabel(label: 'GEÇERLİLİK TARİHİ'),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Expanded(
                        child: _DateChip(
                          label: 'Başlangıç',
                          value: _startDate != null
                              ? _formatDate(_startDate!)
                              : null,
                          placeholder: 'Tarih seçin *',
                          isRequired: true,
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _DateChip(
                          label: 'Bitiş',
                          value:
                              _endDate != null ? _formatDate(_endDate!) : null,
                          placeholder: 'İsteğe bağlı',
                          isRequired: false,
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  if (_startDate == null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Örnek tarih formatı: ${_formatDate(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),

                  // Not alanı
                  _SectionLabel(label: 'NOT (İSTEĞE BAĞLI)'),
                  const SizedBox(height: AppSpacing.xxs),
                  _buildTextField(
                    controller: _noteController,
                    hint: 'Açıklama ekleyin...',
                    maxLines: 2,
                  ),

                  // Hata banner
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFD32F2F), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFD32F2F),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Gönder butonu
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.sm,
              AppSpacing.screenHorizontal,
              MediaQuery.of(context).padding.bottom + AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: PrimaryButton(
              label: 'Gönder',
              trailingIcon: Icons.send_rounded,
              isLoading: _isLoading,
              onPressed: _canSubmit ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 220,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _mapCenter,
                  initialZoom: 14,
                  onPositionChanged: (camera, hasGesture) {
                    if (hasGesture) {
                      _mapCenter = camera.center;
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: MapConfig.tileUrlTemplate,
                    userAgentPackageName: 'com.servisnow.parent',
                  ),
                ],
              ),
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_pin,
                        color: Color(0xFFDC2626), size: 40),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Konumu belirlemek için haritayı kaydırın',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _confirmedLatLng = _mapCenter;
                _errorMessage = null;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.primaryDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: Icon(
              _confirmedLatLng != null
                  ? Icons.check_circle_rounded
                  : Icons.my_location_rounded,
              size: 18,
            ),
            label: Text(
              _confirmedLatLng != null
                  ? 'Konum Seçildi ✓'
                  : 'Bu Konumu Kullan',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (_confirmedLatLng != null) ...[
          const SizedBox(height: 6),
          Text(
            '${_confirmedLatLng!.latitude.toStringAsFixed(5)}, ${_confirmedLatLng!.longitude.toStringAsFixed(5)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildManualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _addressController,
          hint: 'Tam adres bilgisini girin...',
          maxLines: 3,
          onChanged: (_) => setState(() => _errorMessage = null),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 3,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.primaryDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMd.copyWith(color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.all(AppSpacing.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide:
              const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.mode, required this.onChanged});

  final _InputMode mode;
  final ValueChanged<_InputMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ModeButton(
          icon: Icons.map_rounded,
          label: 'Haritadan Seç',
          isSelected: mode == _InputMode.map,
          onTap: () => onChanged(_InputMode.map),
        ),
        const SizedBox(width: AppSpacing.xs),
        _ModeButton(
          icon: Icons.edit_rounded,
          label: 'Manuel Gir',
          isSelected: mode == _InputMode.manual,
          onTap: () => onChanged(_InputMode.manual),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryDark
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryDark
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.isRequired,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final bool isRequired;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.primaryDark.withValues(alpha: 0.06)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: hasValue ? AppColors.primaryDark : const Color(0xFFE5E7EB),
            width: hasValue ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRequired ? '$label *' : label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hasValue
                          ? AppColors.primaryDark
                          : const Color(0xFF9CA3AF),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? placeholder,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: hasValue
                          ? AppColors.primaryDark
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: hasValue
                  ? AppColors.primaryDark
                  : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentAddressCard extends StatelessWidget {
  const _CurrentAddressCard({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: AppColors.primaryDark),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.primaryDark, size: 20),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          address.isEmpty ? 'Kayıtlı adres yok.' : address,
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.primaryDark),
                        ),
                      ),
                    ],
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.8,
      ),
    );
  }
}
