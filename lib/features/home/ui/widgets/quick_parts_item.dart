// ─── QuickPartsItem ───────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
 
class QuickPartsItem extends StatelessWidget {
  const QuickPartsItem({
    super.key,
    required this.title,
    required this.image,
    // ارتفاع بيتمرر من QuickParts عشان يتحسب بشكل مركزي
    this.height,
  });
 
  final String title;
  final String image;
  final double? height;
 
  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final screenH = MediaQuery.of(context).size.height;
    // لو ما اتمررش ارتفاع، استخدم قيمة افتراضية
    final itemH = height ?? 140.h;
 
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: itemH,
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // الأيقونة تاخد الجزء الأكبر
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(screenH * 0.015),
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
              ),
              // الـ label الأخضر
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: screenH * 0.012,
                  horizontal: 4,
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
                      // حجم الخط نسبة من عرض الشاشة
                      fontSize: MediaQuery.of(context).size.width * 0.038,
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
