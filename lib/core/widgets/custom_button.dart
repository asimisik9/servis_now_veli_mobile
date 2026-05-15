import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'primary_button.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: textColor ?? Colors.white,
    );
  }
}
