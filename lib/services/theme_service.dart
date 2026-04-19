import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService._();

  static final ThemeService instance = ThemeService._();
  static const String _themePreferenceKey = 'is_dark_mode';

  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

  bool get isDarkMode => isDarkModeNotifier.value;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkModeNotifier.value = prefs.getBool(_themePreferenceKey) ?? false;
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, isDarkMode);
    isDarkModeNotifier.value = isDarkMode;
  }
}
