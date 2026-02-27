import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';
import 'package:rafeeq/features/home/logic/prayer_time_state.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu Button to open Drawer
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Scaffold.of(context).openDrawer();
              },
              style: IconButton.styleFrom(
                minimumSize: Size(44.w, 44.h),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                backgroundColor: context.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
              ),
              icon: Icon(
                Icons.menu_rounded,
                color: context.colorScheme.primary,
                size: 28.sp,
              ),
            ),
          ),

          BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
            builder: (context, state) {
              String locationText = "common.loading".tr();
              if (state is PrayerTimeLoaded) {
                locationText = "${state.cityName} - ${state.countryName}";
              } else if (state is PrayerTimeLocationDenied) {
                locationText = "home.unknown_location".tr();
              }
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest.withValues(
                    alpha:0.3,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Text(
                      locationText,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.location_on,
                      color: context.colorScheme.primary,
                      size: 20.sp,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
