import 'package:flutter/material.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'qibla_config.dart';

class DirectionLabels extends StatelessWidget {
  final double size;
  final bool isDark;
  final QiblaConfig cfg;

  const DirectionLabels({
    super.key,
    required this.size,
    required this.isDark,
    required this.cfg,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: isDark ? AppColors.white : const Color(0xFF2D5F3F),
      fontWeight: FontWeight.bold,
      fontSize: (size * 0.055).clamp(13.0, 18.0),
      letterSpacing: 1.2,
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: const Alignment(0, -0.68),
            child: Text(
              "N",
              style: style.copyWith(
                color: const Color(0xFF029E50),
                fontSize: style.fontSize! + 2,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.68, 0),
            child: Text("E", style: style),
          ),
          Align(
            alignment: const Alignment(0, 0.68),
            child: Text("S", style: style),
          ),
          Align(
            alignment: const Alignment(-0.68, 0),
            child: Text("W", style: style),
          ),
        ],
      ),
    );
  }
}
