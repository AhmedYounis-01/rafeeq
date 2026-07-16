import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart'
    hide getPageData, getPageNumber;

import 'package:rafeeq/features/quran/logic/cubit/quran_cubit.dart';
import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';
import 'package:rafeeq/features/quran/ui/widgets/surah_index_tile.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Surah Index Content — StatefulWidget مع بحث داخلي
// ═══════════════════════════════════════════════════════════════════════════
class SurahIndexContent extends StatefulWidget {
  final ScrollController scrollController;
  final QuranReady state;
  final bool isDark;
  final MushafConfig cfg;
  final Color gold, bgColor, textColor;
  final void Function(int surahNum) onNavigate;
  final void Function(int surahNum) onPlay;

  const SurahIndexContent({
    super.key,
    required this.scrollController,
    required this.state,
    required this.isDark,
    required this.cfg,
    required this.gold,
    required this.bgColor,
    required this.textColor,
    required this.onNavigate,
    required this.onPlay,
  });

  @override
  State<SurahIndexContent> createState() => _SurahIndexContentState();
}

class _SurahIndexContentState extends State<SurahIndexContent> {
  final TextEditingController _ctrl = TextEditingController();
  List<int> _filtered = List.generate(114, (i) => i + 1);

  // Cache lists
  late final List<String> _surahNames;
  late final List<String> _surahNamesNormalized;

  @override
  void initState() {
    super.initState();
    // Cache Surah names to avoid calling getSurahNameArabic 114 times per keystroke
    _surahNames = List.generate(114, (i) => getSurahNameArabic(i + 1));
    _surahNamesNormalized = _surahNames.map(_normalizeArabic).toList();
  }

  String _normalizeArabic(String text) {
    var s = text.trim();
    // remove all diacritics
    s = s.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    // unify alef
    s = s.replaceAll(RegExp(r'[آإأ]'), 'ا');
    // unify yaa
    s = s.replaceAll('ى', 'ي');
    // unify haa
    s = s.replaceAll('ة', 'ه');

    // remove extra spaces and unify numerals (English/Arabic)
    s = s.replaceAllMapped(RegExp(r'[٠-٩]'), (m) {
      return (m.group(0)!.codeUnitAt(0) - 1632).toString();
    });
    return s.toLowerCase();
  }

  void _filter(String q) {
    if (q.isEmpty) {
      if (_filtered.length != 114) {
        setState(() {
          _filtered = List.generate(114, (i) => i + 1);
        });
      }
      return;
    }

    final query = _normalizeArabic(q);
    final List<int> results = [];

    for (int i = 0; i < 114; i++) {
      final surahNum = i + 1;
      final nameOrig = _surahNames[i];
      final nameNorm = _surahNamesNormalized[i];

      // Match normalized name, original name, or surah number
      if (nameNorm.contains(query) ||
          nameOrig.contains(query) ||
          surahNum.toString().contains(query)) {
        results.add(surahNum);
      }
    }

    setState(() {
      _filtered = results;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = widget.gold;
    final cfg = widget.cfg;

    return Container(
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

          // Title
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: Text(
              'فهرس السور',
              style: GoogleFonts.amiri(
                fontSize: cfg.surahNameFontSize * 0.8,
                color: gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Search field داخل الفهرس
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold.withValues(alpha: 0.25)),
              ),
              child: TextField(
                controller: _ctrl,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(fontSize: 15, color: widget.textColor),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم السورة أو رقمها',
                  hintStyle: GoogleFonts.amiri(
                    fontSize: 13,
                    color: widget.textColor.withValues(alpha: 0.4),
                  ),
                  hintTextDirection: TextDirection.rtl,
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search_rounded, color: gold, size: 18),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: gold,
                            size: 16,
                          ),
                          onPressed: () {
                            _ctrl.clear();
                            _filter('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: _filter,
              ),
            ),
          ),

          Divider(
            height: 1,
            color: gold.withValues(alpha: 0.2),
            indent: 16,
            endIndent: 16,
          ),

          // القائمة
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          color: gold.withValues(alpha: 0.3),
                          size: 42,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد نتائج',
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            color: widget.textColor.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : BlocBuilder<QuranCubit, QuranState>(
                    buildWhen: (prev, curr) =>
                        prev is QuranReady &&
                        curr is QuranReady &&
                        prev.audioStatus != curr.audioStatus,
                    builder: (_, s) {
                      final audio = s is QuranReady
                          ? s.audioStatus
                          : widget.state.audioStatus;
                      return ListView.builder(
                        controller: widget.scrollController,
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final surahNum = _filtered[i];
                          final isPlayingThis =
                              audio.surah == surahNum &&
                              audio.mode == AudioPlayMode.surah;
                          return SurahIndexTile(
                            surahNum: surahNum,
                            gold: gold,
                            textColor: widget.textColor,
                            isPlayingThis: isPlayingThis,
                            isPlaying: audio.isPlaying,
                            cfg: cfg,
                            onNavigate: () => widget.onNavigate(surahNum),
                            onPlay: () => widget.onPlay(surahNum),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
