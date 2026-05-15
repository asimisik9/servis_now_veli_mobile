import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import 'widgets/auth_flow_scaffold.dart';

class PasswordUpdatedView extends StatelessWidget {
  const PasswordUpdatedView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFlowScaffold(
      title: 'Şifre Güncellendi',
      description:
          'Şifreniz başarıyla güncellendi. Şimdi güvenle hesabınıza tekrar giriş yapabilirsiniz.',
      badge: 'İşlem Tamamlandı',
      icon: Icons.verified_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Giriş ekranına dönüp yeni şifrenizle devam edebilirsiniz.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Girişe Dön',
            trailingIcon: Icons.login_rounded,
            onPressed: () => Navigator.maybePop(context),
          ),
        ],
      ),
    );
  }
}
