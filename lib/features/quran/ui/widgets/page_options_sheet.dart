import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';
import 'package:rafeeq/features/quran/ui/widgets/option_btn.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Page Options Sheet
// ═══════════════════════════════════════════════════════════════════════════
class PageOptionsSheet extends StatelessWidget {
  final int page;
  final String hizb;
  final bool isBookmarked, isPlayingPage, isPlaying, isDark;
  final Color gold, bgColor, textColor;
  final String selectedReciterName;
  final MushafConfig cfg;
  final VoidCallback onPlayPage,
      onBookmark,
      onSelectReciter,
      onSurahIndex,
      onLastRead,
      onSearch;

  const PageOptionsSheet({
    super.key,
    required this.page,
    required this.hizb,
    required this.isBookmarked,
    required this.isPlayingPage,
    required this.isPlaying,
    required this.isDark,
    required this.gold,
    required this.bgColor,
    required this.textColor,
    required this.selectedReciterName,
    required this.cfg,
    required this.onPlayPage,
    required this.onBookmark,
    required this.onSelectReciter,
    required this.onSurahIndex,
    required this.onLastRead,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        32 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'الصفحة $page',
                style: GoogleFonts.amiri(
                  fontSize: cfg.optionFontSize + 2,
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold.withValues(alpha: 0.5),
                ),
              ),
              Text(
                hizb,
                style: GoogleFonts.amiri(
                  fontSize: cfg.optionFontSize + 2,
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: OptionBtn(
                  icon: isPlayingPage && isPlaying
                      ? Icons.pause_circle_rounded
                      : Icons.play_circle_rounded,
                  label: isPlayingPage && isPlaying ? 'إيقاف' : 'تشغيل الصفحة',
                  gold: gold,
                  cfg: cfg,
                  onTap: onPlayPage,
                ),
              ),
              Expanded(
                child: OptionBtn(
                  icon: isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: isBookmarked ? 'إزالة الحفظ' : 'علّم الصفحة',
                  gold: isBookmarked ? AppColors.secondary : gold,
                  cfg: cfg,
                  onTap: onBookmark,
                ),
              ),
              Expanded(
                child: OptionBtn(
                  icon: Icons.mic_rounded,
                  label: 'اختر القارئ',
                  gold: gold,
                  cfg: cfg,
                  onTap: onSelectReciter,
                  subtitle: selectedReciterName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: OptionBtn(
                  icon: Icons.menu_book_rounded,
                  label: 'فهرس السور',
                  gold: gold,
                  cfg: cfg,
                  onTap: onSurahIndex,
                ),
              ),
              Expanded(
                child: OptionBtn(
                  icon: Icons.bookmark_added_rounded,
                  label: 'آخر حفظ',
                  gold: gold,
                  cfg: cfg,
                  onTap: onLastRead,
                ),
              ),
              Expanded(
                child: OptionBtn(
                  icon: Icons.search_rounded,
                  label: 'بحث في الآيات',
                  gold: gold,
                  cfg: cfg,
                  onTap: onSearch,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
