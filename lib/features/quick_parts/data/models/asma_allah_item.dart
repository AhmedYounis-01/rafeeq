class AsmaAllahItem {
  final String ar;
  final String en;
  final String description;

  const AsmaAllahItem({
    required this.ar,
    required this.en,
    required this.description,
  });

  factory AsmaAllahItem.fromJson(Map<String, dynamic> json) {
    return AsmaAllahItem(
      ar: json['ar'] as String,
      en: json['en'] as String,
      description: json['description'] as String,
    );
  }
}
