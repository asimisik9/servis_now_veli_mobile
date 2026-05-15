import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppShadows {
  AppShadows._();

  static final List<BoxShadow> surface = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
