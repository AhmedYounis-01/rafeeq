import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QiblaConfig {
  final BuildContext context;
  final double shortestSide;

  QiblaConfig(this.context)
      : shortestSide = MediaQuery.of(context).size.shortestSide;

  bool get isTablet => shortestSide >= 600;

  double get kaabaSize => isTablet ? 150 : 70.w;
  double get arrowSize => isTablet ? 80 : 48.w;
  double get qiblaMarkerSize => isTablet ? 100 : 60.w;
  double get labelFontSize => isTablet ? 24 : 18.sp;
  double get bodyFontSize => isTablet ? 18 : 15.sp;
  double get iconSize => isTablet ? 36 : 28.sp;
  double get btnHeight => isTablet ? 64 : 54.h;
  double get hPad => isTablet ? shortestSide * 0.08 : 32.w;
  double get compassSize => isTablet ? 480 : 280.w;
  double get degFontSize => isTablet ? 32 : 24.sp;
}

double calculateOffset(double deviceDirection, double qiblahDirection) {
  double diff = qiblahDirection - deviceDirection;
  while (diff > 180) {
    diff -= 360;
  }
  while (diff < -180) {
    diff += 360;
  }
  return diff;
}
