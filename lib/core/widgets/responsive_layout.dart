import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AppDeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        AppDeviceType deviceType;
        
        if (constraints.maxWidth >= AppConstants.desktopBreakpoint) {
          deviceType = AppDeviceType.desktop;
        } else if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
          deviceType = AppDeviceType.tablet;
        } else {
          deviceType = AppDeviceType.mobile;
        }
        
        return builder(context, deviceType);
      },
    );
  }
}

enum AppDeviceType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.tabletBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.tabletBreakpoint && width < AppConstants.desktopBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;
  }
  
  static AppDeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= AppConstants.desktopBreakpoint) {
      return AppDeviceType.desktop;
    } else if (width >= AppConstants.tabletBreakpoint) {
      return AppDeviceType.tablet;
    } else {
      return AppDeviceType.mobile;
    }
  }
  
  static double getResponsiveWidth(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case AppDeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case AppDeviceType.tablet:
        return tablet ?? mobile;
      case AppDeviceType.mobile:
        return mobile;
    }
  }
  
  static double getResponsiveHeight(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case AppDeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case AppDeviceType.tablet:
        return tablet ?? mobile;
      case AppDeviceType.mobile:
        return mobile;
    }
  }
  
  static EdgeInsets getResponsivePadding(BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case AppDeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case AppDeviceType.tablet:
        return tablet ?? mobile;
      case AppDeviceType.mobile:
        return mobile;
    }
  }
}
