import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/features/settings/logic/cubit/settings_cubit.dart';
import 'settings_config.dart';
import 'sliding_toggle.dart';

class AdhanToggle extends StatelessWidget {
  final SettingsConfig config;

  const AdhanToggle({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) =>
          prev.isAdhanSoundEnabled != curr.isAdhanSoundEnabled,
      builder: (context, state) {
        return SlidingToggle(
          selectedIndex: state.isAdhanSoundEnabled ? 0 : 1,
          height: config.toggleHeight,
          options: [
            ToggleOption(
              label: "drawer.adhan_sound_enabled".tr(),
              icon: Icons.volume_up_rounded,
            ),
            ToggleOption(
              label: "drawer.adhan_sound_disabled".tr(),
              icon: Icons.volume_off_rounded,
            ),
          ],
          onChanged: (index) {
            context.read<SettingsCubit>().toggleAdhanSound(index == 0);
          },
        );
      },
    );
  }
}
