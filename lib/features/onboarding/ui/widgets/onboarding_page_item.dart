import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import '../../data/models/onboarding_item.dart';

class OnboardingPageItem extends StatelessWidget {
  final OnboardingItem item;
  final Animation<double> imageScale;
  final Animation<double> imageFade;
  final Animation<double> floatAnimation;
  final Animation<Offset> titleSlide;
  final Animation<double> titleFade;
  final Animation<Offset> descSlide;
  final Animation<double> descFade;

  const OnboardingPageItem({
    super.key,
    required this.item,
    required this.imageScale,
    required this.imageFade,
    required this.floatAnimation,
    required this.titleSlide,
    required this.titleFade,
    required this.descSlide,
    required this.descFade,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 24.h),

          // ── Floating Image with scale + fade + float ──
          Expanded(
            flex: 5,
            child: FadeTransition(
              opacity: imageFade,
              child: ScaleTransition(
                scale: imageScale,
                child: AnimatedBuilder(
                  animation: floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, floatAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withAlpha(60)
                              : AppColors.primary.withAlpha(20),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withAlpha(30)
                              : AppColors.primary.withAlpha(8),
                          blurRadius: 60,
                          offset: const Offset(0, 25),
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28.r),
                      child: Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 36.h),

          // ── Title with slide + fade ──
          SlideTransition(
            position: titleSlide,
            child: FadeTransition(
              opacity: titleFade,
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  height: 1.35,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // ── Description with delayed slide + fade ──
          SlideTransition(
            position: descSlide,
            child: FadeTransition(
              opacity: descFade,
              child: Text(
                item.description,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  height: 1.6,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),

          SizedBox(height: 28.h),
        ],
      ),
    );
  }
}
