class AsmaAllahItem {
  final String ar;
  final String en;
  final String descriptionAr;
  final String descriptionEn;

  const AsmaAllahItem({
    required this.ar,
    required this.en,
    required this.descriptionAr,
    required this.descriptionEn,
  });

  factory AsmaAllahItem.fromJson(Map<String, dynamic> json) {
    return AsmaAllahItem(
      ar: json['ar'] as String,
      en: json['en'] as String,
      descriptionAr: json['descriptionAr'] as String,
      descriptionEn: json['descriptionEn'] as String,
    );
  }
}
