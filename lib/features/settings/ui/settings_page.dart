import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/logic/theme_cubit.dart';
import 'package:rafeeq/core/helpers/location_helper.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/settings/logic/cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==================== Sliver App Bar ====================
          SliverAppBar(
            expandedHeight: 120.h,
            floating: false,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSurface,
                size: 20.sp,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "settings.title".tr(),
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              titlePadding: EdgeInsetsDirectional.only(
                start: 56.w,
                bottom: 16.h,
              ),
              centerTitle: false,
            ),
          ),

          // ==================== Settings Content ====================
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSection(
                  context,
                  title: "drawer.language".tr(),
                  icon: Icons.language_rounded,
                  child: _buildLanguageToggle(context),
                ),
                SizedBox(height: 24.h),

                _buildSection(
                  context,
                  title: "drawer.theme".tr(),
                  icon: Icons.palette_outlined,
                  child: _buildThemeToggle(context),
                ),
                SizedBox(height: 24.h),

                _buildSection(
                  context,
                  title: "drawer.adhan_sound".tr(),
                  icon: Icons.volume_up_rounded,
                  child: _buildAdhanToggle(context),
                ),
                SizedBox(height: 24.h),

                _buildSection(
                  context,
                  title: "home.select_location".tr(),
                  icon: Icons.location_on_rounded,
                  child: _buildLocationButton(context),
                ),
                SizedBox(height: 32.h),

                // ==================== Legal & Data Usage Sections ====================
                _buildLegalSection(context),
                SizedBox(height: 40.h),

                // ==================== Footer ====================
                _buildFooter(context),
                SizedBox(height: 32.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== Section Title ======================
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 12.h),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: AppColors.getPrimary(context)),
              SizedBox(width: 10.w),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  // ====================== Language Toggle ======================
  Widget _buildLanguageToggle(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return _SlidingToggle(
      selectedIndex: isArabic ? 0 : 1,
      options: [
        _ToggleOption(label: "drawer.arabic".tr()),
        _ToggleOption(label: "drawer.english".tr()),
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

  // ====================== Theme Toggle ======================
  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        bool isDark = themeMode == ThemeMode.dark;
        if (themeMode == ThemeMode.system) {
          isDark = Theme.of(context).brightness == Brightness.dark;
        }

        return _SlidingToggle(
          selectedIndex: isDark ? 1 : 0,
          options: [
            _ToggleOption(
              label: "drawer.light".tr(),
              icon: Icons.wb_sunny_rounded,
            ),
            _ToggleOption(
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

  // ====================== Adhan Toggle ======================
  Widget _buildAdhanToggle(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.isAdhanSoundEnabled != current.isAdhanSoundEnabled,
      builder: (context, state) {
        return _SlidingToggle(
          selectedIndex: state.isAdhanSoundEnabled ? 0 : 1,
          options: [
            _ToggleOption(
              label: "drawer.adhan_sound_enabled".tr(),
              icon: Icons.volume_up_rounded,
            ),
            _ToggleOption(
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

  // ====================== Location Button ======================
  Widget _buildLocationButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await LocationHelper.showLocationOptions(context);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "drawer.location".tr(),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  // ====================== Legal Section ======================
  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegalCard(
          context,
          title: "settings.location_usage_title".tr(),
          description: "settings.location_usage_desc".tr(),
          detailedDescription: "settings.location_usage_detailed".tr(),
          icon: Icons.info_outline_rounded,
        ),
        SizedBox(height: 16.h),
        _buildLegalCard(
          context,
          title: "settings.privacy_policy_title".tr(),
          description: "settings.privacy_policy_desc".tr(),
          detailedDescription: "settings.privacy_policy_detailed".tr(),
          icon: Icons.privacy_tip_outlined,
        ),
      ],
    );
  }

  Widget _buildLegalCard(
    BuildContext context, {
    required String title,
    required String description,
    required String detailedDescription,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = AppColors.getPrimary(context);

    return InkWell(
      onTap: () => _showDetailedLegal(context, title, detailedDescription),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primary, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: primary,
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 14.sp,
                        color: primary.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedLegal(
    BuildContext context,
    String title,
    String detailedContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = AppColors.getPrimary(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: primary,
              ),
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  detailedContent,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.8,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "settings.close".tr(),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  // ====================== Footer ======================
  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
        SizedBox(height: 16.h),
        Text(
          "settings.version".tr(),
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "settings.copyright".tr(),
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ====================== Sliding Toggle Components ======================

class _ToggleOption {
  final String label;
  final IconData? icon;
  _ToggleOption({required this.label, this.icon});
}

class _SlidingToggle extends StatelessWidget {
  final int selectedIndex;
  final List<_ToggleOption> options;
  final ValueChanged<int> onChanged;

  const _SlidingToggle({
    required this.selectedIndex,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = AppColors.getPrimary(context);

    return Container(
      height: 52.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / options.length;

          return Stack(
            children: [
              // Sliding Pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                alignment: AlignmentDirectional(
                  -1 + (selectedIndex * (2 / (options.length - 1))),
                  0,
                ),
                child: Container(
                  width: itemWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Options
              Row(
                children: List.generate(options.length, (index) {
                  final isSelected = selectedIndex == index;
                  final option = options[index];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          HapticFeedback.selectionClick();
                          onChanged(index);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (option.icon != null) ...[
                              Icon(
                                option.icon,
                                size: 16.sp,
                                color: isSelected
                                    ? Colors.white
                                    : colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 8.w),
                            ],
                            Text(
                              option.label,
                              style: context.textTheme.labelMedium!.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
