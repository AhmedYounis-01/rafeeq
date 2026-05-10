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
    final config = _SettingsConfig(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==================== Sliver App Bar ====================
          SliverAppBar(
            expandedHeight: config.appBarHeight,
            floating: false,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colorScheme.onSurface,
                  size: 20.sp,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsetsDirectional.only(
                start: 56.w,
                bottom: 16.h,
              ),
              centerTitle: false,
              title: Text(
                "settings.title".tr(),
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              background: _AppBarBackground(),
            ),
          ),

          // ==================== Settings Content ====================
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: config.sidePadding,
              vertical: 8.h,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Appearance Group ──
                _SectionHeader(title: "drawer.appearance".tr()),
                SizedBox(height: 10.h),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      config: config,
                      icon: Icons.language_rounded,
                      iconColor: const Color(0xFF4A90D9),
                      title: "drawer.language".tr(),
                      child: _buildLanguageToggle(context, config),
                    ),
                    _Divider(config: config),
                    _SettingsTile(
                      config: config,
                      icon: Icons.palette_outlined,
                      iconColor: const Color(0xFF9B59B6),
                      title: "drawer.theme".tr(),
                      child: _buildThemeToggle(context, config),
                    ),
                  ],
                ),
                SizedBox(height: config.sectionSpacing),

                // ── Prayer Settings Group ──
                _SectionHeader(title: "drawer.prayer_settings".tr()),
                SizedBox(height: 10.h),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      config: config,
                      icon: Icons.volume_up_rounded,
                      iconColor: const Color(0xFF27AE60),
                      title: "drawer.adhan_sound".tr(),
                      child: _buildAdhanToggle(context, config),
                    ),
                    _Divider(config: config),
                    _buildLocationTile(context, config),
                  ],
                ),
                SizedBox(height: config.sectionSpacing),

                // ── Legal & Privacy ──
                _SectionHeader(title: "drawer.legal_privacy".tr()),
                SizedBox(height: 10.h),
                _buildLegalSection(context, config),
                SizedBox(height: config.sectionSpacing + 8.h),

                // ── Footer ──
                _buildFooter(context),
                SizedBox(height: 32.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== Language Toggle ======================
  Widget _buildLanguageToggle(BuildContext context, _SettingsConfig config) {
    final isArabic = context.locale.languageCode == 'ar';
    return _SlidingToggle(
      selectedIndex: isArabic ? 0 : 1,
      height: config.toggleHeight,
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
  Widget _buildThemeToggle(BuildContext context, _SettingsConfig config) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        bool isDark = themeMode == ThemeMode.dark;
        if (themeMode == ThemeMode.system) {
          isDark = Theme.of(context).brightness == Brightness.dark;
        }
        return _SlidingToggle(
          selectedIndex: isDark ? 1 : 0,
          height: config.toggleHeight,
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
  Widget _buildAdhanToggle(BuildContext context, _SettingsConfig config) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) =>
          prev.isAdhanSoundEnabled != curr.isAdhanSoundEnabled,
      builder: (context, state) {
        return _SlidingToggle(
          selectedIndex: state.isAdhanSoundEnabled ? 0 : 1,
          height: config.toggleHeight,
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

  // ====================== Location Tile ======================
  Widget _buildLocationTile(BuildContext context, _SettingsConfig config) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await LocationHelper.showLocationOptions(context);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: config.iconContainerSize,
              height: config.iconContainerSize,
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: const Color(0xFFE74C3C),
                size: config.iconSize,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                "home.select_location".tr(),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  // ====================== Legal Section ======================
  Widget _buildLegalSection(BuildContext context, _SettingsConfig config) {
    return _SettingsCard(
      children: [
        _LegalTile(
          config: config,
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF4A90D9),
          title: "settings.location_usage_title".tr(),
          description: "settings.location_usage_desc".tr(),
          detailedDescription: "settings.location_usage_detailed".tr(),
        ),
        _Divider(config: config),
        _LegalTile(
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

  // ====================== Footer ======================
  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          "settings.version".tr(),
          style: context.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "settings.copyright".tr(),
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// ====================== App Bar Background ======================
class _AppBarBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = AppColors.getPrimary(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary.withValues(alpha: 0.08),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
    );
  }
}

// ====================== Section Header ======================
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 4.w),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ====================== Settings Card ======================
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

// ====================== Settings Tile ======================
class _SettingsTile extends StatelessWidget {
  final _SettingsConfig config;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SettingsTile({
    required this.config,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: config.tileInsidePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: config.iconContainerSize,
                height: config.iconContainerSize,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: config.iconSize),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

// ====================== Legal Tile ======================
class _LegalTile extends StatelessWidget {
  final _SettingsConfig config;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String detailedDescription;

  const _LegalTile({
    required this.config,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.detailedDescription,
  });

  void _showDetailedLegal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = AppColors.getPrimary(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: EdgeInsets.only(top: 14.h, bottom: 8.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: config.iconContainerSize * 1.1,
                      height: config.iconContainerSize * 1.1,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: config.iconSize,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        title,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                height: 1,
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: Text(
                    detailedDescription,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.9,
                    ),
                  ),
                ),
              ),
              // Close Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 54.h,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showDetailedLegal(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: config.tileInsidePadding,
        ),
        child: Row(
          children: [
            Container(
              width: config.iconContainerSize,
              height: config.iconContainerSize,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: config.iconSize),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    description,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== Divider ======================
class _Divider extends StatelessWidget {
  final _SettingsConfig config;
  const _Divider({required this.config});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: (config.iconContainerSize + 32.w),
      endIndent: 16.w,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.2),
    );
  }
}

// ====================== Toggle Option Model ======================
class _ToggleOption {
  final String label;
  final IconData? icon;
  const _ToggleOption({required this.label, this.icon});
}

// ====================== Sliding Toggle ======================
class _SlidingToggle extends StatelessWidget {
  final int selectedIndex;
  final List<_ToggleOption> options;
  final ValueChanged<int> onChanged;
  final double height;

  const _SlidingToggle({
    required this.selectedIndex,
    required this.options,
    required this.onChanged,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = AppColors.getPrimary(context);

    return Container(
      height: height,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / options.length;

          return Stack(
            children: [
              // Sliding Pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                alignment: AlignmentDirectional(
                  -1 + (selectedIndex * (2 / (options.length - 1))),
                  0,
                ),
                child: Container(
                  width: itemWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(11.r),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Options Row
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
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: context.textTheme.labelMedium!.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (option.icon != null) ...[
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    option.icon,
                                    key: ValueKey('${option.icon}_$isSelected'),
                                    size: 15.sp,
                                    color: isSelected
                                        ? Colors.white
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                              ],
                              Text(option.label),
                            ],
                          ),
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

// ─── Responsive Config ────────────────────────────────────────────────────────
class _SettingsConfig {
  final BuildContext context;
  final double shortestSide;

  _SettingsConfig(this.context)
    : shortestSide = MediaQuery.of(context).size.shortestSide;

  bool get isTablet => shortestSide >= 600;

  double get appBarHeight => isTablet ? 180.h : 140.h;
  double get sidePadding => isTablet ? 40.w : 20.w;
  double get sectionSpacing => isTablet ? 40.h : 28.h;
  double get tileInsidePadding => isTablet ? 20.h : 14.h;
  double get iconContainerSize => isTablet ? 50.w : 38.w;
  double get iconSize => isTablet ? 24.sp : 20.sp;
  double get toggleHeight => isTablet ? 56.h : 46.h;
}
