import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/surface_card.dart';

class DriverInfoCard extends StatelessWidget {
  const DriverInfoCard({
    super.key,
    this.driverName,
    this.driverPhone,
    this.plateNumber,
    this.onCallPressed,
  });

  final String? driverName;
  final String? driverPhone;
  final String? plateNumber;
  final Future<void> Function()? onCallPressed;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName ?? 'Sürücü atanmadı',
                      style: AppTextStyles.titleLg,
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      driverPhone ?? 'Telefon bilgisi yok',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DriverMeta(
                  label: 'Araç Plakası',
                  value: plateNumber ?? 'Belirtilmedi',
                  icon: Icons.directions_bus_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DriverMeta(
                  label: 'İletişim',
                  value: driverPhone ?? 'Yok',
                  icon: Icons.phone_outlined,
                ),
              ),
            ],
          ),
          if (driverPhone != null && onCallPressed != null) ...[
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Sürücüyü Ara',
              icon: Icons.phone_forwarded_rounded,
              onPressed: () => onCallPressed!(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DriverMeta extends StatelessWidget {
  const _DriverMeta({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.labelSm,
          ),
          const SizedBox(height: AppSpacing.xxxs),
          Text(
            value,
            style: AppTextStyles.titleMd,
          ),
        ],
      ),
    );
  }
}
