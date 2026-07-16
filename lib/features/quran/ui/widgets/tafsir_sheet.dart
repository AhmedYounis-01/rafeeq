import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rafeeq/features/quran/data/tafsir_model.dart';
import 'package:rafeeq/features/quran/logic/cubit/quran_cubit.dart';
import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';
import 'package:rafeeq/features/quran/ui/widgets/tafsir_message.dart';

class TafsirSheet extends StatelessWidget {
  final QuranCubit cubit;
  final bool isDark;
  final MushafConfig cfg;
  final Color gold, bgColor, textColor;
  final void Function(int surah, int ayah) onPlayAyah;

  const TafsirSheet({
    super.key,
    required this.cubit,
    required this.isDark,
    required this.cfg,
    required this.gold,
    required this.bgColor,
    required this.textColor,
    required this.onPlayAyah,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, sc) => Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: gold.withValues(alpha: 0.2)),
        ),
        child: ValueListenableBuilder<TafsirData?>(
          valueListenable: cubit.tafsirNotifier,
          builder: (_, data, _) {
            if (data == null) {
              return Center(child: CircularProgressIndicator(color: gold));
            }
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => onPlayAyah(data.surah, data.ayah),
                        child: Container(
                          width: cfg.headerCircleSize,
                          height: cfg.headerCircleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: gold.withValues(alpha: 0.12),
                            border: Border.all(
                              color: gold.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: gold,
                            size: cfg.headerIconSize * 0.75,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            data.surahName,
                            style: GoogleFonts.amiri(
                              fontSize: cfg.surahNameFontSize * 0.78,
                              color: gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'آية ${data.ayah}',
                            style: GoogleFonts.amiri(
                              fontSize: cfg.overlayLabelSize,
                              color: gold.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 20,
                  color: gold.withValues(alpha: 0.18),
                  indent: 20,
                  endIndent: 20,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: sc,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: gold.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Text(
                            data.verseText,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amiri(
                              fontSize: cfg.surahNameFontSize * 0.85,
                              color: textColor,
                              height: 2.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'التفسير الميسّر',
                              style: GoogleFonts.amiri(
                                fontSize: cfg.surahNameFontSize * 0.68,
                                color: gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.menu_book_rounded,
                              color: gold,
                              size: cfg.headerIconSize * 0.7,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildTafsirBody(data),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTafsirBody(TafsirData data) {
    if (data.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: gold)),
      );
    }
    if (data.noInternet) {
      return TafsirMessage(
        icon: Icons.wifi_off_rounded,
        text: 'لا يوجد اتصال بالإنترنت',
        sub: 'التفسير يحتاج اتصال للتحميل\nثم يُحفظ تلقائياً',
        gold: gold,
        textColor: textColor,
        cfg: cfg,
      );
    }
    if (data.hasError) {
      return TafsirMessage(
        icon: Icons.error_outline_rounded,
        text: 'تعذّر تحميل التفسير',
        sub: 'تحقق من الاتصال وحاول مجدداً',
        gold: gold,
        textColor: textColor,
        cfg: cfg,
      );
    }
    return Text(
      data.tafsir,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.amiri(
        fontSize: cfg.surahNameFontSize * 0.72,
        color: textColor.withValues(alpha: 0.85),
        height: 1.9,
      ),
    );
  }
}
