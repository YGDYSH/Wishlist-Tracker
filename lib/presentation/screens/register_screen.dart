import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await ApiService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil, silakan login.')),
      );
      Navigator.of(context).pop(); // back to Login
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final email = value.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'Email tidak valid';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  String? _confirmValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != _passwordController.text) return 'Password tidak sama';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
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
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _nameValidator,
                    ),
                    const SizedBox(height: AppDimens.spacingMd),
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
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      validator: _passwordValidator,
                    ),
                    const SizedBox(height: AppDimens.spacingMd),
                    TextFormField(
                      controller: _confirmController,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      validator: _confirmValidator,
                      onFieldSubmitted: (_) => _loading ? null : _register(),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppDimens.spacingMd),
                      Container(
                        padding: const EdgeInsets.all(AppDimens.spacingMd),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusMd,
                          ),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppDimens.spacingSm),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimens.spacingLg),
                    FilledButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Daftar'),
                    ),
                    const SizedBox(height: AppDimens.spacingMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Masuk'),
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
