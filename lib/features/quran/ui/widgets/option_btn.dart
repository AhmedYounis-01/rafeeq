import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Option Button
// ═══════════════════════════════════════════════════════════════════════════
class OptionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color gold;
  final MushafConfig cfg;
  final VoidCallback onTap;
  final String? subtitle;

  const OptionBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.gold,
    required this.cfg,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: cfg.optionBtnSize,
            height: cfg.optionBtnSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.1),
              border: Border.all(
                color: gold.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: gold, size: cfg.optionBtnSize * 0.44),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: GoogleFonts.amiri(fontSize: cfg.optionFontSize, color: gold),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            SizedBox(
              width: cfg.optionBtnSize * 1.4,
              child: Text(
                subtitle!,
                style: GoogleFonts.amiri(
                  fontSize: cfg.optionFontSize * 0.82,
                  color: gold.withValues(alpha: 0.55),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
