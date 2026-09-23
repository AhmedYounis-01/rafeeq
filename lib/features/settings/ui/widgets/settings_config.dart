import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsConfig {
  final BuildContext context;
  final double shortestSide;

  SettingsConfig(this.context)
      : shortestSide = MediaQuery.of(context).size.shortestSide;

  bool get isTablet => shortestSide >= 600;

  double get appBarHeight => isTablet ? 180.h : 140.h;
  double get sidePadding => isTablet ? 40.w : 20.w;
  double get sectionSpacing => isTablet ? 40.h : 28.h;
  double get tileInsidePadding => isTablet ? 20.h : 14.h;
  double get iconContainerSize => isTablet ? 50.w : 38.w;
  double get iconSize => isTablet ? 24.sp : 20.sp;
  double get toggleHeight => isTablet ? 56.h : 46.h;
}
