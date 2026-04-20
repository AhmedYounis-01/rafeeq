import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/logic/theme_cubit.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';
import 'package:rafeeq/core/widgets/location_picker_dialog.dart';
import 'package:rafeeq/core/widgets/shared_navigation.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = context.locale.languageCode == 'ar';

    return Drawer(
      width: 0.88.sw,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.horizontal(
          start: Radius.circular(isArabic ? 0 : 32.r),
          end: Radius.circular(isArabic ? 32.r : 0),
        ).resolve(Directionality.of(context)),
      ),
      child: Column(
        children: [
          // ==================== Fixed Header ====================
          _buildHeader(context),

          // ==================== Scrollable Content (Language + Theme + Location + Footer) ====================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    title: "drawer.language".tr(),
                    icon: Icons.language_rounded,
                    child: _buildLanguageToggle(context),
                  ),
                  SizedBox(height: 32.h),

                  _buildSection(
                    context,
                    title: "drawer.theme".tr(),
                    icon: Icons.palette_outlined,
                    child: _buildThemeToggle(context),
                  ),
                  SizedBox(height: 32.h),

                  _buildSection(
                    context,
                    title: "home.select_location".tr(),
                    icon: Icons.location_on_rounded,
                    child: _buildLocationButton(context),
                  ),

                  // مساحة كبيرة قبل الفوتر عشان يبقى في الأسفل بشكل طبيعي
                  SizedBox(height: 80.h),

                  // ==================== Footer (الآن داخل الـ Scroll) ====================
                  _buildFooter(context),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== Fixed Header ======================
  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(28.w, 65.h, 28.w, 40.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withValues(alpha: 0.07),
            colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.08),
            ),
            child: Image.asset(
              'assets/images/rafeeq_logo.png',
              width: 100.r,
              height: 100.r,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                Icons.mosque_rounded,
                size: 72.r,
                color: colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "drawer.about".tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
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
        Row(
          children: [
            Icon(icon, size: 22.sp, color: colorScheme.primary),
            SizedBox(width: 12.w),
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        child,
      ],
    );
  }

  // ====================== Language Toggle ======================
  Widget _buildLanguageToggle(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 64.h,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              context,
              "English",
              !isArabic,
              () => _changeLocale(context, const Locale('en')),
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              context,
              "العربية",
              isArabic,
              () => _changeLocale(context, const Locale('ar')),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== Theme Toggle ======================
  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final colorScheme = Theme.of(context).colorScheme;
        bool isDark = themeMode == ThemeMode.dark;
        if (themeMode == ThemeMode.system) {
          isDark = Theme.of(context).brightness == Brightness.dark;
        }

        return Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildToggleOption(
                  context,
                  "drawer.light".tr(),
                  !isDark,
                  () {
                    if (isDark) {
                      context.read<ThemeCubit>().setTheme(ThemeMode.light);
                    }
                  },
                  Icons.wb_sunny_rounded,
                ),
              ),
              Expanded(
                child: _buildToggleOption(
                  context,
                  "drawer.dark".tr(),
                  isDark,
                  () {
                    if (!isDark) {
                      context.read<ThemeCubit>().setTheme(ThemeMode.dark);
                    }
                  },
                  Icons.nightlight_round,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ====================== Reusable Toggle Option ======================
  Widget _buildToggleOption(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap, [
    IconData? icon,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      splashColor: colorScheme.primary.withValues(alpha: 0.1),
      highlightColor: colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        margin: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 21.sp,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 10.w),
              ],
              Text(
                label,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontSize: 15.5.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== Location Button ======================
  Widget _buildLocationButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const LocationPickerDialog(),
        );

        if (result != null && context.mounted) {
          await context.read<PrayerTimeCubit>().updateLocationManually(
            latitude: result['lat'] as double,
            longitude: result['lon'] as double,
            cityName: result['city'] as String,
            countryName: result['country'] as String,
          );

          final controller = AdvancedDrawerControllerProvider.of(context);
          if (controller != null) controller.hideDrawer();
        }
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "drawer.location".tr(),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _changeLocale(BuildContext context, Locale newLocale) {
    final controller = AdvancedDrawerControllerProvider.of(context);
    if (controller != null) controller.hideDrawer();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (context.mounted) context.setLocale(newLocale);
    });
  }

  // ====================== Footer ======================
  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
        SizedBox(height: 20.h),
        Text(
          "Version 1.0.0",
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Rafeeq © 2026",
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
