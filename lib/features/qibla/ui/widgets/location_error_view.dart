import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'qibla_config.dart';

class LocationErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onEnable;
  final QiblaConfig cfg;

  const LocationErrorView({
    super.key,
    required this.message,
    this.onEnable,
    required this.cfg,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(cfg.hPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SvgPicture.asset(
              Assets.images.locationOff.path,
              width: cfg.isTablet ? 520 : 250.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: cfg.isTablet ? 40 : 24),
            Text(
              "qibla.location_error_title".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.textPrimary,
                fontSize: cfg.labelFontSize + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                fontSize: cfg.bodyFontSize + 2,
                height: 1.6,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: cfg.btnHeight + (cfg.isTablet ? 10 : 0),
              child: ElevatedButton(
                onPressed: onEnable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(context),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "qibla.activate".tr(),
                      style: TextStyle(
                        fontSize: cfg.isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.location_on, size: cfg.isTablet ? 28 : 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
