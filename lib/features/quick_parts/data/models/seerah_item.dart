class SeerahItem {
  final int id;
  final String category;
  final String title;
  final String content;

  const SeerahItem({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
  });

  factory SeerahItem.fromJson(Map<String, dynamic> json) {
    return SeerahItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      category: (json['category'] as String?)?.trim() ?? '',
      title: (json['title'] as String?)?.trim() ?? '',
      content: (json['content'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'content': content,
    };
  }
}
