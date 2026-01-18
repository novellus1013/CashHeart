import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  final SharedPreferences? _prefs;

  ThemeProvider([this._prefs]) {
    if (_prefs != null) {
      final isDark = _prefs.getBool(_themeKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  /// main()에서 호출하여 초기화된 ThemeProvider 반환
  static Future<ThemeProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeProvider(prefs);
  }

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _saveTheme();
  }

  Future<void> setDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _saveTheme();
  }

  Future<void> _saveTheme() async {
    try {
      if (_prefs != null) {
        await _prefs.setBool(_themeKey, isDarkMode);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_themeKey, isDarkMode);
      }
    } catch (e) {
      debugPrint('ThemeProvider: 테마 저장 실패 - $e');
    }
  }
}
