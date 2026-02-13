import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class AppTheme {
  static ThemeData get lightTheme => getLightTheme();

  static ThemeData get darkTheme => getDarkTheme();
}
