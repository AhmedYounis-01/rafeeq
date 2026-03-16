// ═══════════════════════════════════════════════════════════════════════════
// FILE: features/home/ui/widgets/prayer_time.dart
// ═══════════════════════════════════════════════════════════════════════════
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
 
  static bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;
 
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
      builder: (context, state) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _build(context, state),
      ),
    );
  }
 
  Widget _build(BuildContext context, PrayerTimeState state) {
    final isTablet   = _isTablet(context);
    final screenW    = MediaQuery.of(context).size.width;
    final screenH    = MediaQuery.of(context).size.height;
 
    // حجم كل item — على التابلت نسبة من الشاشة
    final itemW = isTablet ? screenW * 0.145 : 95.w.toDouble();
    final listH = isTablet ? screenH * 0.22  : 185.h.toDouble();
 
    if (state is PrayerTimeLoading) {
      return _buildShimmer(context, itemW: itemW, listH: listH);
    }
    if (state is PrayerTimeLocationDenied) {
      return _buildError(context, state.message, state.isPermanentlyDenied);
    }
    if (state is PrayerTimeError) {
      return _buildError(context, "errors.geocodingError".tr(), true);
    }
    if (state is PrayerTimeLoaded) {
      final prayers = _prayers(context, state);
      return SizedBox(
        height: listH,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? screenW * 0.02 : 16.w,
            vertical: isTablet ? 10 : 8.h,
          ),
          itemCount: prayers.length,
          separatorBuilder: (_, __) => SizedBox(width: isTablet ? screenW * 0.018 : 12.w),
          itemBuilder: (context, i) {
            final p = prayers[i];
            return SizedBox(
              width: itemW,
              child: PrayerTimesItem(
                image: p.image,
                title: p.name,
                time: intl.DateFormat.jm(context.locale.languageCode).format(p.time),
                isNext: state.nextPrayer == p.prayer,
              ),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
 
  List<_PE> _prayers(BuildContext context, PrayerTimeLoaded s) => [
    _PE("home.prayer_names.fajr".tr(),    s.prayerTimes.fajr,    Prayer.fajr,    Assets.images.fajr.path),
    _PE("home.prayer_names.sunrise".tr(), s.prayerTimes.sunrise, Prayer.sunrise, Assets.images.shrouq.path),
    _PE("home.prayer_names.dhuhr".tr(),   s.prayerTimes.dhuhr,   Prayer.dhuhr,   Assets.images.duhr.path),
    _PE("home.prayer_names.asr".tr(),     s.prayerTimes.asr,     Prayer.asr,     Assets.images.asr.path),
    _PE("home.prayer_names.maghrib".tr(), s.prayerTimes.maghrib, Prayer.maghrib, Assets.images.maghrb.path),
    _PE("home.prayer_names.isha".tr(),    s.prayerTimes.isha,    Prayer.isha,    Assets.images.isha.path),
  ];
 
  Widget _buildShimmer(BuildContext context, {required double itemW, required double listH}) {
    final base = context.colorScheme.onSurface.withValues(alpha: 0.1);
    final hi   = context.colorScheme.onSurface.withValues(alpha: 0.05);
    final isTablet = _isTablet(context);
    final screenW  = MediaQuery.of(context).size.width;
    return SizedBox(
      height: listH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? screenW * 0.02 : 16.w,
          vertical: isTablet ? 10 : 8.h,
        ),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(width: isTablet ? screenW * 0.018 : 12.w),
        itemBuilder: (_, __) => SizedBox(
          width: itemW,
          child: Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Shimmer.fromColors(
              baseColor: base,
              highlightColor: hi,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: itemW * 0.5, height: itemW * 0.5,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(height: 10),
                  Container(width: itemW * 0.6, height: 10, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(width: itemW * 0.45, height: 8, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _buildError(BuildContext context, String msg, bool permanent) {
    final isTablet = _isTablet(context);
    final screenW = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? screenW * 0.02 : 16.w),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colorScheme.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.location_off_outlined, color: context.colorScheme.error, size: 32),
          const SizedBox(height: 8),
          Text(msg, textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.error, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (_) => const LocationPickerDialog(),
                  );
                  if (result != null && context.mounted) {
                    context.read<PrayerTimeCubit>().updateLocationManually(
                      latitude: result['lat'], longitude: result['lon'],
                      cityName: result['city'], countryName: result['country'],
                    );
                  }
                },
                icon: const Icon(Icons.map),
                label: Text("home.select_from_map".tr()),
                style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary, foregroundColor: Colors.white),
              ),
              if (permanent) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => context.read<PrayerTimeCubit>().loadPrayerTimes(),
                  child: Text("common.retry".tr()),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
 
class _PE {
  final String name; final DateTime time; final Prayer prayer; final String image;
  const _PE(this.name, this.time, this.prayer, this.image);
}
 
