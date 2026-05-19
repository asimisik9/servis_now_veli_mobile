import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/form_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/surface_card.dart';
import '../viewmodel/forgot_password_viewmodel.dart';
import 'otp_verification_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  static const Color _neutralText = Color(0xFF4B5563);
  static const Color _neutralLabel = Color(0xFF6B7280);
  static const Color _neutralBorder = Color(0xFFE5E7EB);

  late final ForgotPasswordViewModel _viewModel;
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onSendCodePressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final result = await _viewModel.submit(email);
    if (!mounted) return;

    if (result != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationView(email: email),
        ),
      );
      return;
    }

    setState(() {
      _errorMessage = _viewModel.errorMessage ?? 'Bir hata oluştu. Tekrar deneyin.';
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
                                child: Form(
                                  key: _formKey,
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
                                            'Şifremi Unuttum',
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
                                            hintStyle:
                                                AppTextStyles.bodySm.copyWith(
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
                                          label: 'E-posta',
                                          hint: 'ornek@email.com',
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          labelColor: _neutralLabel,
                                          textColor: _neutralText,
                                          hintColor: _neutralLabel,
                                          prefixIconColor: _neutralLabel,
                                          suffixIconColor: _neutralLabel,
                                          prefixIcon: const Icon(
                                            Icons.mail_outline_rounded,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Lütfen e-posta adresinizi girin';
                                            }
                                            if (!value.contains('@')) {
                                              return 'Geçerli bir e-posta adresi girin';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Eğer bu e-posta ile kayıtlı bir hesabınız varsa, şifre sıfırlama kodu gönderilecektir.',
                                        style: AppTextStyles.bodySm.copyWith(
                                          color: _neutralText,
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
                                      const SizedBox(height: AppSpacing.lg),
                                      PrimaryButton(
                                        label: 'Kod Gönder',
                                        backgroundColor: AppColors.primaryDark,
                                        onPressed: _onSendCodePressed,
                                        isLoading: _viewModel.isLoading,
                                      ),
                                    ],
                                  ),
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
