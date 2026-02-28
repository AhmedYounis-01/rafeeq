import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';
import 'package:rafeeq/features/home/logic/prayer_time_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:intl/intl.dart' as intl;
import 'package:adhan/adhan.dart';
import 'package:rafeeq/core/widgets/location_picker_dialog.dart';
import 'package:rafeeq/features/home/ui/widgets/prayer_time_item.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

class PrayerTime extends StatelessWidget {
  const PrayerTime({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildStateContent(context, state),
        );
      },
    );
  }

  Widget _buildStateContent(BuildContext context, PrayerTimeState state) {
    if (state is PrayerTimeLoading) {
      return _buildShimmer(context, key: const ValueKey('loading'));
    }

    if (state is PrayerTimeLocationDenied) {
      return _buildErrorState(
        context,
        state.message,
        state.isPermanentlyDenied,
        key: const ValueKey('denied'),
      );
    }

    if (state is PrayerTimeError) {
      return _buildErrorState(
        context,
        "errors.geocodingError".tr(context: context),
        true,
        key: const ValueKey('error'),
      );
    }

    if (state is PrayerTimeLoaded) {
      final prayers = [
        (
          name: "home.prayer_names.fajr".tr(context: context),
          time: state.prayerTimes.fajr,
          prayer: Prayer.fajr,
          image: Assets.images.fajr,
        ),
        (
          name: "home.prayer_names.sunrise".tr(context: context),
          time: state.prayerTimes.sunrise,
          prayer: Prayer.sunrise,
          image: Assets.images.shrouq,
        ),
        (
          name: "home.prayer_names.dhuhr".tr(context: context),
          time: state.prayerTimes.dhuhr,
          prayer: Prayer.dhuhr,
          image: Assets.images.duhr,
        ),
        (
          name: "home.prayer_names.asr".tr(context: context),
          time: state.prayerTimes.asr,
          prayer: Prayer.asr,
          image: Assets.images.asr,
        ),
        (
          name: "home.prayer_names.maghrib".tr(context: context),
          time: state.prayerTimes.maghrib,
          prayer: Prayer.maghrib,
          image: Assets.images.maghrb,
        ),
        (
          name: "home.prayer_names.isha".tr(context: context),
          time: state.prayerTimes.isha,
          prayer: Prayer.isha,
          image: Assets.images.isha,
        ),
      ];

      return SizedBox(
        key: const ValueKey('loaded'),
        height: 185.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: prayers.length,
          separatorBuilder: (context, index) => SizedBox(width: 12.w),
          itemBuilder: (context, index) {
            final p = prayers[index];
            final timeStr = intl.DateFormat.jm(
              context.locale.languageCode,
            ).format(p.time);

            return PrayerTimesItem(
              image: p.image.path,
              title: p.name,
              time: timeStr,
              isNext: state.nextPrayer == p.prayer,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink(key: ValueKey('empty'));
  }

  Widget _buildShimmer(BuildContext context, {Key? key}) {
    final baseColor = context.colorScheme.onSurface.withValues(alpha: 0.1);
    final highlightColor = context.colorScheme.onSurface.withValues(
      alpha: 0.05,
    );

    return SizedBox(
      key: key,
      height: 185.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return Container(
            width: 100.w,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image Placeholder
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Title Placeholder
                  Container(
                    width: 60.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Time Placeholder
                  Container(
                    width: 40.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    bool permanent, {
    Key? key,
  }) {
    return Container(
      key: key,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            color: context.colorScheme.error,
            size: 32.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const LocationPickerDialog(),
                  );
                  if (result != null && context.mounted) {
                    context.read<PrayerTimeCubit>().updateLocationManually(
                      latitude: result['lat'],
                      longitude: result['lon'],
                      cityName: result['city'],
                      countryName: result['country'],
                    );
                  }
                },
                icon: const Icon(Icons.map),
                label: Text("home.select_from_map".tr(context: context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              if (permanent) ...[
                SizedBox(width: 8.w),
                OutlinedButton(
                  onPressed: () =>
                      context.read<PrayerTimeCubit>().loadPrayerTimes(),
                  child: Text("common.retry".tr(context: context)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
