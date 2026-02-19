import 'package:flutter/material.dart';

class AppColors {
  // Main brand color
  // Main brand color (warm yellow)
  static const Color primary = Color(0xFFFFB030); // #FFB030

  // Darker variant for contrast / dark mode
  static const Color primaryDark = Color(0xFFB36F00);
  static const Color primaryVariant = Color(
    0xFF874D14,
  ); // use secondary as variant

  // Lighter grey for secondary text in dark mode
  static const Color brightGrey = Color(0xFFE0E0E0);

  // Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF262729);

  // Transparent colors
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);

  // Primary text color (near black)
  static const Color nearBlackGreen = Color(0xFF1F1F1F); // #1F1F1F
  static const Color ghostWhite = Color(0xFFF6F7F9);
  static const Color textGreen = Color(0xFF27c08d);

  // Muted sage green  & for hinted text
  static const Color mutedSageGreen = Color(0xFF668275);
  static const Color coolGray = Color(0xFF8A8B8D);

  // Legacy name for primary color
  static const Color deepTealGreen = primary;

  // Light mint gray & for container background
  static const Color lightMintGray = Color(0xFFF2F5F2);

  // (Soft off-white green - dark grey)  & for  text field background
  static const Color softOffWhiteGreen = Color(0xFFF0F5F2);
  static const Color gunmetalGray = Color(0xFF3B3C3E);

  // toast colors
  static const Color success = Color(0xFF00DF80); // Green
  static const Color warning = Color(0xFFFFD21E); // Yellow
  static const Color error = Color(0xFFF04248); // Red
  static const Color info = Color(0xFF2196F3); // Blue (generic info)

  // toast background colors
  static const Color toastBgPrimary = Color(0xFF242C32);
  static const Color toastBgSecondary = Color(0xFF303746);

  // toast text colors
  static const Color toastTextPrimary = Color(0xFFFFFFFF);
  static const Color toastTextSecondary = Color(0xFFC8C5C5);

  // Border and Outline colors
  static const Color outlineLight = Color(0xFFE0E0E0); // grey.shade300
  static const Color outlineDark = Color(0xFF616161); // grey.shade700

  // Container and Fill colors
  static const Color containerLight = Color(0xFFF0F5F0); // Light greenish grey
  static const Color containerDark = Color(0xFF212121); // grey.shade900

  // Legacy & Basic colors (needed for existing code)
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color secondary = Color(0xFF874D14); // #874D14 (brownish)
  static const Color textPrimary = nearBlackGreen;
  static const Color textSecondary = Color(0xFF6D6D6D);
  static const Color textHint = coolGray;
  // Navigation unselected color (light tan) used for unselected icons/labels
  static const Color navUnselected = Color(0xFFB08A5A);
  // Navigation background (slightly warm off-white)
  static const Color navBackground = Color(0xFFF8F5F0);
  // Navigation selected color (used for selected icon/text)
  static const Color navSelected = Color(0xFF844C12); // #844c12
  static const Color lightBorder = outlineLight;
  static const Color darkBorder = outlineDark;
  static const Color lightBackground = backgroundLight;
  static const Color darkBackground = backgroundDark;
  static const Color lightCardBackground = white;
  static const Color darkCardBackground = gunmetalGray;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
