import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rafeeq/core/cache/storage_manager.dart';
import 'package:rafeeq/features/quick_parts/data/models/seerah_item.dart';

part 'seerah_state.dart';

class SeerahCubit extends Cubit<SeerahState> {
  static const _lastTopicKey = 'seerah_last_topic_index';
  static const _fontSizeKey = 'seerah_font_size';

  Timer? _saveDebounce;

  SeerahCubit() : super(const SeerahState()) {
    loadSeerah();
  }

  Future<void> loadSeerah() async {
    emit(state.copyWith(status: SeerahStatus.loading));
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/seerah.json');
      final dynamic decoded = json.decode(jsonString);

      if (decoded is! List) {
        throw const FormatException('Invalid JSON format for Seerah data');
      }

      final items = decoded
          .map((e) => SeerahItem.fromJson(e as Map<String, dynamic>))
          .toList();

      final savedIndex =
          StorageManager.instance.getData<int>(key: _lastTopicKey) ?? 0;
      final savedFontSize =
          StorageManager.instance.getData<double>(key: _fontSizeKey) ?? 18.0;

      final initialIndex = (savedIndex >= 0 && savedIndex < items.length)
          ? savedIndex
          : 0;

      emit(
        state.copyWith(
          status: SeerahStatus.loaded,
          items: items,
          currentIndex: initialIndex,
          fontSize: savedFontSize.clamp(14.0, 32.0),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SeerahStatus.error,
          errorMessage: 'فشل تحميل بيانات السيرة النبوية: ${e.toString()}',
        ),
      );
    }
  }

  void goToTopic(int index) {
    if (state.items.isEmpty) return;
    final targetIndex = index.clamp(0, state.items.length - 1);
    emit(state.copyWith(currentIndex: targetIndex));

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 600), () {
      StorageManager.instance.saveData(
        key: _lastTopicKey,
        value: targetIndex,
      );
    });
  }

  void nextTopic() {
    if (state.currentIndex < state.items.length - 1) {
      goToTopic(state.currentIndex + 1);
    }
  }

  void previousTopic() {
    if (state.currentIndex > 0) {
      goToTopic(state.currentIndex - 1);
    }
  }

  void changeFontSize(double delta) {
    final newSize = (state.fontSize + delta).clamp(14.0, 32.0);
    emit(state.copyWith(fontSize: newSize));
    StorageManager.instance.saveData(key: _fontSizeKey, value: newSize);
  }

  void resetFontSize() {
    emit(state.copyWith(fontSize: 18.0));
    StorageManager.instance.saveData(key: _fontSizeKey, value: 18.0);
  }

  void toggleSearch() {
    final newSearching = !state.isSearching;
    emit(
      state.copyWith(
        isSearching: newSearching,
        searchQuery: newSearching ? state.searchQuery : '',
      ),
    );
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void selectCategory(String? category) {
    if (category == state.selectedCategory) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: category));
    }
  }

  @override
  Future<void> close() {
    if (_saveDebounce?.isActive ?? false) {
      StorageManager.instance.saveData(
        key: _lastTopicKey,
        value: state.currentIndex,
      );
    }
    _saveDebounce?.cancel();
    return super.close();
  }
}
