import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Decides the first screen based on the saved session.
///
/// [SessionService.init] already ran in main(), so the check is synchronous.
class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return SessionService.isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
