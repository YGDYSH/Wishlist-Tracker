import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await ApiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result.success) {
      final data = result.data;
      final user = data?['user'];
      if (user is Map<String, dynamic>) {
        final id = int.tryParse('${user['id']}');
        final name = user['name'] as String? ?? '';
        final email = user['email'] as String? ?? _emailController.text.trim();
        if (id != null) {
          await SessionService.saveUser(id: id, name: name, email: email);
          await HiveService.openBoxesForCurrentUser();
        }
      }
      if (!mounted) return;
      // Navigate to Home first, then schedule reminders in the background.
      Navigator.of(context).pushReplacementNamed('/home');
      NotificationService.rescheduleAllReminders();
    } else {
      setState(() => _errorMessage = result.message);
    }

    setState(() => _loading = false);
  }

  void _goRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final email = value.trim();
    final valid = email.contains('@') && email.contains('.');
    if (!valid) return 'Email tidak valid';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.spacingLg),
                    Text(
                      'Selamat Datang',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppDimens.spacingXs),
                    Text(
                      'Masuk untuk memantau wishlist kamu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimens.spacingXl),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: AppDimens.spacingMd),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      validator: _passwordValidator,
                      onFieldSubmitted: (_) => _loading ? null : _login(),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppDimens.spacingMd),
                      _ErrorBanner(message: _errorMessage!),
                    ],
                    const SizedBox(height: AppDimens.spacingLg),
                    FilledButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Masuk'),
                    ),
                    const SizedBox(height: AppDimens.spacingMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: _loading ? null : _goRegister,
                          child: const Text('Daftar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppDimens.spacingSm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
