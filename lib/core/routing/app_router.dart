import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rafeeq/features/onboarding/ui/onboarding_screen.dart';
import 'package:rafeeq/features/quick_parts/ui/screens/azkar_categories_screen.dart';
import 'package:rafeeq/features/quick_parts/ui/screens/asma_allah_screen.dart';
import 'package:rafeeq/features/quick_parts/ui/screens/dhikr_list_screen.dart';
import 'package:rafeeq/features/quick_parts/ui/screens/seerah_screen.dart';
import 'package:rafeeq/features/quick_parts/data/quick_parts_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/widgets/main_layout.dart';
import 'package:rafeeq/features/home/ui/home_screen.dart';
import 'package:rafeeq/features/qibla/ui/qibla_screen.dart';
import 'package:rafeeq/features/quran/ui/quran_screen.dart';
import 'package:rafeeq/features/tasbih/ui/tasbih_screen.dart';
import 'package:rafeeq/core/cache/storage_manager.dart';
import 'package:rafeeq/features/splash/ui/screens/splash_screen.dart';
import 'package:rafeeq/features/settings/ui/settings_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String onboarding = '/onboarding';

  // Navigation screens
  static const String home = '/home';
  static const String qibla = '/qibla';
  static const String quran = '/quran';
  static const String tasbih = '/tasbih';
  static const String settings = '/settings';

  // Quick parts screens
  static const String azkar = '/azkar';
  static const String ruqiah = '/ruqiah';
  static const String dua = '/dua';
  static const String seerah = '/seerah';

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: "/",
    redirect: (context, state) {
      final hasSeenOnboarding = StorageManager.instance.hasSeenOnboarding();
      final isGoingToOnboarding = state.uri.toString() == onboarding;
      final isGoingToSplash = state.uri.toString() == "/";

      if (!hasSeenOnboarding && !isGoingToOnboarding && !isGoingToSplash) {
        return onboarding;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: qibla,
            name: 'qibla',
            builder: (context, state) => const QiblaScreen(),
          ),
          GoRoute(
            path: quran,
            name: 'quran',
            builder: (context, state) => const QuranScreen(),
          ),
          GoRoute(
            path: tasbih,
            name: 'tasbih',
            builder: (context, state) => const TasbihScreen(),
          ),
        ],
      ),

      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: azkar,
        name: 'azkar',
        builder: (context, state) => const AzkarCategoriesScreen(),
      ),
      GoRoute(
        path: ruqiah,
        name: 'ruqiah',
        builder: (context, state) =>
            const DhikrListScreen(type: QuickPartType.ruqiah),
      ),
      GoRoute(
        path: dua,
        name: 'dua',
        builder: (context, state) => const AsmaAllahScreen(),
      ),
      GoRoute(
        path: seerah,
        name: 'seerah',
        builder: (context, state) => const SeerahScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'errors.pageNotFound'.tr(namedArgs: {'path': state.uri.toString()}),
        ),
      ),
    ),
  );
}
