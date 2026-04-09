class TasbihModel {
  final String cat;
  final String text; // Always Arabic dhikr text
  final String transliteration;
  final String meaning; // Localized at load time
  final String sub; // Localized at load time
  final int count;

  const TasbihModel({
    required this.cat,
    required this.text,
    required this.transliteration,
    required this.meaning,
    required this.sub,
    required this.count,
  });

  factory TasbihModel.fromJson(Map<String, dynamic> json) => TasbihModel(
        cat: json['cat'] as String,
        text: json['text'] as String,
        transliteration: json['transliteration'] as String,
        meaning: json['meaning'] as String,
        sub: json['sub'] as String,
        count: json['count'] as int,
      );

  Map<String, dynamic> toJson() => {
        'cat': cat,
        'text': text,
        'transliteration': transliteration,
        'meaning': meaning,
        'sub': sub,
        'count': count,
      };
}