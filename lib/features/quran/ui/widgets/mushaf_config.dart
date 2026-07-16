import 'package:flutter/material.dart';

// ─── Responsive Config ────────────────────────────────────────────────────
class MushafConfig {
  final double shortestSide;
  MushafConfig(BuildContext context)
    : shortestSide = MediaQuery.of(context).size.shortestSide;

  bool get isTablet => shortestSide >= 600;

  double get pageNumFontSize => (shortestSide * 0.085).clamp(26.0, 46.0);
  double get overlayLabelSize => (shortestSide * 0.028).clamp(10.0, 16.0);
  double get overlayJuzSize => (shortestSide * 0.048).clamp(16.0, 26.0);
  double get overlaySurahSize => (shortestSide * 0.042).clamp(14.0, 24.0);
  double get surahNameFontSize => (shortestSide * 0.058).clamp(18.0, 32.0);

  double get maxSheetWidth => isTablet ? 580.0 : double.infinity;
  double get playerLabelSize => (shortestSide * 0.038).clamp(13.0, 20.0);
  double get playerBtnSize => (shortestSide * 0.1).clamp(36.0, 56.0);
  double get optionBtnSize => (shortestSide * 0.155).clamp(54.0, 80.0);
  double get optionFontSize => (shortestSide * 0.032).clamp(11.0, 16.0);
  double get headerBtnSize => (shortestSide * 0.1).clamp(34.0, 54.0);
  double get headerCircleSize => (shortestSide * 0.09).clamp(30.0, 48.0);
  double get headerIconSize => (shortestSide * 0.05).clamp(18.0, 28.0);
}
