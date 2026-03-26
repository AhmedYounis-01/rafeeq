class TasbihModel {
  final String cat;
  final String catEn;
  final String text;
  final String transliteration;
  final String meaning;
  final String meaningAr;
  final String sub;
  final String subEn;
  final int count;

  const TasbihModel({
    required this.cat,
    required this.catEn,
    required this.text,
    required this.transliteration,
    required this.meaning,
    required this.meaningAr,
    required this.sub,
    required this.subEn,
    required this.count,
  });

  factory TasbihModel.fromJson(Map<String, dynamic> json) => TasbihModel(
        cat: json['cat'] as String,
        catEn: json['catEn'] as String,
        text: json['text'] as String,
        transliteration: json['transliteration'] as String,
        meaning: json['meaning'] as String,
        meaningAr: json['meaningAr'] as String,
        sub: json['sub'] as String,
        subEn: json['subEn'] as String,
        count: json['count'] as int,
      );

  Map<String, dynamic> toJson() => {
        'cat': cat,
        'catEn': catEn,
        'text': text,
        'transliteration': transliteration,
        'meaning': meaning,
        'meaningAr': meaningAr,
        'sub': sub,
        'subEn': subEn,
        'count': count,
      };
}