import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';

// ═══ رسالة حالة ──────────────────────────────────────────────────────────
class TafsirMessage extends StatelessWidget {
  final IconData icon;
  final String text, sub;
  final Color gold, textColor;
  final MushafConfig cfg;

  const TafsirMessage({
    super.key,
    required this.icon,
    required this.text,
    required this.sub,
    required this.gold,
    required this.textColor,
    required this.cfg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, color: gold.withValues(alpha: 0.45), size: 42),
          const SizedBox(height: 12),
          Text(
            text,
            style: GoogleFonts.amiri(
              fontSize: cfg.surahNameFontSize * 0.7,
              color: textColor.withValues(alpha: 0.65),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: cfg.overlayLabelSize,
              color: textColor.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
