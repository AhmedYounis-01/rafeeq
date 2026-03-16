import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/quran.dart' as quran;
import 'package:just_audio/just_audio.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

const List<Map<String, String>> kReciters = [
  {'id': 'Alafasy_128kbps', 'name': 'مشاري العفاسي'},
  {'id': 'Abdurrahmaan_As-Sudais_192kbps', 'name': 'عبد الرحمن السديس'},
  {'id': 'Hudhaify_128kbps', 'name': 'علي الحذيفي'},
  {'id': 'Minshawy_Murattal_128kbps', 'name': 'محمد صديق المنشاوي'},
  {'id': 'Muhammad_Ayyoub_128kbps', 'name': 'محمد أيوب'},
  {'id': 'Abu_Bakr_Ash-Shaatree_128kbps', 'name': 'أبو بكر الشاطري'},
  {'id': 'MaherAlMuaiqly128kbps', 'name': 'ماهر المعيقلي'},
  {'id': 'Saood_ash-Shuraym_128kbps', 'name': 'سعود الشريم'},
];

// ─── Mushaf Responsive Config ─────────────────────────────────────────────────
class _MushafConfig {
  final double shortestSide;
  _MushafConfig(BuildContext context)
    : shortestSide = MediaQuery.of(context).size.shortestSide;

  bool get isTablet => shortestSide >= 600;

  double get quranFontSize => (shortestSide * 0.063).clamp(22.0, 36.0);
  double get basmalaFontSize => quranFontSize * 1.05;
  double get lineHeight => isTablet ? 2.25 : 2.1;

  double get surahNameFontSize => (shortestSide * 0.058).clamp(18.0, 32.0);
  double get pageNumFontSize => (shortestSide * 0.085).clamp(26.0, 46.0);
  double get overlayLabelSize => (shortestSide * 0.028).clamp(10.0, 16.0);
  double get overlayJuzSize => (shortestSide * 0.048).clamp(16.0, 26.0);
  double get overlaySurahSize => (shortestSide * 0.042).clamp(14.0, 24.0);

  double get hPadding => isTablet ? shortestSide * 0.06 : 16.0;
  double get vPadding => isTablet ? 20.0 : 12.0;
  double get maxWidth => isTablet ? shortestSide * 1.1 : double.infinity;

  double get badgeSize => (shortestSide * 0.075).clamp(28.0, 44.0);

  double get maxSheetWidth => isTablet ? 580.0 : double.infinity;

  double get playerLabelSize => (shortestSide * 0.038).clamp(13.0, 20.0);
  double get playerBtnSize => (shortestSide * 0.1).clamp(36.0, 56.0);

  double get headerBtnSize => (shortestSide * 0.1).clamp(34.0, 54.0);
  double get headerCircleSize => (shortestSide * 0.09).clamp(30.0, 48.0);
  double get headerIconSize => (shortestSide * 0.05).clamp(18.0, 28.0);
  double get headerVerseCount => (shortestSide * 0.028).clamp(10.0, 15.0);

  double get optionBtnSize => (shortestSide * 0.155).clamp(54.0, 80.0);
  double get optionFontSize => (shortestSide * 0.032).clamp(11.0, 16.0);
}

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final PageController _pageController = PageController();
  final AudioPlayer _player = AudioPlayer();
  final Map<String, LongPressGestureRecognizer> _recognizers = {};

  late SharedPreferences _prefs;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<int?>? _indexSub;
  bool _audioBusy = false;
  List<Map<String, int>> _sequenceMap = [];

  int _currentPage = 1;
  int? _lastBookmarkPage;
  bool _isLoading = true;
  bool _showOverlay = false;
  int? _playingSurah;
  int? _playingAyah;
  bool _isPlaying = false;
  bool _isSurahMode = false;
  bool _isAudioLoading = false;

  String _selectedReciterId = 'Minshawy_Murattal_128kbps';
  String get _selectedReciterName => kReciters.firstWhere(
    (r) => r['id'] == _selectedReciterId,
    orElse: () => kReciters.first,
  )['name']!;

  // ─── Colors — كلها من AppColors الآن ──────────────────────────────────────
  /// خلفية الصفحة — بيضاء دافئة للـ light، داكنة للـ dark
  Color _bgColor(bool isDark) =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundCard;

  /// اللون الذهبي — secondary من AppColors
  Color _goldColor(bool isDark) =>
      isDark ? AppColors.secondaryDark : AppColors.secondary;

  /// لون النص الأساسي
  Color _textColor(bool isDark) =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

  /// خلفية الـ sheets والـ cards
  Color _cardColor(bool isDark) =>
      isDark ? AppColors.backgroundCardDark : AppColors.backgroundCard;

  /// خلفية الـ audio player
  Color _playerBgColor(bool isDark) =>
      isDark ? AppColors.backgroundCardDark : AppColors.backgroundLight;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    for (final r in _recognizers.values) r.dispose();
    _recognizers.clear();
    _stateSub?.cancel();
    _indexSub?.cancel();
    _player.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _setupAudioListeners() {
    _stateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        _isAudioLoading =
            state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _playingSurah = null;
          _playingAyah = null;
          _isSurahMode = false;
          _isAudioLoading = false;
          _audioBusy = false;
        }
      });
    });

    _indexSub = _player.currentIndexStream.listen((index) {
      if (!mounted || index == null || !_isSurahMode) return;
      if (index < _sequenceMap.length) {
        final m = _sequenceMap[index];
        setState(() {
          _playingSurah = m['surah'];
          _playingAyah = m['ayah'];
        });
      }
    });
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await Future.wait([_loadLastPage(), _loadPrefs()]);
    _setupAudioListeners();
    if (mounted) setState(() => _isLoading = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentPage > 1) _pageController.jumpToPage(_currentPage - 1);
    });
  }

  Future<void> _loadLastPage() async =>
      _currentPage = _prefs.getInt('last_page') ?? 1;

  Future<void> _loadPrefs() async {
    _lastBookmarkPage = _prefs.getInt('last_bookmark_page');
    _selectedReciterId =
        _prefs.getString('reciter_id') ?? 'Minshawy_Murattal_128kbps';
  }

  Future<void> _savePage(int page) async => _prefs.setInt('last_page', page);

  Future<void> _saveBookmark() async {
    if (_lastBookmarkPage != null) {
      await _prefs.setInt('last_bookmark_page', _lastBookmarkPage!);
    } else {
      await _prefs.remove('last_bookmark_page');
    }
  }

  Future<void> _saveReciter() async =>
      _prefs.setString('reciter_id', _selectedReciterId);

  void _setBookmark(int page) {
    setState(() => _lastBookmarkPage = page);
    _saveBookmark();
    HapticFeedback.mediumImpact();
  }

  void _clearBookmark() {
    setState(() => _lastBookmarkPage = null);
    _saveBookmark();
    HapticFeedback.lightImpact();
  }

  bool _isPageBookmarked(int page) => _lastBookmarkPage == page;

  Future<bool> _hasInternet() async {
    try {
      final r = await InternetAddress.lookup(
        'everyayah.com',
      ).timeout(const Duration(seconds: 4));
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

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

  String _audioUrl(int surah, int ayah) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$_selectedReciterId/$s$a.mp3';
  }

  // ─── Audio ────────────────────────────────────────────────────────────────

  Future<void> _playAyah(int surah, int ayah) async {
    if (_audioBusy) return;
    if (_playingSurah == surah && _playingAyah == ayah && !_isSurahMode) {
      _isPlaying ? await _player.pause() : await _player.play();
      return;
    }
    if (!await _hasInternet()) {
      _showNoInternetSnack();
      return;
    }
    _audioBusy = true;
    _sequenceMap = [];
    try {
      await _player.stop();
      if (!mounted) return;
      setState(() {
        _playingSurah = surah;
        _playingAyah = ayah;
        _isSurahMode = false;
        _isPlaying = false;
        _isAudioLoading = true;
      });
      await _player.setUrl(_audioUrl(surah, ayah));
      await _player.play();
    } catch (e) {
      if (mounted) {
        _showNoInternetSnack();
        _resetAudioState();
      }
    } finally {
      _audioBusy = false;
    }
  }

  Future<void> _playSurah(int surah) async {
    if (_audioBusy) return;
    if (_playingSurah == surah && _isSurahMode) {
      _isPlaying ? await _player.pause() : await _player.play();
      return;
    }
    if (!await _hasInternet()) {
      _showNoInternetSnack();
      return;
    }
    _audioBusy = true;
    final count = quran.getVerseCount(surah);
    _sequenceMap = List.generate(count, (i) => {'surah': surah, 'ayah': i + 1});
    final sources = List.generate(
      count,
      (i) => AudioSource.uri(Uri.parse(_audioUrl(surah, i + 1))),
    );
    try {
      await _player.stop();
      if (!mounted) return;
      setState(() {
        _playingSurah = surah;
        _playingAyah = 1;
        _isSurahMode = true;
        _isPlaying = false;
        _isAudioLoading = true;
      });
      await _player.setAudioSources(
        sources,
        initialIndex: 0,
        initialPosition: Duration.zero,
        preload: false,
      );
      await _player.play();
    } catch (e) {
      if (mounted) {
        _showNoInternetSnack();
        _resetAudioState();
      }
    } finally {
      _audioBusy = false;
    }
  }

  Future<void> _playPage(int page) async {
    if (_audioBusy) return;
    if (!await _hasInternet()) {
      _showNoInternetSnack();
      return;
    }
    _audioBusy = true;
    final pageData = quran.getPageData(page);
    final sources = <AudioSource>[];
    final newMap = <Map<String, int>>[];
    for (final item in pageData) {
      final s = item['surah'] as int;
      final start = item['start'] as int;
      final end = item['end'] as int;
      for (int a = start; a <= end; a++) {
        sources.add(AudioSource.uri(Uri.parse(_audioUrl(s, a))));
        newMap.add({'surah': s, 'ayah': a});
      }
    }
    _sequenceMap = newMap;
    try {
      await _player.stop();
      if (!mounted) return;
      setState(() {
        _playingSurah = pageData.first['surah'] as int;
        _playingAyah = pageData.first['start'] as int;
        _isSurahMode = true;
        _isPlaying = false;
        _isAudioLoading = true;
      });
      await _player.setAudioSources(
        sources,
        initialIndex: 0,
        initialPosition: Duration.zero,
        preload: false,
      );
      await _player.play();
    } catch (e) {
      if (mounted) {
        _showNoInternetSnack();
        _resetAudioState();
      }
    } finally {
      _audioBusy = false;
    }
  }

  Future<void> _stopAudio() async {
    await _player.stop();
    _resetAudioState();
  }

  void _resetAudioState() {
    if (!mounted) return;
    _audioBusy = false;
    _sequenceMap = [];
    setState(() {
      _isPlaying = false;
      _playingSurah = null;
      _playingAyah = null;
      _isSurahMode = false;
      _isAudioLoading = false;
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  int _getJuz(int page) {
    final data = quran.getPageData(page);
    return quran.getJuzNumber(data.first['surah'], data.first['start']);
  }

  String _getHizb(int page) {
    final hizbNum = ((page - 1) / 10).floor().clamp(0, 59) + 1;
    final quarter = (((page - 1) % 10) / 2.5).floor().clamp(0, 3);
    const quarters = ['', ' ½', ' ¾', ''];
    return 'حزب $hizbNum${quarters[quarter]}';
  }

  String _getSurahDisplayName(int page) {
    final data = quran.getPageData(page);
    final first = data.first['surah'] as int;
    final last = data.last['surah'] as int;
    if (first == last) return quran.getSurahNameArabic(first);
    return '${quran.getSurahNameArabic(first)} - ${quran.getSurahNameArabic(last)}';
  }

  Future<void> _onPageTap(bool isDark) async {
    setState(() => _showOverlay = true);
    HapticFeedback.lightImpact();
    await _showPageOptions(isDark);
    if (mounted) setState(() => _showOverlay = false);
  }

  Future<void> _showPageOptions(bool isDark) {
    final cfg = _MushafConfig(context);
    final isBookmarked = _isPageBookmarked(_currentPage);
    final isPlayingPage = _isPlaying && _isSurahMode;
    final gold = _goldColor(isDark);

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (_) => _PageOptionsSheet(
        page: _currentPage,
        hizb: _getHizb(_currentPage),
        isBookmarked: isBookmarked,
        isPlayingPage: isPlayingPage,
        isPlaying: _isPlaying,
        gold: gold,
        isDark: isDark,
        bgColor: _cardColor(isDark),
        textColor: _textColor(isDark),
        selectedReciterName: _selectedReciterName,
        cfg: cfg,
        onPlayPage: () {
          Navigator.pop(context);
          isPlayingPage && _isPlaying
              ? _player.pause()
              : _playPage(_currentPage);
        },
        onBookmark: () {
          Navigator.pop(context);
          isBookmarked ? _clearBookmark() : _setBookmark(_currentPage);
        },
        onSelectReciter: () {
          Navigator.pop(context);
          _openReciterSelector(isDark);
        },
        onSurahIndex: () {
          Navigator.pop(context);
          _openSurahIndex(isDark);
        },
        onLastRead: () {
          Navigator.pop(context);
          if (_lastBookmarkPage != null) {
            _pageController.jumpToPage(_lastBookmarkPage! - 1);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('لا يوجد حفظ بعد', style: GoogleFonts.amiri()),
                backgroundColor: gold,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        onSearch: () => Navigator.pop(context),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = _MushafConfig(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bgColor(isDark),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'بسم الله الرحمن الرحيم',
                style: GoogleFonts.amiriQuran(
                  fontSize: cfg.basmalaFontSize,
                  color: _goldColor(isDark),
                ),
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(color: _goldColor(isDark)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor(isDark),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            reverse: true,
            itemCount: quran.totalPagesCount,
            onPageChanged: (i) {
              setState(() => _currentPage = i + 1);
              _savePage(_currentPage);
              HapticFeedback.lightImpact();
            },
            itemBuilder: (_, i) => _buildMushafPage(i + 1, isDark, cfg),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showOverlay ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 220),
              child: IgnorePointer(
                ignoring: !_showOverlay,
                child: _buildTopOverlay(isDark, cfg),
              ),
            ),
          ),
          if (_playingSurah != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 12,
              left: 14,
              right: 14,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: cfg.isTablet ? 660 : double.infinity,
                  ),
                  child: _buildAudioPlayer(isDark, cfg),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMushafPage(int page, bool isDark, _MushafConfig cfg) {
    final pageData = quran.getPageData(page);
    final isBookmarked = _isPageBookmarked(page);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _onPageTap(isDark),
        child: Container(
          color: _bgColor(isDark),
          child: Stack(
            children: [
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cfg.maxWidth),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: cfg.hPadding,
                        vertical: cfg.vPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _buildPageVerses(pageData, isDark, cfg),
                      ),
                    ),
                  ),
                ),
              ),
              if (isBookmarked)
                Positioned(
                  top: 0,
                  right: cfg.isTablet ? 28 : 20,
                  child: _LastReadRibbon(
                    color: _goldColor(isDark),
                    width: cfg.isTablet ? 28 : 22,
                    height: cfg.isTablet ? 74 : 60,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopOverlay(bool isDark, _MushafConfig cfg) {
    final juz = _getJuz(_currentPage);
    final surahName = _getSurahDisplayName(_currentPage);

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
                  '$_currentPage',
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

  List<Widget> _buildPageVerses(List pageData, bool isDark, _MushafConfig cfg) {
    final widgets = <Widget>[];
    for (final item in pageData) {
      final surah = item['surah'] as int;
      final start = item['start'] as int;
      final end = item['end'] as int;
      if (start == 1) {
        widgets.add(_buildSurahHeader(surah, isDark, cfg));
        if (surah != 1 && surah != 9)
          widgets.add(_buildBasmalaLine(isDark, cfg));
      }
      widgets.add(_buildVerseBlock(surah, start, end, isDark, cfg));
    }
    return widgets;
  }

  Widget _buildBasmalaLine(bool isDark, _MushafConfig cfg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Text(
        quran.basmala,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: GoogleFonts.amiriQuran(
          fontSize: cfg.basmalaFontSize,
          color: _textColor(isDark),
          height: 1.8,
        ),
      ),
    );
  }

  String _normalizeArabic(String s) =>
      s.replaceAll('\u0671', '\u0627').replaceAll('\u0640', '');

  String _verseText(int surah, int ayah) {
    final text = quran.getVerse(surah, ayah, verseEndSymbol: false);
    if (ayah == 1 && surah != 1 && surah != 9) {
      final normText = _normalizeArabic(text);
      final normBasmala = _normalizeArabic(quran.basmala);
      if (normText.startsWith(normBasmala)) {
        const marker = '\u0631\u0651\u064E\u062D\u0650\u064A\u0645\u0650';
        final idx = text.indexOf(marker);
        if (idx != -1) {
          final after = text.substring(idx + marker.length).trimLeft();
          return after.isEmpty ? text : after;
        }
      }
    }
    return text;
  }

  Widget _buildSurahHeader(int surah, bool isDark, _MushafConfig cfg) {
    final isPlaying = _playingSurah == surah && _isSurahMode;
    final gold = _goldColor(isDark);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.symmetric(
        horizontal: cfg.isTablet ? 20 : 16,
        vertical: cfg.isTablet ? 12 : 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: gold.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(cfg.isTablet ? 14 : 10),
        // هيدر السورة يستخدم containerLight/Dark من AppColors
        color: isDark
            ? AppColors.backgroundCardDark.withValues(alpha: 0.7)
            : AppColors.containerLight.withValues(alpha: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _playSurah(surah),
            child: Container(
              width: cfg.headerBtnSize,
              height: cfg.headerBtnSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying
                    ? gold.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(color: gold.withValues(alpha: 0.35)),
              ),
              child: _isAudioLoading && _playingSurah == surah && _isSurahMode
                  ? Padding(
                      padding: EdgeInsets.all(cfg.headerBtnSize * 0.22),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: gold,
                      ),
                    )
                  : Icon(
                      isPlaying && _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: gold,
                      size: cfg.headerIconSize,
                    ),
            ),
          ),
          Column(
            children: [
              Text(
                quran.getSurahNameArabic(surah),
                style: GoogleFonts.amiri(
                  fontSize: cfg.surahNameFontSize,
                  color: _textColor(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${quran.getVerseCount(surah)} آية',
                style: GoogleFonts.amiri(
                  fontSize: cfg.headerVerseCount,
                  color: gold.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Container(
            width: cfg.headerCircleSize,
            height: cfg.headerCircleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.4)),
              color: gold.withValues(alpha: 0.08),
            ),
            child: Center(
              child: Text(
                '$surah',
                style: GoogleFonts.amiri(
                  fontSize: cfg.headerIconSize * 0.7,
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseBlock(
    int surah,
    int start,
    int end,
    bool isDark,
    _MushafConfig cfg,
  ) {
    if (start > end) return const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        textAlign: TextAlign.justify,
        TextSpan(
          children: List.generate(end - start + 1, (i) {
            final ayah = start + i;
            final isPlayingThis =
                _playingSurah == surah && _playingAyah == ayah;
            final isSajdah = quran.isSajdahVerse(surah, ayah);
            final key = '${surah}_$ayah';

            final recognizer =
                _recognizers.putIfAbsent(
                    key,
                    () => LongPressGestureRecognizer(
                      duration: const Duration(milliseconds: 500),
                    ),
                  )
                  ..onLongPress = () {
                    HapticFeedback.mediumImpact();
                    _playAyah(surah, ayah);
                  };

            return TextSpan(
              children: [
                TextSpan(
                  text: _verseText(surah, ayah),
                  style: GoogleFonts.amiriQuran(
                    fontSize: cfg.quranFontSize,
                    color: _textColor(isDark),
                    height: cfg.lineHeight,
                    backgroundColor: isPlayingThis
                        ? _goldColor(isDark).withValues(alpha: 0.18)
                        : null,
                  ),
                  recognizer: recognizer,
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: _VerseEndBadge(
                    number: ayah,
                    isPlaying: isPlayingThis,
                    gold: _goldColor(isDark),
                    isDark: isDark,
                    size: cfg.badgeSize,
                    onTap: () => _showAyahOptions(surah, ayah, isDark, cfg),
                  ),
                ),
                if (isSajdah)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.south_rounded,
                        size: cfg.badgeSize * 0.32,
                        color: _goldColor(isDark).withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                const TextSpan(text: ' '),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _showAyahOptions(int surah, int ayah, bool isDark, _MushafConfig cfg) {
    final isPlayingThis =
        _playingSurah == surah && _playingAyah == ayah && !_isSurahMode;
    final gold = _goldColor(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: _cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: gold.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(isDark),
            const SizedBox(height: 14),
            Text(
              quran.getVerse(surah, ayah),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiriQuran(
                fontSize: cfg.quranFontSize * 0.88,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                height: 2.0,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${quran.getSurahNameArabic(surah)} • الآية $ayah',
              style: GoogleFonts.amiri(
                fontSize: cfg.overlayLabelSize + 2,
                color: gold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sheetAction(
                  icon: isPlayingThis && _isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: isPlayingThis && _isPlaying ? 'إيقاف' : 'تشغيل',
                  color: gold,
                  cfg: cfg,
                  onTap: () {
                    Navigator.pop(context);
                    _playAyah(surah, ayah);
                  },
                ),
                _sheetAction(
                  icon: Icons.copy_rounded,
                  label: 'نسخ',
                  color: gold,
                  cfg: cfg,
                  onTap: () {
                    Navigator.pop(context);
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            '${quran.getVerse(surah, ayah)}\n﴿${quran.getSurahNameArabic(surah)} - $ayah﴾',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم نسخ الآية',
                          style: GoogleFonts.amiri(),
                        ),
                        backgroundColor: gold,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
                _sheetAction(
                  icon: Icons.share_rounded,
                  label: 'مشاركة',
                  color: gold,
                  cfg: cfg,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetAction({
    required IconData icon,
    required String label,
    required Color color,
    required _MushafConfig cfg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: cfg.optionBtnSize * 0.88,
            height: cfg.optionBtnSize * 0.88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: color, size: cfg.optionBtnSize * 0.4),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.amiri(
              fontSize: cfg.optionFontSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(bool isDark, _MushafConfig cfg) {
    final gold = _goldColor(isDark);
    final surahName = quran.getSurahNameArabic(_playingSurah!);
    final label = _isSurahMode
        ? 'سورة $surahName'
        : 'سورة $surahName • آية $_playingAyah';
    final subtitle = _isSurahMode ? 'تشغيل السورة' : 'تشغيل آية';

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
              _isAudioLoading
                  ? SizedBox(
                      width: cfg.playerLabelSize + 6,
                      height: cfg.playerLabelSize + 6,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: gold,
                      ),
                    )
                  : _EqBars(
                      isPlaying: _isPlaying,
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
                icon: _isAudioLoading
                    ? Icons.hourglass_empty_rounded
                    : (_isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                color: gold,
                size: cfg.playerBtnSize * 0.58,
                onTap: _isAudioLoading
                    ? () {}
                    : () => _isPlaying ? _player.pause() : _player.play(),
                filled: true,
              ),
              const SizedBox(width: 6),
              _AudioBtn(
                icon: Icons.stop_rounded,
                color: gold.withValues(alpha: 0.55),
                size: cfg.playerBtnSize * 0.44,
                onTap: _stopAudio,
                filled: false,
              ),
            ],
          ),
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (_, posSnap) => StreamBuilder<Duration?>(
              stream: _player.durationStream,
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
                        onChanged: (v) {
                          if (duration > Duration.zero) {
                            _player.seek(
                              Duration(
                                milliseconds: (v * duration.inMilliseconds)
                                    .round(),
                              ),
                            );
                          }
                        },
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

  void _openReciterSelector(bool isDark) {
    final cfg = _MushafConfig(context);
    final gold = _goldColor(isDark);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: BoxDecoration(
            color: _cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: gold.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(isDark),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'اختر القارئ',
                  style: GoogleFonts.amiri(
                    fontSize: cfg.surahNameFontSize * 0.8,
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1, color: gold.withValues(alpha: 0.25)),
              ...kReciters.map((r) {
                final isSelected = r['id'] == _selectedReciterId;
                return ListTile(
                  onTap: () async {
                    setState(() => _selectedReciterId = r['id']!);
                    setSheet(() {});
                    await _saveReciter();
                    if (!mounted) return;
                    Navigator.pop(context);
                    if (_playingSurah != null && !_isAudioLoading) {
                      _isSurahMode
                          ? _playSurah(_playingSurah!)
                          : _playingAyah != null
                          ? _playAyah(_playingSurah!, _playingAyah!)
                          : null;
                    }
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  leading: Container(
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
                    r['name']!,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: cfg.surahNameFontSize * 0.72,
                      color: isSelected ? gold : _textColor(isDark),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _openSurahIndex(bool isDark) {
    final cfg = _MushafConfig(context);
    final gold = _goldColor(isDark);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: cfg.maxSheetWidth),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, sc) => Container(
          decoration: BoxDecoration(
            color: _cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: gold.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _sheetHandle(isDark),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'فهرس السور',
                  style: GoogleFonts.amiri(
                    fontSize: cfg.surahNameFontSize * 0.8,
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1, color: gold.withValues(alpha: 0.3)),
              Expanded(
                child: ListView.builder(
                  controller: sc,
                  itemCount: 114,
                  itemBuilder: (_, i) {
                    final s = i + 1;
                    final isPlayingThis = _playingSurah == s && _isSurahMode;
                    return ListTile(
                      onTap: () {
                        _pageController.jumpToPage(
                          quran.getPageNumber(s, 1) - 1,
                        );
                        Navigator.pop(context);
                      },
                      leading: Container(
                        width: cfg.headerCircleSize * 0.85,
                        height: cfg.headerCircleSize * 0.85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gold.withValues(alpha: 0.5),
                          ),
                          color: gold.withValues(alpha: 0.07),
                        ),
                        child: Center(
                          child: Text(
                            '$s',
                            style: GoogleFonts.amiri(
                              fontSize: cfg.headerIconSize * 0.65,
                              color: gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        quran.getSurahNameArabic(s),
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: cfg.surahNameFontSize * 0.72,
                          color: _textColor(isDark),
                        ),
                      ),
                      subtitle: Text(
                        '${quran.getVerseCount(s)} آية',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: cfg.overlayLabelSize,
                          color: gold.withValues(alpha: 0.6),
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _playSurah(s);
                        },
                        child: Container(
                          width: cfg.headerCircleSize * 0.85,
                          height: cfg.headerCircleSize * 0.85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPlayingThis && _isPlaying
                                ? gold.withValues(alpha: 0.2)
                                : gold.withValues(alpha: 0.07),
                            border: Border.all(
                              color: gold.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(
                            isPlayingThis && _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: gold,
                            size: cfg.headerIconSize * 0.65,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetHandle(bool isDark) => Container(
    margin: const EdgeInsets.only(top: 12, bottom: 4),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: _goldColor(isDark).withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(2),
    ),
  );
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
    required this.gold,
    required this.isDark,
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
                label: 'بحث',
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
// Audio button
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
// Equalizer bars
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
    for (final c in _ctrls)
      c.animateTo(0.2, duration: const Duration(milliseconds: 200));
  }

  @override
  void didUpdateWidget(_EqBars old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying)
      widget.isPlaying ? _start() : _stop();
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
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
          builder: (_, __) => Container(
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
// Verse-end badge
// ═══════════════════════════════════════════════════════════════════════════
class _VerseEndBadge extends StatelessWidget {
  final int number;
  final bool isPlaying;
  final Color gold;
  final bool isDark;
  final VoidCallback onTap;
  final double size;

  const _VerseEndBadge({
    required this.number,
    required this.isPlaying,
    required this.gold,
    required this.isDark,
    required this.onTap,
    this.size = 32,
  });

  String _toArabic(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = isPlaying ? gold : gold.withValues(alpha: 0.75);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _AyahEndPainter(color: activeColor, filled: isPlaying),
              ),
              Text(
                _toArabic(number),
                style: TextStyle(
                  fontSize: number > 99 ? size * 0.25 : size * 0.3,
                  fontWeight: FontWeight.bold,
                  color: isPlaying
                      ? (isDark ? AppColors.backgroundDark : AppColors.white)
                      : activeColor,
                  height: 1,
                  fontFamily: 'Amiri',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AyahEndPainter extends CustomPainter {
  final Color color;
  final bool filled;
  const _AyahEndPainter({required this.color, required this.filled});

  static const double _pi2 = 6.28318530717959;

  static double _sin(double x) {
    double r = x, t = x;
    for (int i = 1; i <= 8; i++) {
      t *= -x * x / ((2 * i) * (2 * i + 1));
      r += t;
    }
    return r;
  }

  static double _cos(double x) {
    double r = 1.0, t = 1.0;
    for (int i = 1; i <= 8; i++) {
      t *= -x * x / ((2 * i - 1) * (2 * i));
      r += t;
    }
    return r;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final innerR = size.width * 0.28;
    final petalR = size.width * 0.095;
    final petalCx = innerR + petalR * 0.88;
    final outerR = size.width * 0.47;

    final petalPaint = Paint()
      ..color = color.withValues(alpha: filled ? 0.85 : 0.5)
      ..style = PaintingStyle.fill;
    for (int k = 0; k < 8; k++) {
      final a = k * _pi2 / 8;
      canvas.drawCircle(
        Offset(cx + petalCx * _cos(a), cy + petalCx * _sin(a)),
        petalR,
        petalPaint,
      );
    }
    canvas.drawCircle(
      Offset(cx, cy),
      outerR,
      Paint()
        ..color = color.withValues(alpha: filled ? 0.55 : 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      innerR,
      Paint()
        ..color = filled ? color : color.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      innerR,
      Paint()
        ..color = color.withValues(alpha: filled ? 1.0 : 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _AyahEndPainter old) =>
      old.color != color || old.filled != filled;
}

// ═══════════════════════════════════════════════════════════════════════════
// Last-read ribbon
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
