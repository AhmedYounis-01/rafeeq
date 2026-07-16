import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart'
    hide getPageData, getPageNumber;

import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Surah Index Tile
// ═══════════════════════════════════════════════════════════════════════════
class SurahIndexTile extends StatelessWidget {
  final int surahNum;
  final Color gold, textColor;
  final bool isPlayingThis, isPlaying;
  final MushafConfig cfg;
  final VoidCallback onNavigate, onPlay;

  const SurahIndexTile({
    super.key,
    required this.surahNum,
    required this.gold,
    required this.textColor,
    required this.isPlayingThis,
    required this.isPlaying,
    required this.cfg,
    required this.onNavigate,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onNavigate,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: cfg.headerCircleSize * 0.85,
        height: cfg.headerCircleSize * 0.85,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: gold.withValues(alpha: 0.5)),
          color: gold.withValues(alpha: 0.07),
        ),
        child: Center(
          child: Text(
            '$surahNum',
            style: GoogleFonts.amiri(
              fontSize: cfg.headerIconSize * 0.65,
              color: gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        getSurahNameArabic(surahNum),
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(
          fontSize: cfg.surahNameFontSize * 0.72,
          color: textColor,
        ),
      ),
      subtitle: Text(
        '${getVerseCount(surahNum)} آية',
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(
          fontSize: cfg.overlayLabelSize,
          color: gold.withValues(alpha: 0.6),
        ),
      ),
      trailing: GestureDetector(
        onTap: onPlay,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: cfg.headerCircleSize * 0.85,
          height: cfg.headerCircleSize * 0.85,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPlayingThis && isPlaying
                ? gold.withValues(alpha: 0.2)
                : gold.withValues(alpha: 0.07),
            border: Border.all(color: gold.withValues(alpha: 0.4)),
          ),
          child: Icon(
            isPlayingThis && isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: gold,
            size: cfg.headerIconSize * 0.65,
          ),
        ),
      ),
    );
  }
}
