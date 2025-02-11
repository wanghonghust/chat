import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';

class ThemeNotifier with ChangeNotifier {
  final ThemeData _currentTheme;
  BuildContext context;
  ThemeMode _themeMode;
  WindowEffect _effect = WindowEffect.mica;

  ThemeNotifier(this._currentTheme, this.context, this._themeMode);

  ThemeData get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;
  WindowEffect get effect => _effect;

  void init() {
    Window.setEffect(
      effect: _effect,
      dark: isDarkMode,
    );
  }

  void setEffect(WindowEffect effect) {
    _effect = effect;
    Window.setEffect(
      effect: _effect,
      dark: isDarkMode,
    );
    notifyListeners();
  }

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    Window.setEffect(
      effect: _effect,
      dark: isDarkMode,
    );
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
