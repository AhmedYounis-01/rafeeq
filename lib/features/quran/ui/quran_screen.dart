import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart';
import 'package:quran_pages_with_ayah_detector/quran_pages_with_ayah_detector.dart';

import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/core/widgets/shared_navigation.dart';
import 'package:rafeeq/features/quran/logic/cubit/quran_cubit.dart';
import 'package:rafeeq/features/quran/ui/widgets/audio_widgets.dart';
import 'package:rafeeq/features/quran/ui/widgets/ayah_search_sheet.dart';
import 'package:rafeeq/features/quran/ui/widgets/last_read_ribbon.dart';
import 'package:rafeeq/features/quran/ui/widgets/mushaf_config.dart';
import 'package:rafeeq/features/quran/ui/widgets/page_options_sheet.dart';
import 'package:rafeeq/features/quran/ui/widgets/reciter_tile.dart';
import 'package:rafeeq/features/quran/ui/widgets/surah_index_content.dart';
import 'package:rafeeq/features/quran/ui/widgets/tafsir_sheet.dart';
import 'package:rafeeq/features/quran/logic/cubit/download/quran_download_cubit.dart';
import 'package:rafeeq/features/quran/logic/cubit/download/quran_download_state.dart';

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

  // ── Static singleton: created once, survives navigation ──────────────
  static final QuranCubit _cubit = QuranCubit();
  late final QuranDownloadCubit _downloadCubit;

  final QuranPageController _quranController = QuranPageController();

  StreamSubscription<int>? _pageJumpSub;
  StreamSubscription<String>? _errorSub;
  Timer? _autoHideTimer;

  String _pagesPath = 'assets/pages/';

  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _isReady = false;
    _downloadCubit = QuranDownloadCubit()..checkAssets();
  }

  void _initQuranCubit() {
    _pageJumpSub?.cancel();
    _errorSub?.cancel();

    // Re-subscribe streams each time this widget mounts (safe, subs are cancelled on dispose)
    _pageJumpSub = _cubit.pageJumpStream.listen((pageIndex) {
      _quranController.jumpToPage(pageIndex + 1);
    });

    _errorSub = _cubit.errorStream.listen((error) {
      if (error == 'no_internet' && mounted) _showNoInternetSnack();
    });

    // init() is a no-op if state is already QuranReady — safe to call again
    _cubit.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cubit.hideOverlay();
        BottomNavVisibility.hide(context);
        final targetPage = _cubit.currentPageNotifier.value;
        if (targetPage > 0 && _quranController.currentPage != targetPage) {
          _quranController.jumpToPage(targetPage);
        }
        for (int i = -2; i <= 2; i++) {
          final p = targetPage + i;
          if (p >= 1 && p <= 604) {
            final ImageProvider provider = _pagesPath.startsWith('assets/')
                ? AssetImage('$_pagesPath$p.png')
                : FileImage(File('$_pagesPath$p.png')) as ImageProvider;
            precacheImage(provider, context);
          }
        }
        if (!_isReady) {
          setState(() {
            _isReady = true;
          });
        }
      }
    });
  }

  Widget _buildDownloadPrompt(
    bool isDark,
    MushafConfig cfg,
    QuranDownloadState state,
  ) {
    final gold = _goldColor(isDark);
    final textCol = _textColor(isDark);
    final cardCol = _cardColor(isDark);
    final bgCol = _bgColor(isDark);

    final isDownloading = state is QuranDownloading;
    final isPaused = state is QuranDownloadPaused;
    final isExtracting = state is QuranDownloading && state.isExtracting;
    final hasError = state is QuranDownloadError;

    final (double progress, String statusText) = switch (state) {
      QuranDownloading s => (s.progress, s.statusText),
      QuranDownloadPaused s => (s.progress, s.statusText),
      QuranDownloadError s => (0.0, s.errorMessage),
      _ => (0.0, ''),
    };

    final bool inProgressOrPaused = isDownloading || isPaused;

    return Scaffold(
      backgroundColor: bgCol,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardCol,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: gold.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: gold.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: gold, size: 56),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'تحميل صفحات المصحف الشريف',
                    style: GoogleFonts.amiri(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'تنزيل المصحف مرة واحدة يتيح لك القراءة دون الحاجة إلى اتصال بالإنترنت لاحقاً.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: textCol.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  if (inProgressOrPaused) ...[
                    // Progress Bar & Status (clean, without byte numbers)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress > 0 ? progress : null,
                            minHeight: 10,
                            backgroundColor: gold.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(gold),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          statusText.isNotEmpty
                              ? statusText
                              : (isDownloading
                                  ? 'جاري التحميل...'
                                  : 'متوقف مؤقتاً'),
                          style: TextStyle(
                            fontSize: 13.5,
                            color: textCol.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isExtracting) ...[
                          ElevatedButton.icon(
                            onPressed: isDownloading
                                ? _downloadCubit.pauseDownload
                                : _downloadCubit.startOrResumeDownload,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              foregroundColor: bgCol,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            icon: Icon(
                              isDownloading
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 22,
                            ),
                            label: Text(
                              isDownloading ? 'إيقاف مؤقت' : 'متابعة التحميل',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isPaused) ...[
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: _downloadCubit.resetDownload,
                              tooltip: 'إعادة التنزيل من البداية',
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.error.withValues(
                                  alpha: 0.1,
                                ),
                                foregroundColor: AppColors.error,
                                padding: const EdgeInsets.all(12),
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                            ),
                          ],
                        ] else ...[
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    // Not started or Error state
                    if (hasError) ...[
                      Text(
                        statusText,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton.icon(
                      onPressed: _downloadCubit.startOrResumeDownload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: bgCol,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      icon: Icon(
                        hasError
                            ? Icons.refresh_rounded
                            : Icons.download_rounded,
                        size: 22,
                      ),
                      label: Text(
                        hasError ? 'إعادة المحاولة' : 'بدء التحميل الآن',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    // Cancel per-widget subscriptions but keep the singleton cubit alive
    _pageJumpSub?.cancel();
    _errorSub?.cancel();
    _downloadCubit.close();
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

  // ─── No Internet Snack ────────────────────────────────────────────────
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
      value: _downloadCubit,
      child: BlocConsumer<QuranDownloadCubit, QuranDownloadState>(
        listener: (context, downloadState) {
          if (downloadState is QuranDownloadSuccess) {
            _pagesPath = downloadState.pagesPath;
            _initQuranCubit();
          } else {
            BottomNavVisibility.show(context);
          }
        },
        builder: (context, downloadState) {
          if (downloadState is QuranDownloadChecking ||
              downloadState is QuranDownloadInitial) {
            return Scaffold(
              backgroundColor: _bgColor(isDark),
              body: Center(
                child: CircularProgressIndicator(color: _goldColor(isDark)),
              ),
            );
          }

          if (downloadState is! QuranDownloadSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) BottomNavVisibility.show(context);
            });
            return _buildDownloadPrompt(isDark, cfg, downloadState);
          }

          return BlocProvider.value(
            value: _cubit,
            child: MultiBlocListener(
              listeners: [
                BlocListener<QuranCubit, QuranState>(
                  listenWhen: (prev, curr) =>
                      prev is! QuranReady && curr is QuranReady,
                  listener: (_, state) {
                    // Hide bottom nav immediately when Quran is ready for immersive reading
                    _autoHideTimer?.cancel();
                    if (mounted) BottomNavVisibility.hide(context);
                  },
                ),
              ],
              child: BlocBuilder<QuranCubit, QuranState>(
                buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
                builder: (context, state) {
                  Widget child;
                  if (!_isReady ||
                      state is QuranInitial ||
                      state is QuranPrefsLoading) {
                    child = Scaffold(
                      key: const ValueKey('quran_loading'),
                      backgroundColor: _bgColor(isDark),
                      body: Center(
                        child: CircularProgressIndicator(
                          color: _goldColor(isDark),
                        ),
                      ),
                    );
                  } else if (state is QuranError) {
                    child = Scaffold(
                      key: const ValueKey('quran_error'),
                      backgroundColor: _bgColor(isDark),
                      body: Center(
                        child: Text(
                          state.message,
                          style: GoogleFonts.amiri(color: _goldColor(isDark)),
                        ),
                      ),
                    );
                  } else {
                    child = _buildMainScreen(isDark, cfg);
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: child,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Main Screen ──────────────────────────────────────────────────────
  Widget _buildMainScreen(bool isDark, MushafConfig cfg) {
    final gold = _goldColor(isDark);
    final targetPage = _cubit.currentPageNotifier.value > 0
        ? _cubit.currentPageNotifier.value
        : ((_cubit.state is QuranReady)
            ? (_cubit.state as QuranReady).currentPage
            : 1);
    final initialPage = (targetPage - 1).clamp(0, 603);

    return Scaffold(
      key: const ValueKey('quran_main_content'),
      backgroundColor: _bgColor(isDark),
      body: Stack(
        children: [
          // ── Mushaf ornamental frame & background tap ───────────────────
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _cubit.toggleOverlay();
                final r = _cubit.state;
                final bool showOverlay = r is QuranReady && r.showOverlay;
                if (showOverlay) {
                  BottomNavVisibility.show(context);
                } else {
                  BottomNavVisibility.hide(context);
                }
                HapticFeedback.lightImpact();
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: gold.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Image-based Quran page view (fast GPU rendering) ──────────
          RepaintBoundary(
            child: BlocSelector<QuranCubit, QuranState, AudioStatus>(
              selector: (s) =>
                  s is QuranReady ? s.audioStatus : const AudioStatus.idle(),
              builder: (context, audioStatus) {
                final String? playingAyahKey =
                    (audioStatus.isPlaying || audioStatus.isLoading) &&
                        audioStatus.surah != null &&
                        audioStatus.ayah != null
                    ? '${audioStatus.surah}_${audioStatus.ayah}'
                    : null;

                return QuranPageView(
                  controller: _quranController,
                  initialPage: initialPage,
                  pageImagePath: _pagesPath,
                  themeModeAdaption: true,
                  highlightedAyahKey: playingAyahKey,
                  // Hide the built-in top bar — we draw our own overlay
                  showPageTopBar: false,
                  // Hide built-in page number — we show it in our overlay
                  showPageNumber: false,
                  // Hide search icon — we use our own search sheet
                  showSearchIcon: false,
                  quranTextColor: isDark ? Colors.white : Colors.black,
                  highlightColor: gold.withValues(alpha: 0.35),

                  // ── Ayah tap → tafsir + audio actions ────────────────────
                  onAyahTap: (surah, ayah, page) {
                    HapticFeedback.mediumImpact();
                    _cubit.fetchTafsir(surah, ayah);
                    _showTafsirSheet(isDark, cfg);
                  },

                  // ── Tap anywhere on the page (outside ayahs) to toggle overlay + bottom nav ─
                  onPageTap: () {
                    _cubit.toggleOverlay();
                    final r = _cubit.state;
                    final bool showOverlay = r is QuranReady && r.showOverlay;
                    if (showOverlay) {
                      BottomNavVisibility.show(context);
                    } else {
                      BottomNavVisibility.hide(context);
                    }
                    HapticFeedback.lightImpact();
                  },

                  // ── Page change callback ──────────────────────────────────
                  onPageChanged: (pageNumber) {
                    _cubit.onPageChanged(pageNumber);
                    HapticFeedback.lightImpact();
                  },

                  // ── Ayah long-press menu disabled ─────────────────────────
                  showAyahMenu: false,

                  // ── Colors for built-in search sheet (not shown but themed) ─
                  searchSheetBackgroundColor: isDark
                      ? AppColors.bottomSheetDark
                      : AppColors.bottomSheetLight,
                  searchSheetDarkBackgroundColor: AppColors.bottomSheetDark,
                  searchFieldBackgroundColor: gold.withValues(alpha: 0.08),
                  searchFieldDarkBackgroundColor: gold.withValues(alpha: 0.12),
                  searchResultInfoColor: gold,
                  selectionResultInfoColor: gold,
                  selectionSheetHighlightColor: gold.withValues(alpha: 0.12),
                  selectionSheetDarkHighlightColor: gold.withValues(
                    alpha: 0.25,
                  ),
                  pageNumberColor: gold,
                  pageNumberDesign: PageNumberDesign.outlined,
                  pageNumberBorderColor: gold.withValues(alpha: 0.4),
                );
              },
            ),
          ),

          // ── Top overlay (page number, surah, juz) ─────────────────────
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

          // ── Bookmark ribbon ──────────────────────────────────────────
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
                        color: gold,
                        width: cfg.isTablet ? 28 : 22,
                        height: cfg.isTablet ? 74 : 60,
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // ── Audio player ─────────────────────────────────────────────
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

      // ── FAB: page options (opens on overlay) ─────────────────────────
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
                    color: gold,
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
    final colorScheme = Theme.of(context).colorScheme;
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
              _quranController.jumpToPage(state.bookmarkPage!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'لا توجد صفحة محفوظة',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: isDark ? Colors.grey[850] : Colors.grey[100],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
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
  }

  // ─── Reciter Selector ─────────────────────────────────────────────────
  void _openReciterSelector(QuranReady state, bool isDark, MushafConfig cfg) {
    final colorScheme = Theme.of(context).colorScheme;
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
                            textColor: colorScheme.onSurface,
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

  // ─── Surah Index ──────────────────────────────────────────────────────
  void _openSurahIndex(QuranReady state, bool isDark, MushafConfig cfg) {
    final colorScheme = Theme.of(context).colorScheme;
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
              // getPageNumber returns 1-based
              final page = getPageNumber(surahNum, 1);
              _quranController.jumpToPage(page);
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
          _quranController.jumpToPage(targetPage);
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
