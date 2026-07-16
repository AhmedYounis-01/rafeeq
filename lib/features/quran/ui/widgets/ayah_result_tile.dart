import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rafeeq/features/quran/logic/cubit/quran_cubit.dart';
import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Ayah Result Tile — يعرض مقتطف الآية مع تمييز الكلمة المطابقة
// ═══════════════════════════════════════════════════════════════════════════
class AyahResultTile extends StatelessWidget {
  final AyahSearchResult result;
  final String query;
  final Color gold, textColor;
  final MushafConfig cfg;
  final VoidCallback onTap;

  const AyahResultTile({
    super.key,
    required this.result,
    required this.query,
    required this.gold,
    required this.textColor,
    required this.cfg,
    required this.onTap,
  });

  static String _normalizeArabic(String text) {
    if (text.isEmpty) return '';
    var s = text;
    // 1. Normalize complex letters
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا'); // Alef
    s = s.replaceAll(RegExp(r'[ئى]'), 'ي'); // Ya / Alef Maksura
    s = s.replaceAll('ؤ', 'و'); // Waw Hamza
    s = s.replaceAll('ة', 'ه'); // Ta Marbuta
    // 2. Remove Tatweel
    s = s.replaceAll('ـ', '');
    // 3. Remove all non-letter characters
    s = s.replaceAll(RegExp(r'[^\u0621-\u064A\s]'), '');
    // 4. Normalize whitespace
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// يستخرج مقتطفاً حول موضع التطابق في النص الأصلي
  (String snippet, int matchStart, int matchEnd) _getSnippet() {
    final verse = result.verseText;
    if (query.isEmpty) {
      final s = verse.length > 90 ? '${verse.substring(0, 87)}...' : verse;
      return (s, -1, -1);
    }

    // نحاول المطابقة أولاً مع تشكيل، ثم بدونه
    int idx = verse.indexOf(query);
    int matchLen = query.length;

    if (idx == -1) {
      final stripped = _normalizeArabic(verse);
      final strippedQ = _normalizeArabic(query);
      final strIdx = stripped.indexOf(strippedQ);
      if (strIdx == -1) {
        final s = verse.length > 90 ? '${verse.substring(0, 87)}...' : verse;
        return (s, -1, -1);
      }
      // نحوّل الموضع من النص المجرّد للأصلي (تقريبي)
      idx = strIdx;
      matchLen = strippedQ.length;
    }

    const radius = 30;
    final start = (idx - radius).clamp(0, verse.length);
    final end = (idx + matchLen + radius).clamp(0, verse.length);
    final prefix = start > 0 ? '...' : '';
    final suffix = end < verse.length ? '...' : '';
    final snippet = '$prefix${verse.substring(start, end)}$suffix';
    final adjustedStart = prefix.length + (idx - start);
    final adjustedEnd = adjustedStart + matchLen;

    return (
      snippet,
      adjustedStart.clamp(0, snippet.length),
      adjustedEnd.clamp(0, snippet.length),
    );
  }

  List<TextSpan> _buildHighlightSpans(
    String text,
    int matchStart,
    int matchEnd, {
    required TextStyle normal,
    required TextStyle highlight,
  }) {
    if (matchStart < 0 || matchEnd <= matchStart) {
      return [TextSpan(text: text, style: normal)];
    }
    final spans = <TextSpan>[];
    if (matchStart > 0) {
      spans.add(TextSpan(text: text.substring(0, matchStart), style: normal));
    }
    spans.add(
      TextSpan(text: text.substring(matchStart, matchEnd), style: highlight),
    );
    if (matchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(matchEnd), style: normal));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final (snippet, matchStart, matchEnd) = _getSnippet();

    final normalStyle = GoogleFonts.amiri(
      fontSize: cfg.surahNameFontSize * 0.6,
      color: textColor.withValues(alpha: 0.68),
      height: 1.65,
    );
    final highlightStyle = GoogleFonts.amiri(
      fontSize: cfg.surahNameFontSize * 0.6,
      color: gold,
      fontWeight: FontWeight.bold,
      backgroundColor: gold.withValues(alpha: 0.1),
      height: 1.65,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // دائرة رقم السورة
            Container(
              width: cfg.headerCircleSize * 0.85,
              height: cfg.headerCircleSize * 0.85,
              margin: const EdgeInsets.only(top: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold.withValues(alpha: 0.45)),
                color: gold.withValues(alpha: 0.07),
              ),
              child: Center(
                child: Text(
                  '${result.surah}',
                  style: GoogleFonts.amiri(
                    fontSize: cfg.headerIconSize * 0.58,
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // المحتوى
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // اسم السورة ورقم الآية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: gold.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          'آية ${result.ayah}',
                          style: GoogleFonts.amiri(
                            fontSize: cfg.overlayLabelSize * 0.88,
                            color: gold.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        result.surahName,
                        style: GoogleFonts.amiri(
                          fontSize: cfg.surahNameFontSize * 0.68,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // مقتطف الآية مع التمييز
                  RichText(
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      children: _buildHighlightSpans(
                        snippet,
                        matchStart,
                        matchEnd,
                        normal: normalStyle,
                        highlight: highlightStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_back_ios_rounded,
              color: gold.withValues(alpha: 0.35),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}
