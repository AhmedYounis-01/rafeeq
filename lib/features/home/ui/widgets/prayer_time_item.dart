import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class PrayerTimesItem extends StatelessWidget {
  const PrayerTimesItem({
    super.key,
    required this.image,
    required this.title,
    required this.time,
    this.isNext = false,
    this.isPassed = false,
  });
  final String image;
  final String title;
  final String time;
  final bool isNext;
  final bool isPassed;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 95.w,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.backgroundCardDark
                : AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16.r),
            border: isNext
                ? Border.all(color: AppColors.getPrimary(context), width: 2.w)
                : Border.all(color: Colors.transparent, width: 2.w),
            boxShadow: [
              BoxShadow(
                color: isNext
                    ? AppColors.getPrimary(
                        context,
                      ).withValues(alpha: isDark ? 0.3 : 0.2)
                    : Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                blurRadius: isNext ? 16 : 8,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image with rounded top
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isNext
                      ? AppColors.getPrimary(context).withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    image,
                    width: 58.w,
                    height: 58.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                time,
                style: context.textTheme.titleSmall?.copyWith(
                  color: isNext
                      ? AppColors.getPrimary(context)
                      : context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
        if (isNext)
          Positioned(
            top: -8.h,
            right: 0,
            left: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.getPrimary(context),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getPrimary(
                        context,
                      ).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "home.next_prayer".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
