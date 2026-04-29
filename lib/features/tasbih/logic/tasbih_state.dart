import 'package:equatable/equatable.dart';
import '../data/model/tasbih_model.dart';

class TasbihSession extends Equatable {
  final String dhikrText;
  final int count;
  final DateTime time;

  const TasbihSession({
    required this.dhikrText,
    required this.count,
    required this.time,
  });

  @override
  List<Object?> get props => [dhikrText, count, time];
}

class TasbihState extends Equatable {
  final List<TasbihModel> adhkar;
  final bool loading;
  final String? loadedLang;
  final int? selectedIdx;
  final int count;
  final bool completed;
  final bool silent;
  final List<TasbihSession> sessions;
  final int todayTotal;
  final String searchQuery;
  final String? activeCat;

  const TasbihState({
    this.adhkar = const [],
    this.loading = true,
    this.loadedLang,
    this.selectedIdx,
    this.count = 0,
    this.completed = false,
    this.silent = false,
    this.sessions = const [],
    this.todayTotal = 0,
    this.searchQuery = '',
    this.activeCat,
  });

  TasbihState copyWith({
    List<TasbihModel>? adhkar,
    bool? loading,
    String? loadedLang,
    Object? selectedIdx = _unset,
    int? count,
    bool? completed,
    bool? silent,
    String? searchQuery,
    String? activeCat,
    List<TasbihSession>? sessions,
    int? todayTotal,
  }) {
    return TasbihState(
      adhkar: adhkar ?? this.adhkar,
      loading: loading ?? this.loading,
      loadedLang: loadedLang ?? this.loadedLang,
      selectedIdx: selectedIdx == _unset
          ? this.selectedIdx
          : selectedIdx as int?,
      count: count ?? this.count,
      completed: completed ?? this.completed,
      silent: silent ?? this.silent,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCat: activeCat ?? this.activeCat,
      sessions: sessions ?? this.sessions,
      todayTotal: todayTotal ?? this.todayTotal,
    );
  }

  static const _unset = Object();

  // Helper for actual selected index that handles the "initial selection null" case
  int? get currentIdx => selectedIdx;
  TasbihModel? get currentDhikr =>
      selectedIdx != null ? adhkar[selectedIdx!] : null;

  @override
  List<Object?> get props => [
    adhkar,
    loading,
    loadedLang,
    selectedIdx,
    count,
    completed,
    silent,
    sessions,
    todayTotal,
    searchQuery,
    activeCat,
  ];
}
