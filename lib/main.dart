import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/view/login_view.dart';

void main() {
  runApp(const ServisNowVeliApp());
}

class ServisNowVeliApp extends StatelessWidget {
  const ServisNowVeliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servis Now Veli',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginView(),
    );
  }
}
