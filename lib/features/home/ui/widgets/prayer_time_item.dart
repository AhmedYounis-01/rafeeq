// ═══════════════════════════════════════════════════════════════════════════
// FILE: features/home/ui/widgets/prayer_time_item.dart
// ═══════════════════════════════════════════════════════════════════════════
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
 
    // الـ item يملأ الـ SizedBox اللي حاط بيه في الـ ListView
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundCardDark : AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16.r),
            border: isNext
                ? Border.all(color: AppColors.getPrimary(context), width: 2)
                : Border.all(color: Colors.transparent, width: 2),
            boxShadow: [
              BoxShadow(
                color: isNext
                    ? AppColors.getPrimary(context).withValues(alpha: isDark ? 0.3 : 0.2)
                    : Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                blurRadius: isNext ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الصورة تاخد 55% من ارتفاع الكارت
              Flexible(
                flex: 55,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(image, fit: BoxFit.contain),
                  ),
                ),
              ),
              // النص في الـ 45% الباقية
              Flexible(
                flex: 45,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          style: TextStyle(
                            color: context.colorScheme.onSurface,
                            fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          time,
                          style: TextStyle(
                            color: isNext
                                ? AppColors.getPrimary(context)
                                : context.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isNext)
          Positioned(
            top: -7, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.getPrimary(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("home.next_prayer".tr(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }
}
