part of 'quran_cubit.dart';

@immutable
sealed class QuranState {}

final class QuranInitial extends QuranState {}

final class QuranPrefsLoading extends QuranState {}

final class QuranFontsLoading extends QuranState {
  final double progress;
  QuranFontsLoading(this.progress);
}

final class QuranReady extends QuranState {
  final int currentPage;
  final int? bookmarkPage;
  final String selectedReciterId;
  final AudioStatus audioStatus;
  final bool showOverlay;

  QuranReady({
    required this.currentPage,
    required this.selectedReciterId,
    this.bookmarkPage,
    this.audioStatus = const AudioStatus.idle(),
    this.showOverlay = false,
  });

  QuranReady copyWith({
    int? currentPage,
    int? bookmarkPage,
    bool clearBookmark = false,
    String? selectedReciterId,
    AudioStatus? audioStatus,
    bool? showOverlay,
  }) => QuranReady(
    currentPage: currentPage ?? this.currentPage,
    bookmarkPage: clearBookmark ? null : (bookmarkPage ?? this.bookmarkPage),
    selectedReciterId: selectedReciterId ?? this.selectedReciterId,
    audioStatus: audioStatus ?? this.audioStatus,
    showOverlay: showOverlay ?? this.showOverlay,
  );
}

final class QuranError extends QuranState {
  final String message;
  QuranError(this.message);
}

// ═══════════════════════════════════════════════════════════════════════════
enum AudioPlayMode { idle, ayah, surah, page }

final class AudioStatus {
  final AudioPlayMode mode;
  final int? surah;
  final int? ayah;
  final bool isPlaying;
  final bool isLoading;

  const AudioStatus.idle()
    : mode = AudioPlayMode.idle,
      surah = null,
      ayah = null,
      isPlaying = false,
      isLoading = false;

  const AudioStatus({
    required this.mode,
    this.surah,
    this.ayah,
    this.isPlaying = false,
    this.isLoading = false,
  });

  bool get isActive => mode != AudioPlayMode.idle;
  bool get isSurahMode =>
      mode == AudioPlayMode.surah || mode == AudioPlayMode.page;

  AudioStatus copyWith({
    AudioPlayMode? mode,
    int? surah,
    int? ayah,
    bool? isPlaying,
    bool? isLoading,
  }) => AudioStatus(
    mode: mode ?? this.mode,
    surah: surah ?? this.surah,
    ayah: ayah ?? this.ayah,
    isPlaying: isPlaying ?? this.isPlaying,
    isLoading: isLoading ?? this.isLoading,
  );

  @override
  bool operator ==(Object other) =>
      other is AudioStatus &&
      other.mode == mode &&
      other.surah == surah &&
      other.ayah == ayah &&
      other.isPlaying == isPlaying &&
      other.isLoading == isLoading;

  @override
  int get hashCode => Object.hash(mode, surah, ayah, isPlaying, isLoading);
}

// ═══════════════════════════════════════════════════════════════════════════
// Ayah Search Result Model
// ═══════════════════════════════════════════════════════════════════════════
class AyahSearchResult {
  final int surah;
  final int ayah;
  final String surahName;
  final String verseText;

  const AyahSearchResult({
    required this.surah,
    required this.ayah,
    required this.surahName,
    required this.verseText,
  });
}