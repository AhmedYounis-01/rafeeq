import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

class CalibrationBanner extends StatelessWidget {
  final ValueNotifier<bool> calibNotifier;
  final bool isDark;

  const CalibrationBanner({
    super.key,
    required this.calibNotifier,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: calibNotifier,
      builder: (context, show, child) {
        if (!show) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          color: AppColors.warning.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "qibla.calibration_hint".tr(),
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
