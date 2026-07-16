import 'package:flutter/material.dart';

import 'package:rafeeq/core/themes/app_colors.dart';

class LastReadRibbon extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const LastReadRibbon({
    super.key,
    required this.color,
    this.width = 22,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, height),
    painter: RibbonPainter(color: color),
  );
}

class RibbonPainter extends CustomPainter {
  final Color color;
  const RibbonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width / 2, size.height - 12)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = color.withValues(alpha: 0.85),
    );
    canvas.drawLine(
      const Offset(4, 0),
      Offset(4, size.height - 14),
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.25)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant RibbonPainter old) => old.color != color;
}
