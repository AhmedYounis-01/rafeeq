import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart'
    hide getPageData, getPageNumber;

// ✅ StatelessWidget منفصل - مش هيتبنى أبداً من الخارج
class QuranPageBody extends StatelessWidget {
  final PageController pageController;
  final ValueNotifier<List<HighlightVerse>> highlightsNotifier;
  final bool isDark;
  final VoidCallback onTap;
  final void Function(int) onPageChanged;
  final void Function(int, int, dynamic) onLongPress;

  const QuranPageBody({
    super.key,
    required this.pageController,
    required this.highlightsNotifier,
    required this.isDark,
    required this.onTap,
    required this.onPageChanged,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SafeArea(
        child: ValueListenableBuilder<List<HighlightVerse>>(
          valueListenable: highlightsNotifier,
          builder: (_, highlights, child) => QuranPageView(
            pageController: pageController,
            isDarkMode: isDark,
            isTajweed: false,
            highlights: highlights,
            onPageChanged: onPageChanged,
            onLongPress: onLongPress,
          ),
        ),
      ),
    );
  }
}
