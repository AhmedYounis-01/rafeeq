class SeerahItem {
  final String category;
  final String categoryEn;
  final String title;
  final String titleEn;
  final String content;
  final String contentEn;

  const SeerahItem({
    required this.category,
    required this.categoryEn,
    required this.title,
    required this.titleEn,
    required this.content,
    required this.contentEn,
  });

  factory SeerahItem.fromJson(Map<String, dynamic> json) {
    return SeerahItem(
      category: json['category'] as String,
      categoryEn: json['categoryEn'] as String,
      title: json['title'] as String,
      titleEn: json['titleEn'] as String,
      content: json['content'] as String,
      contentEn: json['contentEn'] as String,
    );
  }
}
