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

  @override
  Widget build(BuildContext context) {
    // Try to read current route from GoRouter if available, otherwise default to home
    String currentRoute = '/home';
    try {
      currentRoute = GoRouterState.of(context).uri.toString();
    } catch (_) {
      // no router in context; keep default
    }

    return BlocProvider(
      create: (_) => LayoutCubit()..setIndexFromRoute(currentRoute),
      child: BlocBuilder<LayoutCubit, LayoutState>(
        builder: (context, state) {
          return MainLayout(child: _buildChildForIndex(state.currentIndex));
        },
      ),
    );
  }

  Widget _buildChildForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const QiblaScreen();
      case 2:
        return const QuranScreen();
      case 3:
        return const TasbihScreen();
      default:
        return const HomeScreen();
    }
  }
}
