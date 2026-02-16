import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/token_manager.dart';
import 'core/services/notification_service.dart';
import 'core/state/selected_student_state.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/view/login_view.dart';
import 'features/main_wrapper/view/main_wrapper.dart';
import 'features/notifications/viewmodel/notification_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiConstants.ensureBuildConfig();

  // Firebase init
  await Firebase.initializeApp();

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Token manager
  await TokenManager().init();

  // Recover session from refresh token if needed
  if (TokenManager().accessToken == null &&
      TokenManager().refreshToken != null) {
    await AuthService().refreshSession();
  }

  // Backfill user profile for older sessions that stored only tokens
  if (TokenManager().accessToken != null && TokenManager().user == null) {
    await AuthService().fetchCurrentUser();
  }

  // Notification service
  await NotificationService().init();

  runApp(const ServisNowVeliApp());
}

class ServisNowVeliApp extends StatefulWidget {
  const ServisNowVeliApp({super.key});

  @override
  State<ServisNowVeliApp> createState() => _ServisNowVeliAppState();
}

class _ServisNowVeliAppState extends State<ServisNowVeliApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<void>? _sessionExpiredSubscription;

  @override
  void initState() {
    super.initState();

    _sessionExpiredSubscription =
        AuthService().sessionExpiredStream.listen((_) {
      final navigator = _navigatorKey.currentState;
      if (navigator == null) {
        return;
      }

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    });

    // Register FCM token if already logged in
    if (TokenManager().accessToken != null) {
      NotificationService().getAndRegisterToken();
    }
  }

  @override
  void dispose() {
    _sessionExpiredSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = TokenManager().hasSession &&
        (TokenManager().user == null || TokenManager().user!.isParent);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => SelectedStudentState()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Servis Now Veli',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: isLoggedIn ? const MainWrapper() : const LoginView(),
      ),
    );
  }
}
