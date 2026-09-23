import 'package:flutter/material.dart';

abstract final class TasbihTextStyles {
  static TextStyle amiriBold(double size, Color color) => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: color,
  );

  static TextStyle amiri(
    double size,
    Color color, {
    FontStyle style = FontStyle.normal,
    FontWeight weight = FontWeight.normal,
    double height = 1.0,
  }) => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: size,
    color: color,
    fontStyle: style,
    fontWeight: weight,
    height: height,
  );

  static TextStyle amiriQuran(
    double size,
    Color color, {
    double height = 1.8,
  }) => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: size,
    color: color,
    height: height,
  );
}

class TasbihConfig {
  final double side, width, height;
  TasbihConfig(BuildContext ctx)
    : side = MediaQuery.sizeOf(ctx).shortestSide,
      width = MediaQuery.sizeOf(ctx).width,
      height = MediaQuery.sizeOf(ctx).height;
  bool get isTablet => side >= 600;
  double get titleFont => (side * 0.058).clamp(18.0, 28.0);
  double get dhikrFont => (side * 0.046).clamp(15.0, 22.0);
  double get labelFont => (side * 0.033).clamp(11.0, 16.0);
  double get hPad => isTablet ? 28.0 : 18.0;
}

enum HapticFeedbackType { light, medium, heavy, select }
