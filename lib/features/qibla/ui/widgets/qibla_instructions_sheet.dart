import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'qibla_config.dart';

class QiblaInstructionsSheet extends StatelessWidget {
  final bool isDark;
  final QiblaConfig cfg;

  const QiblaInstructionsSheet({
    super.key,
    required this.isDark,
    required this.cfg,
  });

  static void show(BuildContext context, bool isDark, QiblaConfig cfg) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: cfg.isTablet ? 560.0 : double.infinity,
      ),
      builder: (ctx) => QiblaInstructionsSheet(isDark: isDark, cfg: cfg),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(cfg.isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1F18) : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: AppColors.getPrimary(context).withValues(alpha: 0.4),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: cfg.isTablet ? 28 : 24),
          Container(
            padding: EdgeInsets.all(cfg.isTablet ? 20 : 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.getPrimary(context).withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.explore_rounded,
              color: AppColors.getPrimary(context),
              size: cfg.isTablet ? 52 : 40,
            ),
          ),
          SizedBox(height: cfg.isTablet ? 20 : 16),
          Text(
            "qibla.instructions_title".tr(),
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.textPrimary,
              fontSize: cfg.labelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "qibla.activate_location_message".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.6)
                  : AppColors.textSecondary,
              fontSize: cfg.bodyFontSize,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: cfg.btnHeight,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimary(context),
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                "qibla.understand".tr(),
                style: TextStyle(
                  fontSize: cfg.bodyFontSize + 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 16 + MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}
