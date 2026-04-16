import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:rafeeq/core/cache/storage_manager.dart';

part 'seerah_state.dart';

class SeerahCubit extends Cubit<SeerahState> {
  static const _lastPageKey = 'seerah_last_page';

  PdfTextSearchResult? _searchResult;

  SeerahCubit() : super(const SeerahState());

  int get savedPage =>
      StorageManager.instance.getData<int>(key: _lastPageKey) ?? 1;

  void onDocumentLoaded() {
    emit(state.copyWith(isLoaded: true));
  }

  void saveCurrentPage(int pageNumber) {
    StorageManager.instance.saveData(key: _lastPageKey, value: pageNumber);
  }

  void toggleSearch() {
    if (state.isSearching) {
      _searchResult?.clear();
      emit(
        state.copyWith(
          isSearching: false,
          hasSearchResult: false,
          currentSearchInstance: 0,
          totalSearchInstances: 0,
        ),
      );
    } else {
      emit(state.copyWith(isSearching: true));
    }
  }

  void performSearch(String query, PdfViewerController pdfController) {
    if (query.trim().isEmpty) return;

    _searchResult?.clear();
    final result = pdfController.searchText(query);
    _searchResult = result;

    _subscribeToSearchResult(result);
  }

  void _subscribeToSearchResult(PdfTextSearchResult result) {
    result.addListener(() {
      if (!isClosed) {
        emit(
          state.copyWith(
            hasSearchResult: result.hasResult,
            currentSearchInstance: result.currentInstanceIndex,
            totalSearchInstances: result.totalInstanceCount,
          ),
        );
      }
    });
  }

  void nextSearchInstance() {
    _searchResult?.nextInstance();
  }

  void previousSearchInstance() {
    _searchResult?.previousInstance();
  }

  @override
  Future<void> close() {
    _searchResult?.clear();
    return super.close();
  }
}
