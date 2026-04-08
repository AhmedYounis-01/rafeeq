import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/core/constants/app_constants.dart';
import 'package:rafeeq/core/themes/app_theme.dart';
import 'package:rafeeq/core/routing/app_router.dart';
import 'package:rafeeq/core/themes/logic/theme_cubit.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';

import 'package:rafeeq/features/splash/ui/screens/splash_screen.dart';

class Rafeeq extends StatefulWidget {
  const Rafeeq({super.key});

  @override
  State<Rafeeq> createState() => _RafeeqState();
}

class _RafeeqState extends State<Rafeeq> {
  final ValueNotifier<bool> _showSplash = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _showSplash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => PrayerTimeCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return ValueListenableBuilder<bool>(
                valueListenable: _showSplash,
                builder: (context, showSplash, child) {
                  return MaterialApp.router(
                    title: AppConstants.appName,
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeMode,
                    routerConfig: AppRouter.router,
                    builder: (context, widget) {
                      return MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: const TextScaler.linear(1.0)),
                        child: Stack(
                          children: [
                            widget!,
                            if (showSplash)
                              SplashOverlay(
                                onComplete: () {
                                  _showSplash.value = false;
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
