import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/core/constants/app_constants.dart';
import 'package:rafeeq/core/themes/app_theme.dart';
import 'package:rafeeq/core/routing/app_router.dart';
import 'package:rafeeq/core/themes/logic/theme_cubit.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';

class Rafeeq extends StatelessWidget {
  const Rafeeq({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => PrayerTimeCubit()..loadPrayerTimes()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ScreenUtilInit(
            designSize: constraints.maxWidth >= 600
                ? const Size(768, 1024)
                : const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
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
                      final preview = DevicePreview.appBuilder(context, widget);
                      return MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: const TextScaler.linear(1.0)),
                        child: preview,
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
