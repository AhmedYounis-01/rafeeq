import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/themes/logic/theme_cubit.dart';
import 'settings_config.dart';
import 'sliding_toggle.dart';

class ThemeToggle extends StatelessWidget {
  final SettingsConfig config;

  const ThemeToggle({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        bool isDark = themeMode == ThemeMode.dark;
        if (themeMode == ThemeMode.system) {
          isDark = Theme.of(context).brightness == Brightness.dark;
        }
        return SlidingToggle(
          selectedIndex: isDark ? 1 : 0,
          height: config.toggleHeight,
          options: [
            ToggleOption(
              label: "drawer.light".tr(),
              icon: Icons.wb_sunny_rounded,
            ),
            ToggleOption(
              label: "drawer.dark".tr(),
              icon: Icons.nightlight_round,
            ),
          ],
          onChanged: (index) {
            context.read<ThemeCubit>().setTheme(
              index == 0 ? ThemeMode.light : ThemeMode.dark,
            );
          },
        );
      },
    );
  }
}
