import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Reciter Tile
// ═══════════════════════════════════════════════════════════════════════════
class ReciterTile extends StatelessWidget {
  final String name;
  final bool isSelected;
  final Color gold, textColor;
  final MushafConfig cfg;
  final VoidCallback onTap;

  const ReciterTile({
    super.key,
    required this.name,
    required this.isSelected,
    required this.gold,
    required this.textColor,
    required this.cfg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cfg.headerCircleSize * 0.85,
        height: cfg.headerCircleSize * 0.85,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? gold.withValues(alpha: 0.2)
              : gold.withValues(alpha: 0.06),
          border: Border.all(
            color: gold.withValues(alpha: isSelected ? 0.8 : 0.3),
          ),
        ),
        child: Icon(
          isSelected ? Icons.check_rounded : Icons.person_rounded,
          color: gold,
          size: cfg.headerIconSize * 0.7,
        ),
      ),
      title: Text(
        name,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(
          fontSize: cfg.surahNameFontSize * 0.72,
          color: isSelected ? gold : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.graphic_eq_rounded,
              color: gold,
              size: cfg.headerIconSize * 0.8,
            )
          : null,
    );
  }
}
