import 'package:flutter/material.dart';
import 'package:gaana/theme/dark_mode.dart';
import 'package:gaana/theme/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;

  // Getter for current theme
  ThemeData get themeData => _themeData;

  // Check if current theme is dark
  bool get isDarkMode => _themeData == darkMode;

  // Setter to change theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners(); // Trigger UI update
  }

  // Toggle between light and dark
  void toggleTheme() {
    themeData = _themeData == lightMode ? darkMode : lightMode;
  }
}