import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rafeeq/features/quran/logic/cubit/quran_cubit.dart';
import 'package:rafeeq/features/quran/ui/widgets/ayah_result_tile.dart';
import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Ayah Search Sheet — بحث حقيقي في نصوص الآيات عبر الـ Cubit
// ═══════════════════════════════════════════════════════════════════════════
class AyahSearchSheet extends StatefulWidget {
  final QuranCubit cubit;
  final bool isDark;
  final MushafConfig cfg;
  final Color gold, bgColor, textColor;
  final void Function(int surah, int ayah) onNavigate;

  const AyahSearchSheet({
    super.key,
    required this.cubit,
    required this.isDark,
    required this.cfg,
    required this.gold,
    required this.bgColor,
    required this.textColor,
    required this.onNavigate,
  });

  @override
  State<AyahSearchSheet> createState() => _AyahSearchSheetState();
}

class _AyahSearchSheetState extends State<AyahSearchSheet> {
  final TextEditingController _ctrl = TextEditingController();
  static const int _pageSize = 30; // results shown per page
  int _displayCount = _pageSize;

  @override
  void dispose() {
    _ctrl.dispose();
    widget.cubit.clearAyahSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = widget.gold;
    final cfg = widget.cfg;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, sc) => Container(
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    color: gold,
                    size: cfg.headerIconSize * 0.85,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'البحث في الآيات',
                    style: GoogleFonts.amiri(
                      fontSize: cfg.surahNameFontSize * 0.8,
                      color: gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: gold.withValues(alpha: 0.3)),
                ),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    color: widget.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ابحث في كلمات القرآن... (مثال: الرحمن)',
                    hintStyle: GoogleFonts.amiri(
                      fontSize: 13,
                      color: widget.textColor.withValues(alpha: 0.38),
                    ),
                    hintTextDirection: TextDirection.rtl,
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: gold,
                      size: 20,
                    ),
                    suffixIcon: ValueListenableBuilder<bool>(
                      valueListenable: widget.cubit.isSearchingAyahs,
                      builder: (_, isSearching, _) {
                        if (_ctrl.text.isEmpty) return const SizedBox.shrink();
                        return isSearching
                            ? Padding(
                                padding: const EdgeInsets.all(13),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: gold,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: gold,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _ctrl.clear();
                                  widget.cubit.clearAyahSearch();
                                  setState(() => _displayCount = _pageSize);
                                },
                              );
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (v) {
                    // Reset pagination on every new query
                    setState(() => _displayCount = _pageSize);
                    widget.cubit.searchAyahs(v);
                  },
                ),
              ),
            ),

            Divider(height: 1, color: gold.withValues(alpha: 0.15)),

            // Results area
            Expanded(
              child: ValueListenableBuilder<List<AyahSearchResult>>(
                valueListenable: widget.cubit.ayahSearchResults,
                builder: (_, results, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: widget.cubit.isSearchingAyahs,
                    builder: (_, isSearching, _) {
                      // ── Idle state ──────────────────────────────────
                      if (_ctrl.text.isEmpty) {
                        return _buildIdleState(gold, cfg);
                      }

                      // ── Pure loading (no results yet) ────────────────
                      if (isSearching && results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: gold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'جارٍ البحث في المصحف...',
                                style: GoogleFonts.amiri(
                                  fontSize: 15,
                                  color: widget.textColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // ── No results ──────────────────────────────────
                      if (!isSearching && results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                color: gold.withValues(alpha: 0.3),
                                size: 48,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'لا توجد نتائج',
                                style: GoogleFonts.amiri(
                                  fontSize: 18,
                                  color: widget.textColor.withValues(
                                    alpha: 0.55,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'جرّب بحثاً بكلمة أخرى',
                                style: GoogleFonts.amiri(
                                  fontSize: 13,
                                  color: widget.textColor.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // ── Results (with streaming + pagination) ────────
                      final displayed = results.take(_displayCount).toList();
                      final hasMore = results.length > _displayCount;
                      final totalCount = results.length;

                      return Column(
                        children: [
                          // Result count badge
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // "loading more" micro indicator
                                if (isSearching)
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: gold.withValues(alpha: 0.5),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 14),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: gold.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: gold.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    isSearching
                                        ? '$totalCount+ نتيجة'
                                        : '$totalCount نتيجة',
                                    style: GoogleFonts.amiri(
                                      fontSize: cfg.overlayLabelSize,
                                      color: gold.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: ListView.separated(
                              controller: sc,
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                              itemCount: displayed.length + (hasMore ? 1 : 0),
                              separatorBuilder: (_, _) => Divider(
                                height: 1,
                                color: gold.withValues(alpha: 0.08),
                              ),
                              itemBuilder: (_, i) {
                                // ── "Load more" button ─────────────────
                                if (i == displayed.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () => _displayCount += _pageSize,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: gold.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: gold.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.expand_more_rounded,
                                                color: gold,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'عرض المزيد (${results.length - _displayCount} باقية)',
                                                style: GoogleFonts.amiri(
                                                  fontSize:
                                                      cfg.overlayLabelSize,
                                                  color: gold,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final r = displayed[i];
                                return AyahResultTile(
                                  result: r,
                                  query: _ctrl.text.trim(),
                                  gold: gold,
                                  textColor: widget.textColor,
                                  cfg: cfg,
                                  onTap: () =>
                                      widget.onNavigate(r.surah, r.ayah),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState(Color gold, MushafConfig cfg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.08),
              border: Border.all(color: gold.withValues(alpha: 0.2)),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: gold.withValues(alpha: 0.4),
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ابحث في كتاب الله',
            style: GoogleFonts.amiri(
              fontSize: 18,
              color: widget.textColor.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اكتب كلمة أو جزءاً من آية',
            style: GoogleFonts.amiri(
              fontSize: 13,
              color: widget.textColor.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'أو ابحث بمرجع مثل: 2:255',
            style: GoogleFonts.amiri(
              fontSize: 12,
              color: gold.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
