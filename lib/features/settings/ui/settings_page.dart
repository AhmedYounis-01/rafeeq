import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'widgets/settings_config.dart';
import 'widgets/settings_app_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/settings_card.dart';
import 'widgets/settings_tile.dart';
import 'widgets/settings_divider.dart';
import 'widgets/language_toggle.dart';
import 'widgets/theme_toggle.dart';
import 'widgets/adhan_toggle.dart';
import 'widgets/location_tile.dart';
import 'widgets/legal_section.dart';
import 'widgets/settings_footer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = SettingsConfig(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==================== Sliver App Bar ====================
          SettingsAppBar(config: config),

          // ==================== Settings Content ====================
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: config.sidePadding,
              vertical: 8.h,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Appearance Group ──
                SectionHeader(title: "drawer.appearance".tr()),
                SizedBox(height: 10.h),
                SettingsCard(
                  children: [
                    SettingsTile(
                      config: config,
                      icon: Icons.language_rounded,
                      iconColor: const Color(0xFF4A90D9),
                      title: "drawer.language".tr(),
                      child: LanguageToggle(config: config),
                    ),
                    SettingsDivider(config: config),
                    SettingsTile(
                      config: config,
                      icon: Icons.palette_outlined,
                      iconColor: const Color(0xFF9B59B6),
                      title: "drawer.theme".tr(),
                      child: ThemeToggle(config: config),
                    ),
                  ],
                ),
                SizedBox(height: config.sectionSpacing),

                // ── Prayer Settings Group ──
                SectionHeader(title: "drawer.prayer_settings".tr()),
                SizedBox(height: 10.h),
                SettingsCard(
                  children: [
                    SettingsTile(
                      config: config,
                      icon: Icons.volume_up_rounded,
                      iconColor: const Color(0xFF27AE60),
                      title: "drawer.adhan_sound".tr(),
                      child: AdhanToggle(config: config),
                    ),
                    SettingsDivider(config: config),
                    LocationTile(config: config),
                  ],
                ),
                SizedBox(height: config.sectionSpacing),

                // ── Legal & Privacy ──
                SectionHeader(title: "drawer.legal_privacy".tr()),
                SizedBox(height: 10.h),
                LegalSection(config: config),
                SizedBox(height: config.sectionSpacing + 8.h),

                // ── Footer ──
                const SettingsFooter(),
                SizedBox(height: 32.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
