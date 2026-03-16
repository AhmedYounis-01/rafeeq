import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rafeeq/core/widgets/main_layout.dart';
import 'package:rafeeq/features/home/ui/home_screen.dart';
import 'package:rafeeq/features/qibla/ui/qibla_screen.dart';
import 'package:rafeeq/features/quran/ui/quran_screen.dart';
import 'package:rafeeq/features/tasbih/ui/tasbih_screen.dart';
import '../logic/cubit/layout_cubit.dart';

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});

  static final List<Widget> _screens = [
    HomeScreen(key: PageStorageKey('home')),
    QuranScreen(key: PageStorageKey('quran')),
    QiblaScreen(key: PageStorageKey('qibla')),
    TasbihScreen(key: PageStorageKey('tasbih')),
  ];

  @override
  Widget build(BuildContext context) {
    String currentRoute = '/home';
    try {
      currentRoute = GoRouterState.of(context).uri.toString();
    } catch (_) {}

    return BlocProvider(
      create: (_) => LayoutCubit()..setIndexFromRoute(currentRoute),
      child: BlocBuilder<LayoutCubit, LayoutState>(
        builder: (context, state) {
          return MainLayout(
            child: IndexedStack(
              index: state.currentIndex,
              children: _screens,
            ),
          );
        },
      ),
    );
  }
}