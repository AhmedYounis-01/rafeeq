import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

class CategoryHeader extends StatelessWidget {
  final String title;
  final int? itemCount;

  const CategoryHeader({super.key, required this.title, this.itemCount});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary = AppColors.getPrimary(context);

    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 12.h),
      child: Row(
        children: [
          // Decorative left accent
          Container(
            width: 4.w,
            height: 22.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primary,
                  primary.withAlpha(100),
                ],
              ),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 10.w),

          // Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
                letterSpacing: 0.1,
              ),
            ),
          ),

          // Count badge (optional)
          if (itemCount != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: primary.withAlpha(60)),
              ),
              child: Text(
                '$itemCount',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}