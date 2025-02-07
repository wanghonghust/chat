import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  final ThemeData _currentTheme;
  BuildContext context;
  ThemeMode _themeMode;

  ThemeNotifier(this._currentTheme, this.context, this._themeMode);

  ThemeData get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system &&
        MediaQuery.of(context).platformBrightness == Brightness.dark) {
      return true;
    }
    return _themeMode == ThemeMode.dark;
  }
}
