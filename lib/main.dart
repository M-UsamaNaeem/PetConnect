import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'utils/themes.dart';

/// Top-level background message handler.
/// MUST be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message received: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Register the background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications + request FCM permission + save token
  await NotificationService.initialize();

  // Check if we should show onboarding
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: PetConnectApp(showOnboarding: showOnboarding),
    ),
  );
}

class PetConnectApp extends StatelessWidget {
  final bool showOnboarding;
  const PetConnectApp({Key? key, required this.showOnboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Pet Connect',
          debugShowCheckedModeBanner: false,
          navigatorKey: NotificationService.navigatorKey,
          theme: AppThemes.modernTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: showOnboarding
              ? const OnboardingScreen()
              : SplashScreen(
                  onThemeToggle: () => themeProvider.toggleTheme(),
                ),
        );
      },
    );
  }
}
