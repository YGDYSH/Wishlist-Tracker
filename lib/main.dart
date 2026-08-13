import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'services/hive_service.dart';
import 'services/session_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/session_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await SessionService.init();
  if (SessionService.isLoggedIn) {
    await HiveService.openBoxesForCurrentUser();
  }
  runApp(const WishlistTrackerApp());
}

class WishlistTrackerApp extends StatelessWidget {
  const WishlistTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wishlist Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SessionGate(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
