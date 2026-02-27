import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rafeeq/core/routing/app_router.dart';

part 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(const LayoutState(currentIndex: 0));

  /// Set current index (e.g., from a bottom nav tap)
  void setIndex(int index) => emit(LayoutState(currentIndex: index));

  /// Derive index from a route string (keeps logic in one place)
  void setIndexFromRoute(String route) {
    int idx = 0;
    if (route.startsWith(AppRouter.home)) {
      idx = 0;
    } else if (route.startsWith(AppRouter.quran )) {
      idx = 1;
    } else if (route.startsWith(AppRouter.qibla)) {
      idx = 2;
    } else if (route.startsWith(AppRouter.tasbih)) {
      idx = 3;
    }

    emit(LayoutState(currentIndex: idx));
  }
}
