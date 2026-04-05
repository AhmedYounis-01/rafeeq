import 'package:flutter/material.dart';

class AppColors {
  // --- Core Colors (From Your Images) ---
  static const Color primary = Color(0xFF028544); // Light Main
  static const Color primaryDark = Color(0xFF029E50); // Dark Main
  static const Color secondary = Color(0xFFC9A24D); // Light Secondary
  static const Color secondaryDark = Color(0xFFCFAC61); // Dark Secondary

  // Backgrounds
  static const Color backgroundLight = Color(0xFFFFFFFF); // Soft green mist
  static const Color backgroundCard = Color(0xFFF1F8F4);
  static const Color backgroundDark = Color(0xFF0F1412);
  static const Color backgroundCardDark = Color(0xFF161C1A);
  // Status & Common
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color error = Color(0xFFF04248);
  static const Color success = Color(0xFF00DF80);
  static const Color warning = Color(0xFFFFD21E);
  static const Color info = Color(0xFF2196F3);
  static const Color transparent = Colors.transparent;

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF6D6D6D);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Contextual Getters (Match the code usage)
  static Color getPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primaryDark : primary;

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? backgroundDark
      : backgroundLight;

  static Color cardBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? backgroundCardDark
      : backgroundCard;

  // Gradients
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF014D28), primary],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static LinearGradient darkGradient = const LinearGradient(
    colors: [Color(0xFF014D28), primaryDark],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static LinearGradient getGreenGradient(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkGradient
      : primaryGradient;

  // --- Support for legacy lints & other widgets ---
  static const Color navBackground = backgroundLight;
  static const Color navBackgroundDark = Color(0xFF1A1A1A);
  static const Color navUnselected = Color(0xFFB0B0B0);
  static const Color navSelected = primary;

  static const Color containerLight = Color(0xFFF1F8F4);
  static const Color containerDark = backgroundCardDark;
  static const Color primaryLight3 = Color(0xFFF0F9F5);
  static const Color outlineLight = Color(0xFFE0E0E0);
  static const Color outlineDark = Color(0xFF3A3A3A);
  static const Color brightGrey = Color(0xFFE0E0E0);
  static const Color toastBgPrimary = Color(0xFF242C32);
  static const Color toastTextPrimary = Color(0xFFFFFFFF);
  static const Color toastTextSecondary = Color(0xFFB0B0B0);
}
