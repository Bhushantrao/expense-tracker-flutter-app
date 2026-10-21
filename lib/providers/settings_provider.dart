import 'package:flutter/material.dart';
import '../services/database_service.dart';

class SettingsProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  String _currencyCode = 'INR';
  String _currencySymbol = '₹';
  ThemeMode _themeMode = ThemeMode.system;
  String _userName = 'Alex';

  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  ThemeMode get themeMode => _themeMode;
  String get userName => _userName;

  SettingsProvider() {
    loadSettings();
  }

  void loadSettings() {
    _currencyCode = _db.getSetting<String>('currencyCode', 'INR');
    _currencySymbol = _db.getSetting<String>('currencySymbol', '₹');
    final modeStr = _db.getSetting<String>('themeMode', 'system');
    _themeMode = _parseThemeMode(modeStr);
    _userName = _db.getSetting<String>('userName', 'Alex');
    notifyListeners();
  }

  Future<void> setCurrency(String code, String symbol) async {
    _currencyCode = code;
    _currencySymbol = symbol;
    await _db.setSetting('currencyCode', code);
    await _db.setSetting('currencySymbol', symbol);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    await _db.setSetting('themeMode', modeStr);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _db.setSetting('userName', name);
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String val) {
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
