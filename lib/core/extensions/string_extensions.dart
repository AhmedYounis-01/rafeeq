extension StringExtension on String? {
  bool isNullOrEmpty() => this == null || this == "";

  String getFirstTwoWords() {
    List<String> words = this!.split(' ');
    if (words.length <= 2) {
      return this!;
    }
    return '${words[0]} ${words[1]}';
  }
}
