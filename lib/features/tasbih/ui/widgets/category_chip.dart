import 'package:flutter/material.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'tasbih_config.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected, isDark;
  final Color primary;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primary : primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? primary : primary.withValues(alpha: 0.15),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TasbihTextStyles.amiri(
          12.5,
          isSelected
              ? Colors.white
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          weight: isSelected ? FontWeight.bold : FontWeight.w500,
          height: 1.1,
        ),
      ),
    ),
  );
}
