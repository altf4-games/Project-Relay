import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';
  static const _accentColorKey = 'accent_color';
  static const _biometricKey = 'biometric_enabled';

  ThemeMode _themeMode = ThemeMode.dark;
  Color _accentColor = const Color(0xFF00FF94);
  bool _isBiometricEnabled = false; // Disabled by default

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  bool get isBiometricEnabled => _isBiometricEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 2;
    _themeMode = ThemeMode.values[themeModeIndex];

    final colorValue = prefs.getInt(_accentColorKey) ?? 0xFF00FF94;
    _accentColor = Color(colorValue);

    _isBiometricEnabled = prefs.getBool(_biometricKey) ?? false;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool enabled) async {
    _isBiometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
    notifyListeners();
  }
}
