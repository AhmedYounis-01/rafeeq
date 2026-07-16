import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart'
    hide getPageData, getPageNumber;
import 'package:quran/quran.dart'
    hide getSurahNameArabic, getJuzNumber, getVerseCount;

import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/core/widgets/shared_navigation.dart';
import 'package:rafeeq/features/quran/logic/cubit/quran_cubit.dart';
import 'package:rafeeq/features/quran/ui/widgets/audio_widgets.dart';
import 'package:rafeeq/features/quran/ui/widgets/ayah_search_sheet.dart';
import 'package:rafeeq/features/quran/ui/widgets/last_read_ribbon.dart';
import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';
import 'package:rafeeq/features/quran/ui/widgets/page_options_sheet.dart';
import 'package:rafeeq/features/quran/ui/widgets/quran_page_body.dart';
import 'package:rafeeq/features/quran/ui/widgets/reciter_tile.dart';
import 'package:rafeeq/features/quran/ui/widgets/surah_index_content.dart';
import 'package:rafeeq/features/quran/ui/widgets/tafsir_sheet.dart';

// ═══════════════════════════════════════════════════════════════════════════
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final PageController _pageController;
  final QuranCubit _cubit = QuranCubit();
  StreamSubscription<int>? _pageJumpSub;
  StreamSubscription<String>? _errorSub;
  bool _didInitialJump = false;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _pageJumpSub = _cubit.pageJumpStream.listen((pageIndex) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    _errorSub = _cubit.errorStream.listen((error) {
      if (error == 'no_internet' && mounted) _showNoInternetSnack();
    });

    _cubit.init();
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    // Restore nav bar when leaving the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) BottomNavVisibility.show(context);
    });
    _pageJumpSub?.cancel();
    _errorSub?.cancel();
    _pageController.dispose();
    _cubit.close();
    super.dispose();
  }

  // ─── Colors ──────────────────────────────────────────────────────────────
  Color _goldColor(bool isDark) =>
      isDark ? AppColors.secondaryDark : AppColors.secondary;
  Color _bgColor(bool isDark) =>
      isDark ? AppColors.backgroundDark : const Color(0xFFF8F6F0);
  Color _textColor(bool isDark) =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
  Color _cardColor(bool isDark) =>
      isDark ? AppColors.backgroundCardDark : AppColors.backgroundCard;
  Color _playerBgColor(bool isDark) =>
      isDark ? AppColors.backgroundCardDark : AppColors.backgroundLight;

  // ─── No Internet Snackbar ─────────────────────────────────────────────
  void _showNoInternetSnack() {
    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _cardColor(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.warning.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'لا يوجد اتصال بالإنترنت',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'تحقق من الاتصال وأعد المحاولة',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: 11,
                          color: AppColors.warning.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = MushafConfig(context);

    return BlocProvider.value(
      value: _cubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<QuranCubit, QuranState>(
            listenWhen: (prev, curr) =>
                prev is! QuranReady && curr is QuranReady,
            listener: (_, state) {
              if (_didInitialJump) return;
              _didInitialJump = true;
              final page = (state as QuranReady).currentPage;
              if (page > 1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(page - 1);
                  }
                });
              }
              // Auto-hide bottom nav after 1 second for immersive reading
              _autoHideTimer?.cancel();
              _autoHideTimer = Timer(const Duration(seconds: 1), () {
                if (mounted) BottomNavVisibility.hide(context);
              });
            },
          ),
        ],
        child: BlocBuilder<QuranCubit, QuranState>(
          buildWhen: (prev, curr) {
            if (prev.runtimeType != curr.runtimeType) return true;
            if (curr is QuranFontsLoading) return true;
            return false; // ✅ مبقاش يشغل rebuild للـ ready state هنا
          },
          builder: (context, state) {
            if (state is QuranInitial || state is QuranPrefsLoading) {
              return Scaffold(
                backgroundColor: _bgColor(isDark),
                body: Center(
                  child: CircularProgressIndicator(color: _goldColor(isDark)),
                ),
              );
            }
            if (state is QuranFontsLoading) {
              return _buildFontsLoadingScreen(state.progress, isDark, cfg);
            }
            if (state is QuranError) {
              return Scaffold(
                backgroundColor: _bgColor(isDark),
                body: Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.amiri(color: _goldColor(isDark)),
                  ),
                ),
              );
            }
            return _buildMainScreen(isDark, cfg); // ✅ مبقاش بيبعت state
          },
        ),
      ),
    );
  }

  // ─── Fonts Loading ────────────────────────────────────────────────────
  Widget _buildFontsLoadingScreen(
    double progress,
    bool isDark,
    MushafConfig cfg,
  ) {
    return Scaffold(
      backgroundColor: _bgColor(isDark),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: GoogleFonts.amiri(
                fontSize: cfg.surahNameFontSize,
                color: _goldColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 240,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: _goldColor(isDark).withValues(alpha: 0.1),
                    color: _goldColor(isDark),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جاري تحميل بيانات المصحف... ${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.amiri(
                      fontSize: 16,
                      color: _textColor(isDark).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Main Screen ──────────────────────────────────────────────────────
  Widget _buildMainScreen(bool isDark, MushafConfig cfg) {
    return Scaffold(
      backgroundColor: _bgColor(isDark),
      body: Stack(
        children: [
          // ✅ QuranPageView معزول تماماً - مش هيتبنى إلا لو isDark اتغير
          ValueListenableBuilder<bool>(
            valueListenable:
                BottomNavVisibility.of(context) ?? ValueNotifier(true),
            builder: (context, isNavVisible, _) {
              return RepaintBoundary(
                child: QuranPageBody(
                  pageController: _pageController,
                  highlightsNotifier: _cubit.highlightsNotifier,
                  isDark: isDark,
                  onTap: () {
                    _cubit.toggleOverlay();
                    BottomNavVisibility.toggle(context);
                    HapticFeedback.lightImpact();
                  },
                  onPageChanged: (pageNumber) {
                    _cubit.onPageChanged(pageNumber);
                    HapticFeedback.lightImpact();
                  },
                  onLongPress: (surah, ayah, details) {
                    HapticFeedback.mediumImpact();
                    _cubit.fetchTafsir(surah, ayah);
                    _showTafsirSheet(isDark, cfg);
                  },
                ),
              );
            },
          ),

          // ✅ Overlay بـ BlocSelector - مش بيأثر على PageView
          BlocSelector<QuranCubit, QuranState, bool>(
            selector: (s) => s is QuranReady && s.showOverlay,
            builder: (_, showOverlay) => Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                child: IgnorePointer(
                  ignoring: !showOverlay,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _cubit.currentPageNotifier,
                    builder: (_, currentPage, _) =>
                        _buildTopOverlay(currentPage, isDark, cfg),
                  ),
                ),
              ),
            ),
          ),

          // ✅ Bookmark ribbon
          ValueListenableBuilder<int>(
            valueListenable: _cubit.currentPageNotifier,
            builder: (_, currentPage, _) {
              return BlocSelector<QuranCubit, QuranState, int?>(
                selector: (s) => s is QuranReady ? s.bookmarkPage : null,
                builder: (_, bookmarkPage) {
                  if (bookmarkPage != currentPage) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    top: 0,
                    right: cfg.isTablet ? 28 : 20,
                    child: IgnorePointer(
                      child: LastReadRibbon(
                        color: _goldColor(isDark),
                        width: cfg.isTablet ? 28 : 22,
                        height: cfg.isTablet ? 74 : 60,
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // ✅ Audio player - BlocSelector للـ audioStatus فقط
          BlocSelector<QuranCubit, QuranState, AudioStatus>(
            selector: (s) =>
                s is QuranReady ? s.audioStatus : const AudioStatus.idle(),
            builder: (_, audioStatus) {
              if (!audioStatus.isActive) return const SizedBox.shrink();

              return ValueListenableBuilder<bool>(
                valueListenable:
                    BottomNavVisibility.of(context) ?? ValueNotifier(true),
                builder: (context, isNavVisible, _) {
                  final bottomPad = isNavVisible ? 220.0 : 40.0;

                  return Positioned(
                    bottom: bottomPad,
                    left: 14,
                    right: 14,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: cfg.isTablet ? 660 : double.infinity,
                        ),
                        child:
                            BlocSelector<QuranCubit, QuranState, QuranReady?>(
                              selector: (s) => s is QuranReady ? s : null,
                              builder: (_, state) {
                                if (state == null) {
                                  return const SizedBox.shrink();
                                }
                                return _buildAudioPlayer(state, isDark, cfg);
                              },
                            ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),

      floatingActionButton: BlocSelector<QuranCubit, QuranState, bool>(
        selector: (s) => s is QuranReady && s.showOverlay,
        builder: (_, showOverlay) => showOverlay
            ? ValueListenableBuilder<bool>(
                valueListenable:
                    BottomNavVisibility.of(context) ?? ValueNotifier(true),
                builder: (context, isNavVisible, child) {
                  final bottomPad = MediaQuery.of(context).size.height * 0.10;
                  return Padding(
                    padding: EdgeInsets.only(bottom: bottomPad),
                    child: child,
                  );
                },
                child: FloatingActionButton(
                  backgroundColor: _cardColor(isDark),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: _goldColor(isDark),
                    size: MediaQuery.of(context).size.height * 0.035,
                  ),
                  onPressed: () {
                    _cubit.hideOverlay();
                    final state = _cubit.state;
                    if (state is QuranReady) {
                      _showPageOptions(state, isDark, cfg);
                    }
                  },
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  // ─── Top Overlay ──────────────────────────────────────────────────────
  Widget _buildTopOverlay(int currentPage, bool isDark, MushafConfig cfg) {
    final juz = _cubit.getJuz(currentPage);
    final surahName = _cubit.getSurahDisplayName(currentPage);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.88),
            Colors.black.withValues(alpha: 0.72),
            Colors.black.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.65, 1.0],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 32,
        left: 20,
        right: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الجزء',
                style: GoogleFonts.amiri(
                  fontSize: cfg.overlayLabelSize,
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '$juz',
                style: GoogleFonts.amiri(
                  fontSize: cfg.overlayJuzSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$currentPage',
                  style: GoogleFonts.amiri(
                    fontSize: cfg.pageNumFontSize,
                    fontWeight: FontWeight.bold,
                    color: _goldColor(isDark),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  height: 1,
                  width: 40,
                  color: _goldColor(isDark).withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'السورة',
                style: GoogleFonts.amiri(
                  fontSize: cfg.overlayLabelSize,
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              ),
              Text(
                surahName,
                style: GoogleFonts.amiri(
                  fontSize: cfg.overlaySurahSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Audio Player ─────────────────────────────────────────────────────
  Widget _buildAudioPlayer(QuranReady state, bool isDark, MushafConfig cfg) {
    final gold = _goldColor(isDark);
    final audio = state.audioStatus;
    final surahName = getSurahNameArabic(audio.surah!);
    final label = audio.isSurahMode
        ? 'سورة $surahName'
        : 'سورة $surahName • آية ${audio.ayah}';
    final subtitle = audio.isSurahMode ? 'تشغيل السورة' : 'تشغيل آية';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: _playerBgColor(isDark).withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: gold.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              audio.isLoading
                  ? SizedBox(
                      width: cfg.playerLabelSize + 6,
                      height: cfg.playerLabelSize + 6,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: gold,
                      ),
                    )
                  : EqBars(
                      isPlaying: audio.isPlaying,
                      color: gold,
                      size: cfg.playerLabelSize + 6,
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: cfg.playerLabelSize,
                        fontWeight: FontWeight.bold,
                        color: _textColor(isDark),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: cfg.playerLabelSize * 0.7,
                        color: gold.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AudioBtn(
                icon: audio.isLoading
                    ? Icons.hourglass_empty_rounded
                    : (audio.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                color: gold,
                size: cfg.playerBtnSize * 0.58,
                onTap: audio.isLoading ? () {} : _cubit.togglePlayPause,
                filled: true,
              ),
              const SizedBox(width: 6),
              AudioBtn(
                icon: Icons.stop_rounded,
                color: gold.withValues(alpha: 0.55),
                size: cfg.playerBtnSize * 0.44,
                onTap: _cubit.stopAudio,
                filled: false,
              ),
            ],
          ),
          StreamBuilder<Duration>(
            stream: _cubit.positionStream,
            builder: (_, posSnap) => StreamBuilder<Duration?>(
              stream: _cubit.durationStream,
              builder: (_, durSnap) {
                final position = posSnap.data ?? Duration.zero;
                final duration = durSnap.data ?? Duration.zero;
                final progress = duration.inMilliseconds > 0
                    ? (position.inMilliseconds / duration.inMilliseconds).clamp(
                        0.0,
                        1.0,
                      )
                    : 0.0;
                String fmt(Duration d) =>
                    '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
                return Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: cfg.isTablet ? 4 : 3,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: cfg.isTablet ? 7 : 6,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: cfg.isTablet ? 16 : 14,
                        ),
                        activeTrackColor: gold,
                        inactiveTrackColor: gold.withValues(alpha: 0.18),
                        thumbColor: gold,
                        overlayColor: gold.withValues(alpha: 0.15),
                      ),
                      child: Slider(
                        value: progress,
                        onChanged: (v) => _cubit.seekTo(v),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fmt(duration - position),
                            style: TextStyle(
                              fontSize: 10,
                              color: gold.withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            fmt(position),
                            style: TextStyle(
                              fontSize: 10,
                              color: gold.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page Options ──────────────────────────────────────────────────────
  void _showPageOptions(QuranReady state, bool isDark, MushafConfig cfg) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gold = _goldColor(isDark);

    final currentPage = _cubit.currentPageNotifier.value;
    final isBookmarked = state.bookmarkPage == currentPage;
    final isPlayingPage =
        state.audioStatus.isPlaying &&
        state.audioStatus.mode == AudioPlayMode.page;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: colorScheme.scrim.withValues(alpha: 0.4),
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (ctx) => BlocProvider.value(
        value: _cubit,
        child: PageOptionsSheet(
          page: currentPage,
          hizb: _cubit.getHizb(currentPage),
          isBookmarked: isBookmarked,
          isPlayingPage: isPlayingPage,
          isPlaying: state.audioStatus.isPlaying,
          gold: gold,
          isDark: isDark,
          bgColor: isDark
              ? AppColors.bottomSheetDark
              : AppColors.bottomSheetLight,
          textColor: colorScheme.onSurface,
          selectedReciterName: _cubit.getReciterName(state.selectedReciterId),
          cfg: cfg,
          onPlayPage: () {
            Navigator.pop(ctx);
            if (isPlayingPage && state.audioStatus.isPlaying) {
              _cubit.togglePlayPause();
            } else {
              _cubit.playPage(currentPage);
            }
          },
          onBookmark: () {
            Navigator.pop(ctx);
            isBookmarked
                ? _cubit.clearBookmark()
                : _cubit.setBookmark(currentPage);
            HapticFeedback.mediumImpact();
          },
          onSelectReciter: () {
            Navigator.pop(ctx);
            _openReciterSelector(state, isDark, cfg);
          },
          onSurahIndex: () {
            Navigator.pop(ctx);
            _openSurahIndex(state, isDark, cfg);
          },
          onLastRead: () {
            Navigator.pop(ctx);
            if (state.bookmarkPage != null) {
              _cubit.jumpToPage(state.bookmarkPage!);
            }
          },
          onSearch: () {
            Navigator.pop(ctx);
            _openSearchSheet(isDark, cfg);
          },
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        BottomNavVisibility.hide(context);
        _cubit.hideOverlay();
      }
    });
  }

  // ─── Tafsir Sheet ─────────────────────────────────────────────────────
  void _showTafsirSheet(bool isDark, MushafConfig cfg) {
    final colorScheme = Theme.of(context).colorScheme;
    final gold = _goldColor(isDark);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (ctx) => TafsirSheet(
        cubit: _cubit,
        isDark: isDark,
        cfg: cfg,
        gold: gold,
        bgColor: isDark
            ? AppColors.bottomSheetDark
            : AppColors.bottomSheetLight,
        textColor: colorScheme.onSurface,
        onPlayAyah: (surah, ayah) {
          Navigator.pop(ctx);
          _cubit.playAyah(surah, ayah);
        },
      ),
    ).whenComplete(() {
      _cubit.clearTafsir();
      if (mounted) {
        BottomNavVisibility.hide(context);
        _cubit.hideOverlay();
      }
    });
  } // ─── Reciter Selector ────────────────────────────────────────────────

  // ─── Reciter Selector ────────────────────────────────────────────────
  void _openReciterSelector(QuranReady state, bool isDark, MushafConfig cfg) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gold = _goldColor(isDark);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (ctx) => BlocProvider.value(
        value: _cubit,
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx2, scrollController) => Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.bottomSheetDark
                  : AppColors.bottomSheetLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: gold.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                _sheetHandle(gold),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic_rounded,
                        color: gold,
                        size: cfg.headerIconSize * 0.85,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'اختر القارئ',
                        style: GoogleFonts.amiri(
                          fontSize: cfg.surahNameFontSize * 0.8,
                          color: gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: gold.withValues(alpha: 0.25),
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: BlocBuilder<QuranCubit, QuranState>(
                    buildWhen: (prev, curr) =>
                        prev is QuranReady &&
                        curr is QuranReady &&
                        prev.selectedReciterId != curr.selectedReciterId,
                    builder: (_, s) {
                      final currentId = s is QuranReady
                          ? s.selectedReciterId
                          : state.selectedReciterId;
                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                        itemCount: kReciters.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: gold.withValues(alpha: 0.12),
                        ),
                        itemBuilder: (_, index) {
                          final r = kReciters[index];
                          final isSelected = r['id'] == currentId;
                          return ReciterTile(
                            name: r['name']!,
                            isSelected: isSelected,
                            gold: gold,
                            textColor:
                                colorScheme.onSurface, // أفضل لون نص حسب الثيم
                            cfg: cfg,
                            onTap: () {
                              Navigator.pop(ctx);
                              _cubit.selectReciter(r['id']!);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        BottomNavVisibility.hide(context);
        _cubit.hideOverlay();
      }
    });
  }

  // ─── Surah Index — مع بحث داخلي للسور ────────────────────────────────
  void _openSurahIndex(QuranReady state, bool isDark, MushafConfig cfg) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gold = _goldColor(isDark);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (ctx) => BlocProvider.value(
        value: _cubit,
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx2, sc) => SurahIndexContent(
            scrollController: sc,
            state: state,
            isDark: isDark,
            cfg: cfg,
            gold: gold,
            bgColor: colorScheme.surfaceContainerLow,
            textColor: colorScheme.onSurface,
            onNavigate: (surahNum) {
              _pageController.jumpToPage(getPageNumber(surahNum, 1) - 1);
              Navigator.pop(ctx);
            },
            onPlay: (surahNum) {
              Navigator.pop(ctx);
              _cubit.playSurah(surahNum);
            },
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        BottomNavVisibility.hide(context);
        _cubit.hideOverlay();
      }
    });
  }

  // ─── Ayah Search Sheet ────────────────────────────────────────────────
  void _openSearchSheet(bool isDark, MushafConfig cfg) {
    final colorScheme = Theme.of(context).colorScheme;
    final gold = _goldColor(isDark);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (ctx) => AyahSearchSheet(
        cubit: _cubit,
        isDark: isDark,
        cfg: cfg,
        gold: gold,
        bgColor: colorScheme.surfaceContainerLow,
        textColor: colorScheme.onSurface,
        onNavigate: (surahNum, ayah) {
          Navigator.pop(ctx);
          final targetPage = getPageNumber(surahNum, ayah);
          _pageController.jumpToPage(targetPage - 1);
        },
      ),
    ).whenComplete(() {
      if (mounted) {
        BottomNavVisibility.hide(context);
        _cubit.hideOverlay();
      }
    });
  }

  // ─── Sheet Handle ─────────────────────────────────────────────────────
  Widget _sheetHandle(Color gold) => Container(
    margin: const EdgeInsets.only(top: 12, bottom: 8),
    width: 36,
    height: 4,
    decoration: BoxDecoration(
      color: gold.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
