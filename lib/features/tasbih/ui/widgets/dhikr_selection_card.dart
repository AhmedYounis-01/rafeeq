import 'package:flutter/material.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/tasbih/data/model/tasbih_model.dart';
import 'tasbih_config.dart';

class DhikrSelectionCard extends StatelessWidget {
  final MapEntry<int, TasbihModel> entry;
  final Color primary, cardBg;
  final bool isDark, isRtl;
  final TasbihConfig cfg;
  final VoidCallback onTap;

  const DhikrSelectionCard({
    super.key,
    required this.entry,
    required this.primary,
    required this.isDark,
    required this.isRtl,
    required this.cfg,
    required this.cardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final d = entry.value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
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
        child: Row(
          children: [
            // Count badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.1),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Text(
                  '${d.count}',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: cfg.labelFont + 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRtl ? d.text : d.transliteration,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: isRtl
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: isRtl
                        ? TasbihTextStyles.amiriQuran(
                            cfg.dhikrFont * 0.9,
                            isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            height: 1.6,
                          )
                        : TasbihTextStyles.amiri(
                            cfg.labelFont + 2,
                            isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            weight: FontWeight.bold,
                          ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: primary.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
