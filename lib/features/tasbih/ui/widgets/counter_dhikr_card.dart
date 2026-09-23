import 'package:flutter/material.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/tasbih/data/model/tasbih_model.dart';
import 'tasbih_config.dart';

class NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color primary;
  final bool isDark;

  const NavArrow({
    super.key,
    required this.icon,
    required this.onTap,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: isDark ? 0.15 : 0.08),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: primary, size: 22),
    ),
  );
}

class CounterDhikrCard extends StatelessWidget {
  final TasbihModel dhikr;
  final bool isRtl, isDark;
  final Color textColor, subtextColor, primary;
  final TasbihConfig cfg;
  final VoidCallback onNext, onPrev;

  const CounterDhikrCard({
    super.key,
    required this.dhikr,
    required this.isRtl,
    required this.isDark,
    required this.textColor,
    required this.subtextColor,
    required this.primary,
    required this.cfg,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? AppColors.backgroundCardDark
        : AppColors.backgroundCard;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          NavArrow(
            icon: Icons.chevron_left_rounded,
            onTap: isRtl ? onNext : onPrev,
            primary: primary,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRtl)
                  Text(
                    dhikr.text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TasbihTextStyles.amiriQuran(
                      cfg.dhikrFont + 2,
                      textColor,
                      height: 1.8,
                    ),
                  )
                else
                  Text(
                    dhikr.transliteration,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: TasbihTextStyles.amiri(
                      cfg.dhikrFont + 1,
                      textColor,
                      weight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          NavArrow(
            icon: Icons.chevron_right_rounded,
            onTap: isRtl ? onPrev : onNext,
            primary: primary,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
