import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../main_wrapper/view/main_wrapper.dart';
import '../viewmodel/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel _viewModel;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş Başarılı!")),
        );
      } else if (mounted && _viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05; // 5% of screen width

    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: AnimatedBuilder(
              animation: _viewModel,
              builder: (context, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo or Title Area
                      SizedBox(height: size.height * 0.05),
                      Image.asset(
                        'assets/logo.jpeg',
                        height: size.height * 0.1,
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        "ServisNow Veli",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.height * 0.035,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        "Öğrenci Takip Sistemi",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.height * 0.02,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.08),

                      // Form Fields
                      CustomTextField(
                        label: "E-Posta",
                        hint: "ornek@email.com",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: AppColors.primary),
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
                      SizedBox(height: size.height * 0.02),
                      CustomTextField(
                        label: "Şifre",
                        hint: "******",
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.primary),
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
                      SizedBox(height: size.height * 0.05),

                      // Login Button
                      CustomButton(
                        text: "Giriş Yap",
                        onPressed: _onLoginPressed,
                        isLoading: _viewModel.isLoading,
                      ),

                      SizedBox(height: size.height * 0.05),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
