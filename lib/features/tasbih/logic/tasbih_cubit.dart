import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../data/repository/tasbih_repository.dart';
import 'tasbih_state.dart';

class TasbihCubit extends Cubit<TasbihState> {
  TasbihCubit() : super(const TasbihState());

  // Arabic Normalization Logic (Moved for better performance and organization)
  static String normalizeArabic(String text) {
    if (text.isEmpty) return '';
    var s = text;
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    s = s.replaceAll(RegExp(r'[ئى]'), 'ي');
    s = s.replaceAll('ؤ', 'و');
    s = s.replaceAll('ة', 'ه');
    s = s.replaceAll('ـ', '');
    s = s.replaceAll(RegExp(r'[^\u0621-\u064A\s]'), '');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
  }

  Future<void> loadData(String langCode) async {
    if (state.loadedLang == langCode) return;

    emit(state.copyWith(loading: true));
    final data = await TasbihRepository.loadAll(langCode);

    emit(
      state.copyWith(
        adhkar: data,
        loading: false,
        loadedLang: langCode,
        selectedIdx: null,
        count: 0,
        completed: false,
      ),
    );
  }

  void selectDhikr(int? index) {
    if (!state.silent) HapticFeedback.selectionClick();
    emit(state.copyWith(selectedIdx: index, count: 0, completed: false));
  }

  void incrementCount() {
    if (state.selectedIdx == null) return;

    final dhikr = state.adhkar[state.selectedIdx!];
    final target = dhikr.count;

    if (state.completed) {
      if (!state.silent) HapticFeedback.mediumImpact();
      emit(state.copyWith(count: 1, completed: false));
      return;
    }

    if (!state.silent) HapticFeedback.lightImpact();
    final nextCount = state.count + 1;
    emit(state.copyWith(count: nextCount));

    if (nextCount >= target) {
      _onCompletion(nextCount, dhikr.text);
    }
  }

  void _onCompletion(int finalCount, String text) {
    if (!state.silent) {
      HapticFeedback.heavyImpact();
      Future.delayed(
        const Duration(milliseconds: 180),
        () => HapticFeedback.heavyImpact(),
      );
    }

    final newSessions = List<TasbihSession>.from(state.sessions)
      ..add(
        TasbihSession(dhikrText: text, count: finalCount, time: DateTime.now()),
      );

    emit(
      state.copyWith(
        completed: true,
        todayTotal: state.todayTotal + finalCount,
        sessions: newSessions,
      ),
    );

    // Handle auto-transition logic
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!isClosed && state.selectedIdx != null && state.completed) {
        goNext();
      }
    });
  }

  void resetCount() {
    if (!state.silent) HapticFeedback.selectionClick();
    emit(state.copyWith(count: 0, completed: false));
  }

  void goNext() {
    if (state.adhkar.isEmpty) return;
    final current = state.selectedIdx ?? -1;
    final next = (current + 1) % state.adhkar.length;
    selectDhikr(next);
  }

  void goPrev() {
    if (state.adhkar.isEmpty) return;
    final current = state.selectedIdx ?? 0;
    final prev = (current - 1 + state.adhkar.length) % state.adhkar.length;
    selectDhikr(prev);
  }

  void toggleSilent() {
    emit(state.copyWith(silent: !state.silent));
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void updateCategory(String? category) {
    emit(state.copyWith(activeCat: category));
  }
}
