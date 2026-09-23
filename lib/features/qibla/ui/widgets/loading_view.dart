import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'qibla_config.dart';

class LoadingView extends StatelessWidget {
  final bool isDark;
  final QiblaConfig cfg;

  const LoadingView({super.key, required this.isDark, required this.cfg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.getPrimary(context),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            "common.loading".tr(),
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: cfg.bodyFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
