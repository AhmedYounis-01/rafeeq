import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

ThemeData getDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    fontFamily: 'Tajawal',
    scaffoldBackgroundColor: AppColors.backgroundDark,
    canvasColor: AppColors.backgroundDark,

    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      primaryContainer: AppColors.gunmetalGray,
      surface: AppColors.backgroundDark,
      surfaceContainer: AppColors.backgroundDark,
      surfaceContainerLow: AppColors.backgroundDark,
      surfaceContainerHigh: AppColors.gunmetalGray,
      outline: AppColors.outlineDark,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSurface: AppColors.white,
      onSurfaceVariant: AppColors.brightGrey,
      onError: AppColors.error,
    ),

    // App bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    // Text theme (similar to light but with white colors)
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.ghostWhite,
      ),
      displayMedium: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.ghostWhite,
      ),
      displaySmall: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.ghostWhite,
      ),
      headlineLarge: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.ghostWhite,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.ghostWhite,
      ),
      headlineSmall: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.ghostWhite,
      ),
      titleLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.ghostWhite,
      ),
      titleMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.ghostWhite,
      ),
      titleSmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.brightGrey,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.ghostWhite,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.ghostWhite,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.brightGrey,
      ),
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.brightGrey,
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.ghostWhite,
      ),
      labelSmall: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.brightGrey,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ghostWhite,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.containerDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.outlineDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.outlineDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.containerDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    ),

    // Text selection theme
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.ghostWhite,
      selectionColor: AppColors.ghostWhite.withValues(alpha: 0.3),
      selectionHandleColor: AppColors.ghostWhite,
    ),

    // Card theme
    cardTheme: CardThemeData(
      color: AppColors.gunmetalGray,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
    // extensions: [
    //   StatusColors(
    //     success: AppColors.success,
    //     warning: AppColors.warning,
    //     error: AppColors.error,
    //     info: AppColors.info,
    //   ),
    // ],
  );
}
