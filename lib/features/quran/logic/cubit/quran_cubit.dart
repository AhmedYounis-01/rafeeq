import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meta/meta.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart'
    hide getPageData, getPageNumber;
import 'package:quran/quran.dart'
    hide getSurahNameArabic, getJuzNumber, getVerseCount, getVerse;
import 'package:shared_preferences/shared_preferences.dart';

part 'quran_state.dart';

// ─── قائمة القراء ─────────────────────────────────────────────────────────
const List<Map<String, String>> kReciters = [
  {'id': 'Alafasy_128kbps', 'name': 'مشاري العفاسي'},
  {'id': 'Abdurrahmaan_As-Sudais_192kbps', 'name': 'عبد الرحمن السديس'},
  {'id': 'MaherAlMuaiqly128kbps', 'name': 'ماهر المعيقلي'},
  {'id': 'Saood_ash-Shuraym_128kbps', 'name': 'سعود الشريم'},
  {'id': 'Hudhaify_128kbps', 'name': 'علي الحذيفي'},
  {'id': 'Minshawy_Murattal_128kbps', 'name': 'محمد صديق المنشاوي'},
  {'id': 'Husary_128kbps', 'name': 'محمود خليل الحصري'},
  {'id': 'Ahmed_ibn_Ali_al-Ajamy_128kbps', 'name': 'أحمد العجمي'},
  {'id': 'Muhammad_Jibreel_128kbps', 'name': 'محمد جبريل'},
  {'id': 'Muhammad_Ayyoub_128kbps', 'name': 'محمد أيوب'},
];

class QuranCubit extends Cubit<QuranState> {
  QuranCubit() : super(QuranInitial());

  // ─── Private deps ──────────────────────────────────────────────────────
  final AudioPlayer _player = AudioPlayer();
  late SharedPreferences _prefs;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<int?>? _playerIndexSub;

  bool _audioBusy = false;
  List<Map<String, int>> _sequenceMap = [];

  Color _highlightColor = const Color(0x66D4A853);
  void setHighlightColor(Color color) => _highlightColor = color;

  final ValueNotifier<List<HighlightVerse>> highlightsNotifier =
      ValueNotifier([]);

  // ─── Ayah Search ──────────────────────────────────────────────────────
  final ValueNotifier<List<AyahSearchResult>> ayahSearchResults =
      ValueNotifier([]);
  final ValueNotifier<bool> isSearchingAyahs = ValueNotifier(false);
  Timer? _searchDebounce;

  QuranReady? get _ready => state is QuranReady ? state as QuranReady : null;

  // ═══════════════════════════════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> init() async {
    if (state is QuranReady) return;

    emit(QuranPrefsLoading());

    try {
      _prefs = await SharedPreferences.getInstance();
      final page = _prefs.getInt('last_page') ?? 1;
      final bookmark = _prefs.getInt('last_bookmark_page');
      final savedReciter = _prefs.getString('reciter_id');
      final reciterId =
          (savedReciter != null &&
                  kReciters.any((r) => r['id'] == savedReciter))
              ? savedReciter
              : kReciters.first['id']!;

      emit(QuranFontsLoading(0.0));

      _loadFontsInBackground(
        onReady: () => emit(QuranReady(
          currentPage: page,
          bookmarkPage: bookmark,
          selectedReciterId: reciterId,
        )),
      );

      _setupAudioListeners();
    } catch (e) {
      emit(QuranError('حدث خطأ أثناء التهيئة: $e'));
    }
  }

  void _loadFontsInBackground({required VoidCallback onReady}) {
    QcfFontLoader.setupFontsAtStartup(
      onProgress: (progress) {
        if (state is QuranFontsLoading) {
          emit(QuranFontsLoading(progress));
        }
      },
    ).then((_) {
      if (!isClosed) onReady();
    }).catchError((e) {
      debugPrint('Font loading error: $e');
      if (!isClosed) onReady();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAGE NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════
  void onPageChanged(int page) {
    final r = _ready;
    if (r == null || r.currentPage == page) return;
    emit(r.copyWith(currentPage: page));
    _prefs.setInt('last_page', page);
  }

  void toggleOverlay() {
    final r = _ready;
    if (r == null) return;
    emit(r.copyWith(showOverlay: !r.showOverlay));
  }

  void hideOverlay() {
    final r = _ready;
    if (r == null || !r.showOverlay) return;
    emit(r.copyWith(showOverlay: false));
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BOOKMARK
  // ═══════════════════════════════════════════════════════════════════════
  void setBookmark(int page) {
    final r = _ready;
    if (r == null) return;
    emit(r.copyWith(bookmarkPage: page));
    _prefs.setInt('last_bookmark_page', page);
  }

  void clearBookmark() {
    final r = _ready;
    if (r == null) return;
    emit(r.copyWith(clearBookmark: true));
    _prefs.remove('last_bookmark_page');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // RECITER
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> selectReciter(String reciterId) async {
    final r = _ready;
    if (r == null || r.selectedReciterId == reciterId) return;

    emit(r.copyWith(selectedReciterId: reciterId));
    await _prefs.setString('reciter_id', reciterId);

    final audio = r.audioStatus;
    if (audio.isActive && !audio.isLoading && audio.surah != null) {
      if (audio.isSurahMode) {
        await playSurah(audio.surah!);
      } else if (audio.ayah != null) {
        await playAyah(audio.surah!, audio.ayah!);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AYAH SEARCH — يشتغل في isolate منفصل عشان مايوقفش الـ UI
  // ═══════════════════════════════════════════════════════════════════════

  /// إزالة التشكيل لمقارنة مرنة
  static String _stripDiacritics(String s) => s.replaceAll(
    RegExp(
      r'[\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED]',
    ),
    '',
  );

  /// تُشتغل في isolate — يجب أن تكون static
  static List<AyahSearchResult> _runAyahSearch(String query) {
    final results = <AyahSearchResult>[];

    // بحث بمرجع مباشر: سورة:آية مثل "2:255"
    final refMatch = RegExp(r'^(\d+)[:\-](\d+)$').firstMatch(query);
    if (refMatch != null) {
      final s = int.tryParse(refMatch.group(1) ?? '');
      final a = int.tryParse(refMatch.group(2) ?? '');
      if (s != null && a != null && s >= 1 && s <= 114) {
        final count = getVerseCount(s);
        if (a >= 1 && a <= count) {
          results.add(AyahSearchResult(
            surah: s,
            ayah: a,
            surahName: getSurahNameArabic(s),
            verseText: getVerse(s, a),
          ));
        }
      }
      return results;
    }

    // بحث بالنص — مع تجاهل التشكيل
    final qStripped = _stripDiacritics(query);
    if (qStripped.length < 2) return results; // حد أدنى 2 حروف

    for (int s = 1; s <= 114; s++) {
      final count = getVerseCount(s);
      for (int a = 1; a <= count; a++) {
        final verse = getVerse(s, a);
        if (_stripDiacritics(verse).contains(qStripped)) {
          results.add(AyahSearchResult(
            surah: s,
            ayah: a,
            surahName: getSurahNameArabic(s),
            verseText: verse,
          ));
          if (results.length >= 80) return results; // حد أقصى 80 نتيجة
        }
      }
    }
    return results;
  }

  /// يُستدعى من الـ UI — debounced + compute
  void searchAyahs(String query) {
    _searchDebounce?.cancel();
    final q = query.trim();

    if (q.isEmpty) {
      ayahSearchResults.value = [];
      isSearchingAyahs.value = false;
      return;
    }

    isSearchingAyahs.value = true;

    _searchDebounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final results = await compute(_runAyahSearch, q);
        if (!isClosed) {
          ayahSearchResults.value = results;
          isSearchingAyahs.value = false;
        }
      } catch (e) {
        debugPrint('Ayah search error: $e');
        if (!isClosed) isSearchingAyahs.value = false;
      }
    });
  }

  void clearAyahSearch() {
    _searchDebounce?.cancel();
    ayahSearchResults.value = [];
    isSearchingAyahs.value = false;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AUDIO — Internet check
  // ═══════════════════════════════════════════════════════════════════════
  Future<bool> checkInternet() async {
    try {
      final socket = await Socket.connect('8.8.8.8', 53,
          timeout: const Duration(seconds: 3));
      socket.destroy();
      return true;
    } catch (_) {
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 4));
        return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  String _audioUrl(int surah, int ayah) {
    final reciter = _ready?.selectedReciterId ?? kReciters.first['id']!;
    return 'https://everyayah.com/data/$reciter/'
        '${surah.toString().padLeft(3, '0')}'
        '${ayah.toString().padLeft(3, '0')}.mp3';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AUDIO — Listeners
  // ═══════════════════════════════════════════════════════════════════════
  void _setupAudioListeners() {
    _playerStateSub = _player.playerStateStream.listen((ps) {
      if (isClosed) return;
      final r = _ready;
      if (r == null) return;

      final isLoading = ps.processingState == ProcessingState.loading ||
          ps.processingState == ProcessingState.buffering;

      if (ps.processingState == ProcessingState.completed) {
        _resetAudioInternal();
        return;
      }

      emit(r.copyWith(
        audioStatus: r.audioStatus
            .copyWith(isPlaying: ps.playing, isLoading: isLoading),
      ));
    });

    _playerIndexSub = _player.currentIndexStream.listen((index) {
      if (isClosed) return;
      final r = _ready;
      if (r == null || index == null || !r.audioStatus.isSurahMode) return;
      if (index >= _sequenceMap.length) return;

      final m = _sequenceMap[index];
      final surah = m['surah']!;
      final ayah = m['ayah']!;

      emit(r.copyWith(
        audioStatus: r.audioStatus.copyWith(surah: surah, ayah: ayah),
      ));

      _updateHighlight(surah, ayah, r.currentPage);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // AUDIO — Play
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> playAyah(int surah, int ayah) async {
    if (_audioBusy) return;
    final r = _ready;
    if (r == null) return;

    final audio = r.audioStatus;
    if (audio.surah == surah &&
        audio.ayah == ayah &&
        audio.mode == AudioPlayMode.ayah) {
      audio.isPlaying ? await _player.pause() : await _player.play();
      return;
    }

    if (!await checkInternet()) {
      _emitNoInternet();
      return;
    }

    _audioBusy = true;
    _sequenceMap = [];
    try {
      await _player.stop();
      if (isClosed) return;
      emit(r.copyWith(
        audioStatus: AudioStatus(
            mode: AudioPlayMode.ayah,
            surah: surah,
            ayah: ayah,
            isLoading: true),
      ));
      _updateHighlight(surah, ayah, r.currentPage);
      await _player.setUrl(_audioUrl(surah, ayah));
      await _player.play();
    } catch (_) {
      _emitNoInternet();
      _resetAudioInternal();
    } finally {
      _audioBusy = false;
    }
  }

  Future<void> playSurah(int surah) async {
    if (_audioBusy) return;
    final r = _ready;
    if (r == null) return;

    final audio = r.audioStatus;
    if (audio.surah == surah && audio.mode == AudioPlayMode.surah) {
      audio.isPlaying ? await _player.pause() : await _player.play();
      return;
    }

    if (!await checkInternet()) {
      _emitNoInternet();
      return;
    }

    _audioBusy = true;
    final count = getVerseCount(surah);
    _sequenceMap =
        List.generate(count, (i) => {'surah': surah, 'ayah': i + 1});
    final sources = List.generate(
      count,
      (i) => AudioSource.uri(Uri.parse(_audioUrl(surah, i + 1))),
    );

    try {
      await _player.stop();
      if (isClosed) return;
      emit(r.copyWith(
        audioStatus: AudioStatus(
            mode: AudioPlayMode.surah,
            surah: surah,
            ayah: 1,
            isLoading: true),
      ));
      _updateHighlight(surah, 1, r.currentPage);
      await _player.setAudioSources(sources,
          initialIndex: 0,
          initialPosition: Duration.zero,
          preload: false);
      await _player.play();
    } catch (_) {
      _emitNoInternet();
      _resetAudioInternal();
    } finally {
      _audioBusy = false;
    }
  }

  Future<void> playPage(int page) async {
    if (_audioBusy) return;
    final r = _ready;
    if (r == null) return;

    if (!await checkInternet()) {
      _emitNoInternet();
      return;
    }

    _audioBusy = true;
    final pageData = getPageData(page);
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

    final firstSurah = pageData.first['surah'] as int;
    final firstAyah = pageData.first['start'] as int;

    try {
      await _player.stop();
      if (isClosed) return;
      emit(r.copyWith(
        audioStatus: AudioStatus(
            mode: AudioPlayMode.page,
            surah: firstSurah,
            ayah: firstAyah,
            isLoading: true),
      ));
      _updateHighlight(firstSurah, firstAyah, r.currentPage);
      await _player.setAudioSources(sources,
          initialIndex: 0,
          initialPosition: Duration.zero,
          preload: false);
      await _player.play();
    } catch (_) {
      _emitNoInternet();
      _resetAudioInternal();
    } finally {
      _audioBusy = false;
    }
  }

  Future<void> togglePlayPause() async =>
      _player.playing ? _player.pause() : _player.play();

  Future<void> stopAudio() async {
    await _player.stop();
    _resetAudioInternal();
  }

  Future<void> seekTo(double fraction) async {
    final duration = _player.duration;
    if (duration == null || duration == Duration.zero) return;
    await _player.seek(
        Duration(milliseconds: (fraction * duration.inMilliseconds).round()));
  }

  void _resetAudioInternal() {
    if (isClosed) return;
    _audioBusy = false;
    _sequenceMap = [];
    highlightsNotifier.value = [];
    final r = _ready;
    if (r == null) return;
    emit(r.copyWith(audioStatus: const AudioStatus.idle()));
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HIGHLIGHTS
  // ═══════════════════════════════════════════════════════════════════════
  void _updateHighlight(int surah, int ayah, int currentPage) {
    final targetPage = getPageNumber(surah, ayah);
    highlightsNotifier.value = [
      HighlightVerse(
        surah: surah,
        verseNumber: ayah,
        page: targetPage,
        color: _highlightColor,
      ),
    ];

    if (currentPage != targetPage) {
      _pageJumpController.add(targetPage - 1);
    }
  }

  final StreamController<int> _pageJumpController =
      StreamController<int>.broadcast();

  Stream<int> get pageJumpStream => _pageJumpController.stream;

  // ═══════════════════════════════════════════════════════════════════════
  // STREAMS
  // ═══════════════════════════════════════════════════════════════════════
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  // ═══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════
  int getJuz(int page) {
    final data = getPageData(page);
    return getJuzNumber(
        data.first['surah'] as int, data.first['start'] as int);
  }

  String getHizb(int page) {
    final hizbNum = ((page - 1) / 10).floor().clamp(0, 59) + 1;
    final quarter = (((page - 1) % 10) / 2.5).floor().clamp(0, 3);
    const quarters = ['', ' ½', ' ¾', ''];
    return 'حزب $hizbNum${quarters[quarter]}';
  }

  String getSurahDisplayName(int page) {
    final data = getPageData(page);
    final first = data.first['surah'] as int;
    final last = data.last['surah'] as int;
    return first == last
        ? getSurahNameArabic(first)
        : '${getSurahNameArabic(first)} - ${getSurahNameArabic(last)}';
  }

  String getReciterName(String id) => kReciters.firstWhere(
        (r) => r['id'] == id,
        orElse: () => kReciters.first,
      )['name']!;

  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  Stream<String> get errorStream => _errorController.stream;

  void _emitNoInternet() {
    if (!_errorController.isClosed) _errorController.add('no_internet');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════════════════════════════════
  @override
  Future<void> close() async {
    _searchDebounce?.cancel();
    await _playerStateSub?.cancel();
    await _playerIndexSub?.cancel();
    await _player.dispose();
    await _pageJumpController.close();
    await _errorController.close();
    highlightsNotifier.dispose();
    ayahSearchResults.dispose();
    isSearchingAyahs.dispose();
    return super.close();
  }
}