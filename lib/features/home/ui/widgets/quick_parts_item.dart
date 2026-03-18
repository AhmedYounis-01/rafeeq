// quick_parts_item.dart
import 'package:flutter/material.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

class QuickPartsItem extends StatelessWidget {
  const QuickPartsItem({
    super.key,
    required this.title,
    required this.image,
    this.height,
  });

  final String title;
  final String image;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final side   = MediaQuery.of(context).size.shortestSide;
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    // ✅ حجم من shortestSide بدل ScreenUtil
    final itemH   = height ?? (side * 0.38).clamp(120.0, 200.0);
    final imgPad  = screenH * 0.013;
    final lblVPad = screenH * 0.010;
    final fontSize = (screenW * 0.034).clamp(11.0, 16.0);
    final radius   = (side * 0.042).clamp(12.0, 20.0);

    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: itemH,
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ── Image ──
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(imgPad),
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
              ),
              // ── Label ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: lblVPad,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.getGreenGradient(context),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}