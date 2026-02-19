part of 'layout_cubit.dart';

@immutable
class LayoutState {
  final int currentIndex;

  const LayoutState({required this.currentIndex});

  LayoutState copyWith({int? currentIndex}) {
    return LayoutState(currentIndex: currentIndex ?? this.currentIndex);
  }
}
