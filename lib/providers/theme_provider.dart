import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBoxName = 'theme_settings';
  static const String _isDarkModeKey = 'is_dark_mode';

  Box? _box;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> initialize() async {
    _box = await Hive.openBox(_themeBoxName);
    _isDarkMode = _box?.get(_isDarkModeKey, defaultValue: false) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _box?.put(_isDarkModeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _box?.put(_isDarkModeKey, _isDarkMode);
      notifyListeners();
    }
  }

  String get themeName => _isDarkMode ? 'Dark' : 'Light';
}
