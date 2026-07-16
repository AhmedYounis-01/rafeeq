// ═══════════════════════════════════════════════════════════════════════════
// Tafsir Model
// ═══════════════════════════════════════════════════════════════════════════
class TafsirData {
  final int surah;
  final int ayah;
  final String surahName;
  final String verseText;
  final String tafsir;
  final bool isLoading;
  final bool noInternet;
  final bool hasError;

  const TafsirData({
    required this.surah,
    required this.ayah,
    required this.surahName,
    required this.verseText,
    this.tafsir = '',
    this.isLoading = false,
    this.noInternet = false,
    this.hasError = false,
  });

  TafsirData copyWith({
    String? tafsir,
    bool? isLoading,
    bool? noInternet,
    bool? hasError,
  }) => TafsirData(
    surah: surah,
    ayah: ayah,
    surahName: surahName,
    verseText: verseText,
    tafsir: tafsir ?? this.tafsir,
    isLoading: isLoading ?? this.isLoading,
    noInternet: noInternet ?? this.noInternet,
    hasError: hasError ?? this.hasError,
  );
}
