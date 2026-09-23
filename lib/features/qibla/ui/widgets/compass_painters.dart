import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

class LockGlowPainter extends CustomPainter {
  final double intensity;
  final bool isDark;

  LockGlowPainter({required this.intensity, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.88;
    final glowColor = isDark ? AppColors.primaryDark : AppColors.primary;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = glowColor.withValues(alpha: 0.08 + 0.18 * intensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 + 14 * intensity),
    );

    canvas.drawCircle(
      center,
      radius * 0.75,
      Paint()
        ..color = glowColor.withValues(alpha: 0.05 + 0.1 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant LockGlowPainter oldDelegate) =>
      oldDelegate.intensity != intensity || oldDelegate.isDark != isDark;
}

/// Draws a subtle inner decorative ring inside the compass.
class InnerRingPainter extends CustomPainter {
  final bool isDark;
  final bool isLocked;

  InnerRingPainter({required this.isDark, required this.isLocked});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final color = isLocked
        ? const Color(0xFF029E50)
        : (isDark ? const Color(0xFF1B7A4A) : const Color(0xFF3A9D6A));

    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: isDark ? 0.18 : 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner ring
    canvas.drawCircle(
      center,
      radius * 0.82,
      Paint()
        ..color = color.withValues(alpha: isDark ? 0.10 : 0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 8 small diamond marks
    final diamondPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.35 : 0.25)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (math.pi / 180);
      final cx = center.dx + math.cos(angle) * radius;
      final cy = center.dy + math.sin(angle) * radius;
      final half = i % 2 == 0 ? 3.5 : 2.5;
      final path = Path()
        ..moveTo(cx, cy - half)
        ..lineTo(cx + half * 0.6, cy)
        ..lineTo(cx, cy + half)
        ..lineTo(cx - half * 0.6, cy)
        ..close();
      canvas.drawPath(path, diamondPaint);
    }
  }

  @override
  bool shouldRepaint(covariant InnerRingPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.isLocked != isLocked;
}

class OrnamentalRingPainter extends CustomPainter {
  final bool isDark;

  OrnamentalRingPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.84;
    final baseColor = isDark
        ? const Color(0xFF1B7A4A)
        : const Color(0xFF3A9D6A);

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = baseColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final petalPaint = Paint()
      ..color = baseColor.withValues(alpha: isDark ? 0.4 : 0.25)
      ..style = PaintingStyle.fill;

    const int petalCount = 16;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * (360 / petalCount)) * (math.pi / 180);
      final p1 = Offset(
        center.dx + math.cos(angle - 0.1) * (innerRadius * 1.05),
        center.dy + math.sin(angle - 0.1) * (innerRadius * 1.05),
      );
      final p2 = Offset(
        center.dx + math.cos(angle + 0.1) * (innerRadius * 1.05),
        center.dy + math.sin(angle + 0.1) * (innerRadius * 1.05),
      );
      final pTip = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(
          center.dx + math.cos(angle) * (outerRadius * 0.9),
          center.dy + math.sin(angle) * (outerRadius * 0.9),
          pTip.dx,
          pTip.dy,
        )
        ..quadraticBezierTo(
          center.dx + math.cos(angle) * (outerRadius * 0.9),
          center.dy + math.sin(angle) * (outerRadius * 0.9),
          p2.dx,
          p2.dy,
        )
        ..close();
      canvas.drawPath(path, petalPaint);
    }

    final arcPaint = Paint()
      ..color = baseColor.withValues(alpha: isDark ? 0.2 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 12; i++) {
      final startAngle = (i * 30 - 15) * (math.pi / 180);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius * 0.95),
        startAngle,
        30 * (math.pi / 180),
        false,
        arcPaint,
      );
    }

    final dotPaint = Paint()
      ..color = baseColor.withValues(alpha: isDark ? 0.4 : 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 72; i++) {
      final angle = (i * 5) * (math.pi / 180);
      final pt = Offset(
        center.dx + math.cos(angle) * (outerRadius * 0.92),
        center.dy + math.sin(angle) * (outerRadius * 0.92),
      );
      final r = (i % 6 == 0) ? 2.5 : 1.2;
      canvas.drawCircle(pt, r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OrnamentalRingPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class CompassTicksPainter extends CustomPainter {
  final bool isDark;

  CompassTicksPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final tickColor = isDark ? Colors.white : const Color(0xFF2D5F3F);

    for (int i = 0; i < 360; i += 5) {
      final angle = i * (math.pi / 180);
      final isMajor = i % 90 == 0;
      final isMinor = i % 30 == 0;

      final outerR = radius;
      final innerR = isMajor
          ? radius - 12
          : (isMinor ? radius - 8 : radius - 5);

      final paint = Paint()
        ..color = isMajor
            ? tickColor.withValues(alpha: 0.8)
            : (isMinor
                  ? tickColor.withValues(alpha: 0.4)
                  : tickColor.withValues(alpha: 0.15))
        ..strokeWidth = isMajor ? 2.0 : (isMinor ? 1.2 : 0.5)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * innerR,
          center.dy + math.sin(angle) * innerR,
        ),
        Offset(
          center.dx + math.cos(angle) * outerR,
          center.dy + math.sin(angle) * outerR,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CompassTicksPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class CompassNeedlePainter extends CustomPainter {
  final bool isDark;

  CompassNeedlePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfW = size.width * 0.06;
    final len = size.height * 0.42;

    final Color primaryGreen = isDark
        ? const Color(0xFF029E50)
        : AppColors.primary;
    final Color secondaryGreen = isDark
        ? const Color(0xFF1B7A4A)
        : const Color(0xFF3A9D6A);
    final Color darkGreen = isDark
        ? const Color(0xFF0F2D1E)
        : const Color(0xFF2D7A4A);

    final northPath = Path()
      ..moveTo(center.dx, center.dy - len)
      ..lineTo(center.dx - halfW, center.dy)
      ..lineTo(center.dx + halfW, center.dy)
      ..close();

    canvas.drawPath(
      northPath,
      Paint()
        ..shader =
            LinearGradient(
              colors: [primaryGreen, secondaryGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx, center.dy - len),
                Offset(center.dx, center.dy),
              ),
            ),
    );

    final southPath = Path()
      ..moveTo(center.dx, center.dy + len)
      ..lineTo(center.dx - halfW, center.dy)
      ..lineTo(center.dx + halfW, center.dy)
      ..close();

    canvas.drawPath(
      southPath,
      Paint()
        ..shader =
            LinearGradient(
              colors: [darkGreen, secondaryGreen],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx, center.dy),
                Offset(center.dx, center.dy + len),
              ),
            ),
    );

    final eastPath = Path()
      ..moveTo(center.dx + len, center.dy)
      ..lineTo(center.dx, center.dy - halfW)
      ..lineTo(center.dx, center.dy + halfW)
      ..close();

    canvas.drawPath(
      eastPath,
      Paint()
        ..shader =
            LinearGradient(
              colors: [primaryGreen, secondaryGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx, center.dy - halfW),
                Offset(center.dx + len, center.dy + halfW),
              ),
            ),
    );

    final westPath = Path()
      ..moveTo(center.dx - len, center.dy)
      ..lineTo(center.dx, center.dy - halfW)
      ..lineTo(center.dx, center.dy + halfW)
      ..close();

    canvas.drawPath(
      westPath,
      Paint()
        ..shader =
            LinearGradient(
              colors: [darkGreen, secondaryGreen],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx - len, center.dy - halfW),
                Offset(center.dx, center.dy + halfW),
              ),
            ),
    );

    final diagLen = len * 0.65;
    final diagW = halfW * 0.6;
    final diagPaint = Paint()
      ..color = secondaryGreen.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final angle = (45 + i * 90) * (math.pi / 180);
      final tipX = center.dx + math.cos(angle) * diagLen;
      final tipY = center.dy + math.sin(angle) * diagLen;
      final perpAngle = angle + math.pi / 2;

      final p = Path()
        ..moveTo(tipX, tipY)
        ..lineTo(
          center.dx + math.cos(perpAngle) * diagW,
          center.dy + math.sin(perpAngle) * diagW,
        )
        ..lineTo(
          center.dx - math.cos(perpAngle) * diagW,
          center.dy - math.sin(perpAngle) * diagW,
        )
        ..close();

      canvas.drawPath(p, diagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CompassNeedlePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
