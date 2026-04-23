import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';
import 'package:rafeeq/features/home/logic/prayer_time_state.dart';
import 'package:rafeeq/core/widgets/location_picker_dialog.dart';

class LocationHelper {
  static Future<void> showLocationOptions(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "home.select_location".tr(),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 24.h),
            _buildOption(
              context,
              title: "home.select_auto_gps".tr(),
              subtitle: "home.select_auto_gps_desc".tr(),
              icon: Icons.share_location_rounded,
              onTap: () async {
                final cubit = context.read<PrayerTimeCubit>();
                final isAlreadyLoaded = cubit.state is PrayerTimeLoaded;

                Navigator.pop(context);
                await cubit.loadPrayerTimes(isManual: true);

                if (isAlreadyLoaded) {
                  final state = cubit.state;
                  if (state is PrayerTimeLoaded) {
                    _showSuccessToast("home.location_already_set".tr());
                  }
                }
              },
            ),
            SizedBox(height: 12.h),
            _buildOption(
              context,
              title: "home.select_from_map".tr(),
              subtitle: "home.select_from_map_desc".tr(),
              icon: Icons.map_outlined,
              onTap: () async {
                final cubit = context.read<PrayerTimeCubit>();
                Navigator.pop(context);
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const LocationPickerDialog(),
                );

                if (result != null) {
                  await cubit.updateLocationManually(
                    latitude: result['lat'] as double,
                    longitude: result['lon'] as double,
                    cityName: result['city'] as String,
                    countryName: result['country'] as String,
                  );
                  _showSuccessToast("home.location_updated_successfully".tr());
                }
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  static Widget _buildOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  static void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
