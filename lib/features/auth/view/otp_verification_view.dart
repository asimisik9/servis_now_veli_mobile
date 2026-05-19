import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/form_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/surface_card.dart';
import '../viewmodel/forgot_password_viewmodel.dart';
import 'new_password_view.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  static const Color _neutralText = Color(0xFF4B5563);
  static const Color _neutralLabel = Color(0xFF6B7280);
  static const Color _neutralBorder = Color(0xFFE5E7EB);

  late final ForgotPasswordViewModel _viewModel;
  final TextEditingController _codeController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    final token = _codeController.text.trim();
    if (token.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen e-postanıza gelen kodu girin.';
        _successMessage = null;
      });
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NewPasswordView(token: token)),
    );
  }

  Future<void> _onResendCodePressed() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await _viewModel.submit(widget.email.trim());
    if (!mounted) return;

    if (result != null) {
      setState(() => _successMessage = 'Kod tekrar gönderildi.');
      return;
    }

    setState(() {
      _errorMessage = _viewModel.errorMessage ?? 'Kod gönderilemedi. Tekrar deneyin.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight -
                          (AppSpacing.screenHorizontal * 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: SurfaceCard(
                              color: AppColors.surface,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(AppRadius.xxl),
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xl,
                                AppSpacing.xl,
                                AppSpacing.xl,
                                AppSpacing.lg,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minHeight: 520),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 88,
                                          height: 88,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            child: Image.asset(
                                              'assets/logo.jpeg',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        Text(
                                          'Kodu Girin',
                                          textAlign: TextAlign.center,
                                          style:
                                              AppTextStyles.headlineLg.copyWith(
                                            color: AppColors.primaryDark,
                                            fontSize: 28,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xxl),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintStyle: AppTextStyles.bodySm.copyWith(
                                            color: _neutralLabel,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                              AppRadius.xl,
                                            ),
                                            borderSide: const BorderSide(
                                              color: _neutralBorder,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                              AppRadius.xl,
                                            ),
                                            borderSide: const BorderSide(
                                              color: _neutralBorder,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                              AppRadius.xl,
                                            ),
                                            borderSide: const BorderSide(
                                              color: AppColors.primaryDark,
                                              width: 1.4,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: FormInput(
                                        label: 'Kod',
                                        hint: 'Mailden gelen kodu girin',
                                        controller: _codeController,
                                        keyboardType: TextInputType.text,
                                        labelColor: _neutralLabel,
                                        textColor: _neutralText,
                                        hintColor: _neutralLabel,
                                        prefixIconColor: _neutralLabel,
                                        suffixIconColor: _neutralLabel,
                                        prefixIcon: const Icon(
                                          Icons.verified_user_outlined,
                                        ),
                                      ),
                                    ),
                                    if (_errorMessage != null) ...[
                                      const SizedBox(height: AppSpacing.md),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFEBEB),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFFFFCDD2),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: Color(0xFFD32F2F),
                                              size: 18,
                                            ),
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
                                    if (_successMessage != null) ...[
                                      const SizedBox(height: AppSpacing.md),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFFA5D6A7),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle_outline,
                                              color: Color(0xFF2E7D32),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _successMessage!,
                                                style: const TextStyle(
                                                  color: Color(0xFF2E7D32),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: AppSpacing.lg),
                                    PrimaryButton(
                                      label: 'Devam Et',
                                      backgroundColor: AppColors.primaryDark,
                                      onPressed: _onContinuePressed,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Align(
                                      child: TextButton(
                                        onPressed: _viewModel.isLoading
                                            ? null
                                            : _onResendCodePressed,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize
                                              .shrinkWrap,
                                        ),
                                        child: Text(
                                          _viewModel.isLoading
                                              ? 'Gönderiliyor...'
                                              : 'Kodu Tekrar Gönder',
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: _neutralLabel,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
