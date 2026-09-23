import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'settings_config.dart';
import 'sliding_toggle.dart';

class LanguageToggle extends StatelessWidget {
  final SettingsConfig config;

  const LanguageToggle({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return SlidingToggle(
      selectedIndex: isArabic ? 0 : 1,
      height: config.toggleHeight,
      options: [
        ToggleOption(label: "drawer.arabic".tr()),
        ToggleOption(label: "drawer.english".tr()),
      ],
      onChanged: (index) {
        if (index == 0) {
          context.setLocale(const Locale('ar'));
        } else {
          context.setLocale(const Locale('en'));
        }
      },
    );
  }
}
