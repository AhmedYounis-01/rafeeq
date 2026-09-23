import 'package:flutter/material.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

class SettingsAppBarBackground extends StatelessWidget {
  const SettingsAppBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.getPrimary(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary.withValues(alpha: 0.08),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
    );
  }
}
