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
import 'package:rafeeq/features/quran/data/tafsir_model.dart';

// ─── Responsive Config ────────────────────────────────────────────────────
class _MushafConfig {
  final double shortestSide;
  _MushafConfig(BuildContext context)
    : shortestSide = MediaQuery.of(context).size.shortestSide;

  bool get isTablet => shortestSide >= 600;

  double get pageNumFontSize => (shortestSide * 0.085).clamp(26.0, 46.0);
  double get overlayLabelSize => (shortestSide * 0.028).clamp(10.0, 16.0);
  double get overlayJuzSize => (shortestSide * 0.048).clamp(16.0, 26.0);
  double get overlaySurahSize => (shortestSide * 0.042).clamp(14.0, 24.0);
  double get surahNameFontSize => (shortestSide * 0.058).clamp(18.0, 32.0);

  double get maxSheetWidth => isTablet ? 580.0 : double.infinity;
  double get playerLabelSize => (shortestSide * 0.038).clamp(13.0, 20.0);
  double get playerBtnSize => (shortestSide * 0.1).clamp(36.0, 56.0);
  double get optionBtnSize => (shortestSide * 0.155).clamp(54.0, 80.0);
  double get optionFontSize => (shortestSide * 0.032).clamp(11.0, 16.0);
  double get headerBtnSize => (shortestSide * 0.1).clamp(34.0, 54.0);
  double get headerCircleSize => (shortestSide * 0.09).clamp(30.0, 48.0);
  double get headerIconSize => (shortestSide * 0.05).clamp(18.0, 28.0);
}

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
    final cfg = _MushafConfig(context);

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
    _MushafConfig cfg,
  ) {
    return Scaffold(
      backgroundColor: _bgColor(isDark),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
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
  Widget _buildMainScreen(bool isDark, _MushafConfig cfg) {
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
                child: _QuranPageBody(
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
                      child: _LastReadRibbon(
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
                  final bottomPad = isNavVisible ? 300.0 : 20.0;

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
  Widget _buildTopOverlay(int currentPage, bool isDark, _MushafConfig cfg) {
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
  Widget _buildAudioPlayer(QuranReady state, bool isDark, _MushafConfig cfg) {
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
                  : _EqBars(
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
              _AudioBtn(
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
              _AudioBtn(
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
  void _showPageOptions(QuranReady state, bool isDark, _MushafConfig cfg) {
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
        child: _PageOptionsSheet(
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
  void _showTafsirSheet(bool isDark, _MushafConfig cfg) {
    final colorScheme = Theme.of(context).colorScheme;
    final gold = _goldColor(isDark);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (ctx) => _TafsirSheet(
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
  void _openReciterSelector(QuranReady state, bool isDark, _MushafConfig cfg) {
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
                          return _ReciterTile(
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
  void _openSurahIndex(QuranReady state, bool isDark, _MushafConfig cfg) {
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
          builder: (ctx2, sc) => _SurahIndexContent(
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
  void _openSearchSheet(bool isDark, _MushafConfig cfg) {
    final colorScheme = Theme.of(context).colorScheme;
    final gold = _goldColor(isDark);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (ctx) => _AyahSearchSheet(
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

// ═══════════════════════════════════════════════════════════════════════════
// Surah Index Content — StatefulWidget مع بحث داخلي
// ═══════════════════════════════════════════════════════════════════════════
class _SurahIndexContent extends StatefulWidget {
  final ScrollController scrollController;
  final QuranReady state;
  final bool isDark;
  final _MushafConfig cfg;
  final Color gold, bgColor, textColor;
  final void Function(int surahNum) onNavigate;
  final void Function(int surahNum) onPlay;

  const _SurahIndexContent({
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
  State<_SurahIndexContent> createState() => _SurahIndexContentState();
}

class _SurahIndexContentState extends State<_SurahIndexContent> {
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
                          return _SurahIndexTile(
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

// ═══════════════════════════════════════════════════════════════════════════
// Ayah Search Sheet — بحث حقيقي في نصوص الآيات عبر الـ Cubit
// ═══════════════════════════════════════════════════════════════════════════
class _AyahSearchSheet extends StatefulWidget {
  final QuranCubit cubit;
  final bool isDark;
  final _MushafConfig cfg;
  final Color gold, bgColor, textColor;
  final void Function(int surah, int ayah) onNavigate;

  const _AyahSearchSheet({
    required this.cubit,
    required this.isDark,
    required this.cfg,
    required this.gold,
    required this.bgColor,
    required this.textColor,
    required this.onNavigate,
  });

  @override
  State<_AyahSearchSheet> createState() => _AyahSearchSheetState();
}

class _AyahSearchSheetState extends State<_AyahSearchSheet> {
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
                                return _AyahResultTile(
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

  Widget _buildIdleState(Color gold, _MushafConfig cfg) {
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

// ═══════════════════════════════════════════════════════════════════════════
// Ayah Result Tile — يعرض مقتطف الآية مع تمييز الكلمة المطابقة
// ═══════════════════════════════════════════════════════════════════════════
class _AyahResultTile extends StatelessWidget {
  final AyahSearchResult result;
  final String query;
  final Color gold, textColor;
  final _MushafConfig cfg;
  final VoidCallback onTap;

  const _AyahResultTile({
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

// ═══════════════════════════════════════════════════════════════════════════
// Page Options Sheet
// ═══════════════════════════════════════════════════════════════════════════
class _PageOptionsSheet extends StatelessWidget {
  final int page;
  final String hizb;
  final bool isBookmarked, isPlayingPage, isPlaying, isDark;
  final Color gold, bgColor, textColor;
  final String selectedReciterName;
  final _MushafConfig cfg;
  final VoidCallback onPlayPage,
      onBookmark,
      onSelectReciter,
      onSurahIndex,
      onLastRead,
      onSearch;

  const _PageOptionsSheet({
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _OptionBtn(
                icon: isPlayingPage && isPlaying
                    ? Icons.pause_circle_rounded
                    : Icons.play_circle_rounded,
                label: isPlayingPage && isPlaying ? 'إيقاف' : 'تشغيل الصفحة',
                gold: gold,
                cfg: cfg,
                onTap: onPlayPage,
              ),
              _OptionBtn(
                icon: isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: isBookmarked ? 'إزالة الحفظ' : 'علّم الصفحة',
                gold: isBookmarked ? AppColors.secondary : gold,
                cfg: cfg,
                onTap: onBookmark,
              ),
              _OptionBtn(
                icon: Icons.mic_rounded,
                label: 'اختر القارئ',
                gold: gold,
                cfg: cfg,
                onTap: onSelectReciter,
                subtitle: selectedReciterName,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _OptionBtn(
                icon: Icons.menu_book_rounded,
                label: 'فهرس السور',
                gold: gold,
                cfg: cfg,
                onTap: onSurahIndex,
              ),
              _OptionBtn(
                icon: Icons.bookmark_added_rounded,
                label: 'آخر حفظ',
                gold: gold,
                cfg: cfg,
                onTap: onLastRead,
              ),
              _OptionBtn(
                icon: Icons.search_rounded,
                label: 'بحث في الآيات',
                gold: gold,
                cfg: cfg,
                onTap: onSearch,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Reciter Tile
// ═══════════════════════════════════════════════════════════════════════════
class _ReciterTile extends StatelessWidget {
  final String name;
  final bool isSelected;
  final Color gold, textColor;
  final _MushafConfig cfg;
  final VoidCallback onTap;

  const _ReciterTile({
    required this.name,
    required this.isSelected,
    required this.gold,
    required this.textColor,
    required this.cfg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cfg.headerCircleSize * 0.85,
        height: cfg.headerCircleSize * 0.85,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? gold.withValues(alpha: 0.2)
              : gold.withValues(alpha: 0.06),
          border: Border.all(
            color: gold.withValues(alpha: isSelected ? 0.8 : 0.3),
          ),
        ),
        child: Icon(
          isSelected ? Icons.check_rounded : Icons.person_rounded,
          color: gold,
          size: cfg.headerIconSize * 0.7,
        ),
      ),
      title: Text(
        name,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(
          fontSize: cfg.surahNameFontSize * 0.72,
          color: isSelected ? gold : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.graphic_eq_rounded,
              color: gold,
              size: cfg.headerIconSize * 0.8,
            )
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Surah Index Tile
// ═══════════════════════════════════════════════════════════════════════════
class _SurahIndexTile extends StatelessWidget {
  final int surahNum;
  final Color gold, textColor;
  final bool isPlayingThis, isPlaying;
  final _MushafConfig cfg;
  final VoidCallback onNavigate, onPlay;

  const _SurahIndexTile({
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

// ═══════════════════════════════════════════════════════════════════════════
class _OptionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color gold;
  final _MushafConfig cfg;
  final VoidCallback onTap;
  final String? subtitle;

  const _OptionBtn({
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

// ═══════════════════════════════════════════════════════════════════════════
class _AudioBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  final bool filled;

  const _AudioBtn({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size + 14,
      height: size + 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color.withValues(alpha: 0.15) : Colors.transparent,
        border: Border.all(color: color.withValues(alpha: filled ? 0.5 : 0.25)),
      ),
      child: Icon(icon, color: color, size: size),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
class _EqBars extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double size;

  const _EqBars({required this.isPlaying, required this.color, this.size = 22});

  @override
  State<_EqBars> createState() => _EqBarsState();
}

class _EqBarsState extends State<_EqBars> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + i * 80),
      ),
    );
    _anims = _ctrls
        .map(
          (c) => Tween<double>(
            begin: 0.2,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();
    if (widget.isPlaying) _start();
  }

  void _start() {
    for (int i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: i * 60), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  void _stop() {
    for (final c in _ctrls) {
      c.animateTo(0.2, duration: const Duration(milliseconds: 200));
    }
  }

  @override
  void didUpdateWidget(_EqBars old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      widget.isPlaying ? _start() : _stop();
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.size,
    height: widget.size,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        4,
        (i) => AnimatedBuilder(
          animation: _anims[i],
          builder: (_, _) => Container(
            width: widget.size * 0.14,
            height: widget.size * _anims[i].value,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
class _LastReadRibbon extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const _LastReadRibbon({
    required this.color,
    this.width = 22,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, height),
    painter: _RibbonPainter(color: color),
  );
}

class _RibbonPainter extends CustomPainter {
  final Color color;
  const _RibbonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width / 2, size.height - 12)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = color.withValues(alpha: 0.85),
    );
    canvas.drawLine(
      const Offset(4, 0),
      Offset(4, size.height - 14),
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.25)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _RibbonPainter old) => old.color != color;
}

// ═══════════════════════════════════════════════════════════════════════════
// Tafsir Sheet
// ═══════════════════════════════════════════════════════════════════════════
class _TafsirSheet extends StatelessWidget {
  final QuranCubit cubit;
  final bool isDark;
  final _MushafConfig cfg;
  final Color gold, bgColor, textColor;
  final void Function(int surah, int ayah) onPlayAyah;

  const _TafsirSheet({
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
                // ── Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ── Header: اسم السورة + رقم الآية + زر تشغيل
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    children: [
                      // زر تشغيل الآية
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
                      // اسم السورة ورقم الآية
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

                // ── نص الآية + التفسير
                Expanded(
                  child: SingleChildScrollView(
                    controller: sc,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // نص الآية — من الباكدج offline
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

                        // عنوان التفسير
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

                        // محتوى التفسير
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
      return _TafsirMessage(
        icon: Icons.wifi_off_rounded,
        text: 'لا يوجد اتصال بالإنترنت',
        sub: 'التفسير يحتاج اتصال للتحميل\nثم يُحفظ تلقائياً',
        gold: gold,
        textColor: textColor,
        cfg: cfg,
      );
    }
    if (data.hasError) {
      return _TafsirMessage(
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

// ═══ رسالة حالة ──────────────────────────────────────────────────────────
class _TafsirMessage extends StatelessWidget {
  final IconData icon;
  final String text, sub;
  final Color gold, textColor;
  final _MushafConfig cfg;

  const _TafsirMessage({
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

// ✅ StatelessWidget منفصل - مش هيتبنى أبداً من الخارج
class _QuranPageBody extends StatelessWidget {
  final PageController pageController;
  final ValueNotifier<List<HighlightVerse>> highlightsNotifier;
  final bool isDark;
  final VoidCallback onTap;
  final void Function(int) onPageChanged;
  final void Function(int, int, dynamic) onLongPress;

  const _QuranPageBody({
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
        bottom: false,
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
