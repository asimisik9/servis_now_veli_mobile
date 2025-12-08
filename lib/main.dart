import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/token_manager.dart';
import 'features/auth/view/login_view.dart';
import 'features/main_wrapper/view/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenManager().init();
  runApp(const ServisNowVeliApp());
}

class ServisNowVeliApp extends StatelessWidget {
  const ServisNowVeliApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = TokenManager().accessToken != null;

    return MaterialApp(
      title: 'Servis Now Veli',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const MainWrapper() : const LoginView(),
    );
  }
}
