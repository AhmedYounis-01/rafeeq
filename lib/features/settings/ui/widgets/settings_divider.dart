import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'settings_config.dart';

class SettingsDivider extends StatelessWidget {
  final SettingsConfig config;
  const SettingsDivider({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: (config.iconContainerSize + 32.w),
      endIndent: 16.w,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.2),
    );
  }
}
