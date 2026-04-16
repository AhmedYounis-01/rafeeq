part of 'seerah_cubit.dart';

class SeerahState extends Equatable {
  final bool isLoaded;
  final bool isSearching;
  final bool hasSearchResult;
  final int currentSearchInstance;
  final int totalSearchInstances;

  const SeerahState({
    this.isLoaded = false,
    this.isSearching = false,
    this.hasSearchResult = false,
    this.currentSearchInstance = 0,
    this.totalSearchInstances = 0,
  });

  SeerahState copyWith({
    bool? isLoaded,
    bool? isSearching,
    bool? hasSearchResult,
    int? currentSearchInstance,
    int? totalSearchInstances,
  }) {
    return SeerahState(
      isLoaded: isLoaded ?? this.isLoaded,
      isSearching: isSearching ?? this.isSearching,
      hasSearchResult: hasSearchResult ?? this.hasSearchResult,
      currentSearchInstance: currentSearchInstance ?? this.currentSearchInstance,
      totalSearchInstances: totalSearchInstances ?? this.totalSearchInstances,
    );
  }

  @override
  List<Object> get props => [
        isLoaded,
        isSearching,
        hasSearchResult,
        currentSearchInstance,
        totalSearchInstances,
      ];
}