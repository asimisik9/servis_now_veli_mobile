import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/surface_card.dart';

class EtaCard extends StatelessWidget {
  const EtaCard({
    super.key,
    this.minutesLeft,
    this.isInactive = false,
    required this.tripLabel,
  });

  final int? minutesLeft;
  final bool isInactive;
  final String tripLabel;

  @override
  Widget build(BuildContext context) {
    final safeMinutes = minutesLeft?.clamp(0, 999);
    final progress = safeMinutes == null
        ? 0.35
        : (1 - (safeMinutes / 60)).clamp(0.12, 0.96).toDouble();

    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isInactive ? AppColors.surfaceLow : AppColors.primarySoft)
                      .withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(
                  isInactive ? Icons.bus_alert_rounded : Icons.directions_bus_rounded,
                  color: isInactive ? AppColors.textSecondary : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isInactive ? 'Servis Durumu' : 'Tahmini Varış',
                      style: AppTextStyles.labelSm,
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      isInactive ? 'Rota şu an aktif değil' : tripLabel,
                      style: AppTextStyles.titleMd,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (!isInactive && safeMinutes != null) ...[
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$safeMinutes',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: ' dk',
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Text(
              isInactive ? 'Servis yeniden hareket ettiğinde süre gösterilecek.' : 'Süre hesaplanıyor...',
              style: AppTextStyles.bodyMd,
            ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Container(color: AppColors.surfaceContainer),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.accent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Çıkış',
                style: AppTextStyles.labelSm,
              ),
              Text(
                isInactive ? 'Beklemede' : 'Varış',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
