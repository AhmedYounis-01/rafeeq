import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';
import '../themes/status_colors.dart';
import '../themes/app_colors.dart';

extension ThemeExtension on BuildContext {
  // Quickly access the Theme
  ThemeData get theme => Theme.of(this);

  // Quickly access the ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;

  // Quickly access the TextTheme
  TextTheme get textTheme => theme.textTheme;

  // Alias for backward compatibility
  TextTheme get textStyle => textTheme;

  // Quickly access StatusColors extension
  StatusColors get statusColors => theme.extension<StatusColors>()!;

  // Check if the current theme is dark mode
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Quickly access the Primary Color
  Color get primaryColor => theme.primaryColor;

  // Quickly access the Scaffold Background Color
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;

  // Quickly access the Primary Gradient
  LinearGradient get primaryGradient => AppColors.primaryGradient;

  // Show custom toast
  void showToast({
    required String title,
    required String message,
    ToastType type = ToastType.success,
  }) {
    ToastUtils.show(context: this, title: title, message: message, type: type);
  }
}
