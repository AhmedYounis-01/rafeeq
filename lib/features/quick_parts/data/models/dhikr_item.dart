class DhikrItem {
  final String cat;
  final String catEn;
  final String text;
  final String transliteration;
  final String meaning;
  final String meaningAr;
  final int count;
  final String sub;
  final String subEn;

  const DhikrItem({
    required this.cat,
    required this.catEn,
    required this.text,
    required this.transliteration,
    required this.meaning,
    required this.meaningAr,
    required this.count,
    required this.sub,
    required this.subEn,
  });

  factory DhikrItem.fromJson(Map<String, dynamic> json) {
    return DhikrItem(
      cat: json['cat'] as String,
      catEn: json['catEn'] as String,
      text: json['text'] as String,
      transliteration: json['transliteration'] as String,
      meaning: json['meaning'] as String,
      meaningAr: json['meaningAr'] as String,
      count: json['count'] as int,
      sub: json['sub'] as String,
      subEn: json['subEn'] as String,
    );
  }
}
