import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/surface_card.dart';

class AuthFlowScaffold extends StatelessWidget {
  const AuthFlowScaffold({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.footer,
    this.badge,
    this.icon = Icons.directions_bus_rounded,
    this.showLogo = false,
    this.showBackButton = false,
  });

  final String title;
  final String description;
  final Widget child;
  final Widget? footer;
  final String? badge;
  final IconData icon;
  final bool showLogo;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight = media.size.height - media.padding.vertical;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight - (AppSpacing.screenHorizontal * 2),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SurfaceCard(
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -32,
                        left: -8,
                        right: -8,
                        child: IgnorePointer(
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primarySoft.withValues(alpha: 0.92),
                                  AppColors.primarySoft.withValues(alpha: 0.28),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.lg,
                          AppSpacing.xl,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showBackButton)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () => Navigator.maybePop(context),
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            if (badge != null) ...[
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xxxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primarySoft.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.pill,
                                    ),
                                  ),
                                  child: Text(
                                    badge!,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            _AuthHeroIcon(
                              icon: icon,
                              showLogo: showLogo,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.headlineLg.copyWith(
                                color: AppColors.primary,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              description,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            child,
                            if (footer != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              footer!,
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeroIcon extends StatelessWidget {
  const _AuthHeroIcon({
    required this.icon,
    required this.showLogo,
  });

  final IconData icon;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 88,
              height: 88,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: showLogo
                  ? ClipOval(
                      child: Image.asset(
                        'assets/logo.jpeg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      icon,
                      color: AppColors.onPrimary,
                      size: 34,
                    ),
            ),
            Positioned(
              right: 0,
              bottom: 6,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.alt_route_rounded,
                  color: AppColors.onPrimary,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
