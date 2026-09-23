import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'settings_config.dart';
import 'settings_card.dart';
import 'settings_divider.dart';
import 'legal_tile.dart';

class LegalSection extends StatelessWidget {
  final SettingsConfig config;

  const LegalSection({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      children: [
        LegalTile(
          config: config,
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF4A90D9),
          title: "settings.location_usage_title".tr(),
          description: "settings.location_usage_desc".tr(),
          detailedDescription: "settings.location_usage_detailed".tr(),
        ),
        SettingsDivider(config: config),
        LegalTile(
          config: config,
          icon: Icons.privacy_tip_outlined,
          iconColor: const Color(0xFF27AE60),
          title: "settings.privacy_policy_title".tr(),
          description: "settings.privacy_policy_desc".tr(),
          detailedDescription: "settings.privacy_policy_detailed".tr(),
        ),
      ],
    );
  }
}
