import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'qibla_config.dart';

class NoSensorView extends StatelessWidget {
  final QiblaConfig cfg;
  const NoSensorView({super.key, required this.cfg});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(cfg.hPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(cfg.isTablet ? 32 : 24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.sensors_off_rounded,
                size: cfg.isTablet ? 80 : 64,
                color: isDark ? AppColors.secondaryDark : AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "qibla.sensor_error_title".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.textPrimary,
                fontSize: cfg.labelFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "qibla.sensor_error_desc".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textSecondary,
                fontSize: cfg.bodyFontSize,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
