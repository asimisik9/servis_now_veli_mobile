import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/form_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/surface_card.dart';
import '../viewmodel/reset_password_viewmodel.dart';
import 'password_updated_view.dart';

class NewPasswordView extends StatefulWidget {
  const NewPasswordView({
    super.key,
    required this.token,
  });

  final String token;

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  static const Color _neutralText = Color(0xFF4B5563);
  static const Color _neutralLabel = Color(0xFF6B7280);
  static const Color _neutralBorder = Color(0xFFE5E7EB);

  late final ResetPasswordViewModel _viewModel;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = ResetPasswordViewModel();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() => setState(() {});

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onUpdatePasswordPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _errorMessage = null);

    final result = await _viewModel.submit(
      token: widget.token.trim(),
      newPassword: _passwordController.text,
    );
    if (!mounted) return;

    if (result != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PasswordUpdatedView()),
      );
      return;
    }

    setState(() {
      _errorMessage =
          _viewModel.errorMessage ?? 'Şifre güncellenemedi. Tekrar deneyin.';
    });
  }

  Widget _buildRequirements(String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    final rules = [
      ('En az 8 karakter', value.length >= 8),
      ('En az 1 büyük harf (A–Z)', RegExp(r'[A-Z]').hasMatch(value)),
      ('En az 1 küçük harf (a–z)', RegExp(r'[a-z]').hasMatch(value)),
      ('En az 1 rakam (0–9)', RegExp(r'\d').hasMatch(value)),
    ];
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDE3EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rules
            .map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  children: [
                    Icon(
                      r.$2
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 14,
                      color: r.$2
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFADBDD0),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      r.$1,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: r.$2
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF8A9BB0),
                        fontWeight:
                            r.$2 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
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
                  padding:
                      const EdgeInsets.all(AppSpacing.screenHorizontal),
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
                            constraints:
                                const BoxConstraints(maxWidth: 420),
                            child: SurfaceCard(
                              color: AppColors.surface,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xxl),
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xl,
                                AppSpacing.xl,
                                AppSpacing.xl,
                                AppSpacing.lg,
                              ),
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minHeight: 520),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Logo + başlık
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
                                          const SizedBox(
                                              height: AppSpacing.md),
                                          Text(
                                            'Yeni Şifre Belirle',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles.headlineLg
                                                .copyWith(
                                              color: AppColors.primaryDark,
                                              fontSize: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xxl),

                                      // Input'lar
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          inputDecorationTheme:
                                              InputDecorationTheme(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintStyle: AppTextStyles.bodySm
                                                .copyWith(
                                                    color: _neutralLabel),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.xl),
                                              borderSide: const BorderSide(
                                                  color: _neutralBorder),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.xl),
                                              borderSide: const BorderSide(
                                                  color: _neutralBorder),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.xl),
                                              borderSide: const BorderSide(
                                                color: AppColors.primaryDark,
                                                width: 1.4,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.xl),
                                              borderSide: const BorderSide(
                                                  color: AppColors.error),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.xl),
                                              borderSide: const BorderSide(
                                                color: AppColors.error,
                                                width: 1.4,
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            FormInput(
                                              label: 'Yeni Şifre',
                                              hint: '••••••••',
                                              controller: _passwordController,
                                              obscureText: _obscurePassword,
                                              labelColor: _neutralLabel,
                                              textColor: _neutralText,
                                              hintColor: _neutralLabel,
                                              prefixIconColor: _neutralLabel,
                                              suffixIconColor: _neutralLabel,
                                              prefixIcon: const Icon(
                                                Icons.lock_outline_rounded,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: () => setState(() =>
                                                    _obscurePassword =
                                                        !_obscurePassword),
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Lütfen yeni şifrenizi girin';
                                                }
                                                if (value.length < 8) {
                                                  return 'Şifre en az 8 karakter olmalı';
                                                }
                                                if (!RegExp(r'[A-Z]')
                                                    .hasMatch(value)) {
                                                  return 'Şifre en az bir büyük harf içermeli';
                                                }
                                                if (!RegExp(r'[a-z]')
                                                    .hasMatch(value)) {
                                                  return 'Şifre en az bir küçük harf içermeli';
                                                }
                                                if (!RegExp(r'\d')
                                                    .hasMatch(value)) {
                                                  return 'Şifre en az bir rakam içermeli';
                                                }
                                                return null;
                                              },
                                            ),
                                            _buildRequirements(
                                                _passwordController.text),
                                            const SizedBox(
                                                height: AppSpacing.md),
                                            FormInput(
                                              label: 'Yeni Şifre Tekrar',
                                              hint: '••••••••',
                                              controller:
                                                  _confirmPasswordController,
                                              obscureText:
                                                  _obscureConfirmPassword,
                                              labelColor: _neutralLabel,
                                              textColor: _neutralText,
                                              hintColor: _neutralLabel,
                                              prefixIconColor: _neutralLabel,
                                              suffixIconColor: _neutralLabel,
                                              prefixIcon: const Icon(
                                                Icons.lock_outline_rounded,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: () => setState(() =>
                                                    _obscureConfirmPassword =
                                                        !_obscureConfirmPassword),
                                                icon: Icon(
                                                  _obscureConfirmPassword
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Lütfen şifrenizi tekrar girin';
                                                }
                                                if (value !=
                                                    _passwordController.text) {
                                                  return 'Şifreler eşleşmiyor';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Hata banner
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
                                        label: 'Şifreyi Güncelle',
                                        trailingIcon: Icons.check_rounded,
                                        onPressed: _onUpdatePasswordPressed,
                                        isLoading: _viewModel.isLoading,
                                        backgroundColor: AppColors.primaryDark,
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
