import 'package:flutter/material.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'tasbih_config.dart';

class StatBox extends StatelessWidget {
  final String label, value;
  final Color primary;
  final bool isDark;

  const StatBox({
    super.key,
    required this.label,
    required this.value,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: isDark ? AppColors.backgroundCardDark : AppColors.backgroundCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: primary.withValues(alpha: 0.1)),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          label,
          style: TasbihTextStyles.amiri(
            13,
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            weight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TasbihTextStyles.amiriBold(
            28,
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}
