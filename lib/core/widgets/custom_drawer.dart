import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/logic/theme_cubit.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';
import 'package:rafeeq/core/widgets/location_picker_dialog.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 0.85.sw,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: context.locale.languageCode == 'ar'
              ? Radius.circular(30.r)
              : Radius.zero,
          bottomLeft: context.locale.languageCode == 'ar'
              ? Radius.circular(30.r)
              : Radius.zero,
          topRight: context.locale.languageCode == 'en'
              ? Radius.circular(30.r)
              : Radius.zero,
          bottomRight: context.locale.languageCode == 'en'
              ? Radius.circular(30.r)
              : Radius.zero,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: context.locale.languageCode == 'ar'
                ? Radius.circular(30.r)
                : Radius.zero,
            bottomLeft: context.locale.languageCode == 'ar'
                ? Radius.circular(30.r)
                : Radius.zero,
            topRight: context.locale.languageCode == 'en'
                ? Radius.circular(30.r)
                : Radius.zero,
            bottomRight: context.locale.languageCode == 'en'
                ? Radius.circular(30.r)
                : Radius.zero,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                children: [
                  _buildSectionTitle(context, "drawer.language".tr()),
                  _buildLanguageToggle(context),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(context, "drawer.theme".tr()),
                  _buildThemeToggle(context),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(context, "home.select_location".tr()),
                  _buildLocationButton(context),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 30.h),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha:0.05),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.r),
          bottomRight: Radius.circular(40.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.primary.withValues(alpha:0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.mosque,
              color: context.colorScheme.onPrimary,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "drawer.title".tr(),
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "drawer.about".tr(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: context.textTheme.labelLarge?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            context,
            title: "drawer.arabic".tr(),
            isSelected: isArabic,
            onTap: () {
              if (!isArabic) {
                HapticFeedback.lightImpact();
                context.setLocale(const Locale('ar'));
              }
            },
          ),
          _buildToggleButton(
            context,
            title: "drawer.english".tr(),
            isSelected: !isArabic,
            onTap: () {
              if (isArabic) {
                HapticFeedback.lightImpact();
                context.setLocale(const Locale('en'));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        bool isDark = themeMode == ThemeMode.dark;
        if (themeMode == ThemeMode.system) {
          isDark = Theme.of(context).brightness == Brightness.dark;
        }
        return Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              _buildToggleButton(
                context,
                title: "drawer.light".tr(),
                isSelected: !isDark,
                icon: Icons.light_mode,
                onTap: () {
                  if (isDark) {
                    HapticFeedback.lightImpact();
                    context.read<ThemeCubit>().setTheme(ThemeMode.light);
                  }
                },
              ),
              _buildToggleButton(
                context,
                title: "drawer.dark".tr(),
                isSelected: isDark,
                icon: Icons.dark_mode,
                onTap: () {
                  if (!isDark) {
                    HapticFeedback.lightImpact();
                    context.read<ThemeCubit>().setTheme(ThemeMode.dark);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colorScheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18.sp,
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
              ],
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        HapticFeedback.mediumImpact();
        // 1. Capture the Cubit before popping the drawer
        final prayerCubit = context.read<PrayerTimeCubit>();

        // 2. Open the Location Picker Dialog
        // We use the root navigator to ensure the dialog stays even if drawer closes
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const LocationPickerDialog(),
        );

        if (result != null) {
          // 3. Update the location using the captured cubit
          // This will trigger a state change that all listeners (like Home) will react to
          await prayerCubit.updateLocationManually(
            latitude: result['lat'] as double,
            longitude: result['lon'] as double,
            cityName: result['city'] as String,
            countryName: result['country'] as String,
          );

          if (context.mounted) {
            Navigator.pop(context); // Close drawer after successful update
          }
        }
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colorScheme.primary.withValues(alpha:0.2),
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: context.colorScheme.primary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                "drawer.location".tr(),
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h, top: 20.h),
      child: Text(
        "Version 1.0.0",
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant.withValues(alpha:0.5),
        ),
      ),
    );
  }
}
