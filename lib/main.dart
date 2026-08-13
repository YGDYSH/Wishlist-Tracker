import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'services/hive_service.dart';
import 'services/session_service.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/session_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await ThemeService.init();
  await SessionService.init();
  if (SessionService.isLoggedIn) {
    await HiveService.openBoxesForCurrentUser();
  }
  await NotificationService.init();
  if (SessionService.isLoggedIn) {
    await NotificationService.rescheduleAllReminders();
  }
  runApp(const WishlistTrackerApp());
}

class WishlistTrackerApp extends StatelessWidget {
  const WishlistTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the theme toggle so the whole app rebuilds when it changes.
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDark,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'Wishlist Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const SessionGate(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginScreen(),
          },
        );
      },
    );
  }
}
