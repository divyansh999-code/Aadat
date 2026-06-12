import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _userName = '';
  bool _preferencesLoaded = false;

  ThemeMode get themeMode => _themeMode;
  String get userName => _userName;
  bool get preferencesLoaded => _preferencesLoaded;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _userName = prefs.getString('user_name') ?? '';
    _preferencesLoaded = true;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
  }
}
