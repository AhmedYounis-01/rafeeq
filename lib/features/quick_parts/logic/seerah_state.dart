part of 'seerah_cubit.dart';

enum SeerahStatus { initial, loading, loaded, error }

class SeerahState extends Equatable {
  final SeerahStatus status;
  final List<SeerahItem> items;
  final int currentIndex;
  final double fontSize;
  final bool isSearching;
  final String searchQuery;
  final String? selectedCategory;
  final String? errorMessage;

  const SeerahState({
    this.status = SeerahStatus.initial,
    this.items = const [],
    this.currentIndex = 0,
    this.fontSize = 18.0,
    this.isSearching = false,
    this.searchQuery = '',
    this.selectedCategory,
    this.errorMessage,
  });

  bool get isLoading => status == SeerahStatus.loading;
  bool get isLoaded => status == SeerahStatus.loaded;

  SeerahItem? get currentItem {
    if (items.isEmpty || currentIndex < 0 || currentIndex >= items.length) {
      return null;
    }
    return items[currentIndex];
  }

  List<String> get categories {
    final set = <String>{};
    for (final item in items) {
      if (item.category.isNotEmpty) {
        set.add(item.category);
      }
    }
    return set.toList();
  }

  List<SeerahItem> get filteredItems {
    return items.where((item) {
      final matchesCategory = selectedCategory == null ||
          selectedCategory!.isEmpty ||
          item.category == selectedCategory;
      if (!matchesCategory) return false;

      if (searchQuery.trim().isEmpty) return true;
      final query = searchQuery.trim().toLowerCase();
      final titleMatch = item.title.toLowerCase().contains(query);
      final contentMatch = item.content.toLowerCase().contains(query);
      return titleMatch || contentMatch;
    }).toList();
  }

  SeerahState copyWith({
    SeerahStatus? status,
    List<SeerahItem>? items,
    int? currentIndex,
    double? fontSize,
    bool? isSearching,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
    String? errorMessage,
  }) {
    return SeerahState(
      status: status ?? this.status,
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      fontSize: fontSize ?? this.fontSize,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        currentIndex,
        fontSize,
        isSearching,
        searchQuery,
        selectedCategory,
        errorMessage,
      ];
}