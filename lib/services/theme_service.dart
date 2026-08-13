import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/theme/app_theme.dart';

class ThemeService {
  ThemeService._();

  static final ValueNotifier<bool> _isDark = ValueNotifier<bool>(false);
  static ValueNotifier<bool> get isDark => _isDark;

  static Future<void> init() async {
    final box = await Hive.openBox('theme');
    final theme = box.get('theme');
    if (theme == 'dark') {
      _isDark.value = true;
    } else if (theme == 'light') {
      _isDark.value = false;
    }
  }

  static Future<void> toggleTheme() async {
    _isDark.value = !_isDark.value;
    final box = await Hive.openBox('theme');
    await box.put('theme', _isDark.value ? 'dark' : 'light');
  }

  static ThemeData getTheme(BuildContext context) {
    if (_isDark.value) return AppTheme.darkTheme;
    return AppTheme.lightTheme;
  }
}