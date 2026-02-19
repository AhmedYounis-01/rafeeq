import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/constants/app_constants.dart';
import 'package:rafeeq/core/themes/app_theme.dart';
import 'package:rafeeq/core/routing/app_router.dart';

class Rafeeq extends StatelessWidget {
  const Rafeeq({super.key});

  @override
  Widget build(BuildContext context) {
    // Default to system theme. Replace with SettingsCubit/Bloc when available.
    final ThemeMode themeMode = ThemeMode.system;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // Localization (requires EasyLocalization wrapper in main.dart)
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,

          // Routing
          routerConfig: AppRouter.router,

          // Builder for responsive design and text scaling
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget!,
            );
          },
        );
      },
    );
  }
}
