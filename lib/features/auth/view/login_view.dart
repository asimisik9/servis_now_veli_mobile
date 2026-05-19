import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/form_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/surface_card.dart';
import '../../main_wrapper/view/main_wrapper.dart';
import 'forgot_password_view.dart';
import '../viewmodel/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static const Color _neutralText = Color(0xFF4B5563);
  static const Color _neutralLabel = Color(0xFF6B7280);
  static const Color _neutralBorder = Color(0xFFE5E7EB);

  late final LoginViewModel _viewModel;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      final success = await _viewModel.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      }
    }
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
                    child: Center(
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
                                      "ServisNow",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.headlineLg.copyWith(
                                        color: AppColors.primaryDark,
                                        fontSize: 28,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xxs),
                                    Text(
                                      "Okul servisinde anlık takip, tam güven.",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: _neutralText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    inputDecorationTheme: InputDecorationTheme(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintStyle: AppTextStyles.bodySm.copyWith(
                                        color: _neutralLabel,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.xl),
                                        borderSide: const BorderSide(
                                          color: _neutralBorder,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.xl),
                                        borderSide: const BorderSide(
                                          color: _neutralBorder,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.xl),
                                        borderSide: const BorderSide(
                                          color: AppColors.primaryDark,
                                          width: 1.4,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.xl),
                                        borderSide: const BorderSide(
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.xl),
                                        borderSide: const BorderSide(
                                          color: AppColors.primaryDark,
                                          width: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      FormInput(
                                        label: "E-posta",
                                        hint: "ornek@email.com",
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
                                          if (value == null || value.isEmpty) {
                                            return 'Lütfen e-posta adresinizi girin';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Geçerli bir e-posta adresi girin';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      FormInput(
                                        label: "Şifre",
                                        hint: "••••••••",
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
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Lütfen şifrenizi girin';
                                          }
                                          if (value.length < 6) {
                                            return 'Şifre en az 6 karakter olmalıdır';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordView(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      "Şifremi Unuttum",
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: _neutralLabel,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_viewModel.errorMessage != null) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEB),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFFFCDD2),
                                      ),
                                    ),
                                    child: const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Color(0xFFD32F2F),
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Giriş bilgileriniz hatalıdır.',
                                            style: TextStyle(
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
                                  label: "Giriş Yap",
                                  onPressed: _onLoginPressed,
                                  isLoading: _viewModel.isLoading,
                                  backgroundColor: AppColors.primaryDark,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  "Hesabınız yok mu? Okulunuzla iletişime geçin.",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: _neutralText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
