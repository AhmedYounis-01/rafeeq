import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

// ─── Enum ────────────────────────────────────────────────────────────
enum AppDeviceType { mobile, tablet, desktop }

// ─── ResponsiveHelper ────────────────────────────────────────────────
class ResponsiveHelper {
  // ✅ shortestSide بدل width — مش هيتأثر بالـ landscape
  static AppDeviceType getDeviceType(BuildContext context) {
    final side = MediaQuery.of(context).size.shortestSide;

    if (side >= AppConstants.desktopBreakpoint) return AppDeviceType.desktop;
    if (side >= AppConstants.tabletBreakpoint) return AppDeviceType.tablet;
    return AppDeviceType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == AppDeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == AppDeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == AppDeviceType.desktop;

  // ─── Value helpers ──────────────────────────────────────────────
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (getDeviceType(context)) {
      case AppDeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case AppDeviceType.tablet:
        return tablet ?? mobile;
      case AppDeviceType.mobile:
        return mobile;
    }
  }

  static double getResponsiveWidth(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) => value(context, mobile: mobile, tablet: tablet, desktop: desktop);

  static double getResponsiveHeight(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) => value(context, mobile: mobile, tablet: tablet, desktop: desktop);

  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) => value(context, mobile: mobile, tablet: tablet, desktop: desktop);

  // ✅ مضاف — مفيد جداً للـ font sizes
  static double sp(BuildContext context, double base) {
    switch (getDeviceType(context)) {
      case AppDeviceType.desktop:
        return base * 1.4;
      case AppDeviceType.tablet:
        return base * 1.2;
      case AppDeviceType.mobile:
        return base;
    }
  }

  // ✅ مضاف — horizontal padding جاهز للـ tablet centering
  static EdgeInsets horizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (isTablet(context) || isDesktop(context)) {
      final side = ((w - 620) / 2).clamp(24.0, 200.0);
      return EdgeInsets.symmetric(horizontal: side);
    }
    return const EdgeInsets.symmetric(horizontal: 16);
  }
}

// ─── ResponsiveLayout ────────────────────────────────────────────────
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ استخدم الـ helper المصلوح
    return ResponsiveHelper.value(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

// ─── ResponsiveBuilder ───────────────────────────────────────────────
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AppDeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveHelper.getDeviceType(context));
    // ✅ مش محتاج LayoutBuilder هنا — ResponsiveHelper بيعمل نفس الشغل
  }
}