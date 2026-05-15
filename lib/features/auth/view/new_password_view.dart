import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/form_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodel/reset_password_viewmodel.dart';
import 'password_updated_view.dart';
import 'widgets/auth_flow_scaffold.dart';

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
  late final ResetPasswordViewModel _viewModel;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = ResetPasswordViewModel();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onUpdatePasswordPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final result = await _viewModel.submit(
      token: widget.token.trim(),
      newPassword: _passwordController.text,
    );
    if (!mounted) {
      return;
    }

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PasswordUpdatedView(),
        ),
      );
      return;
    }

    if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) => AuthFlowScaffold(
        title: 'Yeni Şifre Belirle',
        description:
            'Hesabınız için güçlü ve kolay hatırlanabilir yeni bir şifre oluşturun.',
        badge: 'Güvenli Güncelleme',
        icon: Icons.password_rounded,
        showBackButton: true,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormInput(
                label: 'Yeni Şifre',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
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
                    return 'Lutfen yeni sifrenizi girin';
                  }
                  if (value.length < 6) {
                    return 'Sifre en az 6 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              FormInput(
                label: 'Yeni Şifre Tekrar',
                hint: '••••••••',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lutfen yeni sifrenizi tekrar girin';
                  }
                  if (value != _passwordController.text) {
                    return 'Sifreler birbiri ile ayni olmali';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Şifreyi Güncelle',
                trailingIcon: Icons.check_rounded,
                onPressed: _onUpdatePasswordPressed,
                isLoading: _viewModel.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
