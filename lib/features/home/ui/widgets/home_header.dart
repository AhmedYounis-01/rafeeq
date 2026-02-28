import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';
import 'package:rafeeq/features/home/logic/prayer_time_state.dart';
import 'package:rafeeq/features/home/logic/timer_cubit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:adhan/adhan.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePrayerHeader extends StatelessWidget {
  const HomePrayerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, timerState) {
        final now = timerState.now;
        String currentTime = timerState.currentTime;
        String amPm = timerState.amPm;

        // Determine Greeting
        String greeting;
        int hour = now.hour;
        if (hour >= 4 && hour < 11) {
          greeting = "home.greetings.morning".tr(context: context);
        } else if (hour >= 11 && hour < 16) {
          greeting = "home.greetings.afternoon".tr(context: context);
        } else if (hour >= 16 && hour < 21) {
          greeting = "home.greetings.evening".tr(context: context);
        } else {
          greeting = "home.greetings.night".tr(context: context);
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            constraints: BoxConstraints(minHeight: 280.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        const Color(0xFF061F14), // Darker, softer forest green
                        const Color(0xFF0B3D26),
                      ]
                    : [
                        const Color(
                          0xFF028544,
                        ).withValues(alpha: 0.9), // Muted primary
                        const Color(0xFF016D38).withValues(alpha: 0.9),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Premium Pattern Overlay with soft shadow/overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40.r),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.15, // Subtle pattern
                          child: Image.asset(
                            Assets.images.best.path,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Soft shadow overlay to make content readable
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Navigation Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLocationInfo(context),
                          _buildCalendarButton(context),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Central Clock Area
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Text(
                              greeting,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  currentTime,
                                  style: context.textTheme.displayLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 82.sp,
                                        fontWeight: FontWeight.w200,
                                        height: 1,
                                        letterSpacing: -3,
                                      ),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      amPm.toUpperCase(),
                                      style: context.textTheme.titleLarge
                                          ?.copyWith(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 22.sp,
                                          ),
                                    ),
                                    Container(
                                      height: 3.5.h,
                                      width: 14.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(
                                          2.r,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Next Prayer Interactive Card
                      _buildPrayerCard(context, now),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
      builder: (context, state) {
        String location = "home.loading_location".tr(context: context);
        if (state is PrayerTimeLoaded) {
          location = "${state.cityName}, ${state.countryName}";
        }
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.secondary,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  location,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.2),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: () => _showPremiumCalendar(context),
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  void _showPremiumCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) => _CalendarModal(),
    );
  }

  Widget _buildPrayerCard(BuildContext context, DateTime now) {
    return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
      builder: (context, state) {
        if (state is! PrayerTimeLoaded) return const SizedBox.shrink();
        final next = state.nextPrayer;
        final prayerName = _getPrayerNameLocalized(next);
        final nextTime = state.nextPrayerTime;
        final prayerTimeStr = intl.DateFormat.jm(
          context.locale.languageCode,
        ).format(nextTime);

        // Countdown
        String countdown = "--:--:--";
        final diff = nextTime.difference(now);
        if (!diff.isNegative) {
          final hours = diff.inHours;
          final minutes = diff.inMinutes % 60;
          final seconds = diff.inSeconds % 60;
          countdown =
              "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              _buildPrayerIcon(next),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "home.next_prayer".tr(context: context),
                      style: context.textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "$prayerName - $prayerTimeStr",
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  countdown,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerIcon(Prayer prayer) {
    IconData icon;
    if (prayer == Prayer.fajr || prayer == Prayer.isha) {
      icon = Icons.nights_stay_rounded;
    } else if (prayer == Prayer.maghrib) {
      icon = Icons.wb_twilight_rounded;
    } else {
      icon = Icons.wb_sunny_rounded;
    }
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.secondary, size: 20.sp),
    );
  }

  String _getPrayerNameLocalized(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return "home.prayer_names.fajr".tr();
      case Prayer.sunrise:
        return "home.prayer_names.sunrise".tr();
      case Prayer.dhuhr:
        return "home.prayer_names.dhuhr".tr();
      case Prayer.asr:
        return "home.prayer_names.asr".tr();
      case Prayer.maghrib:
        return "home.prayer_names.maghrib".tr();
      case Prayer.isha:
        return "home.prayer_names.isha".tr();
      default:
        return "---";
    }
  }
}

class _CalendarModal extends StatefulWidget {
  @override
  State<_CalendarModal> createState() => _CalendarModalState();
}

class _CalendarModalState extends State<_CalendarModal> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141C18) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Stack(
        children: [
          // Background Decorative elements
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            children: [
              // SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "home.calendar_title".tr(context: context),
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 22.sp,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TableCalendar(
                          firstDay: DateTime.now().subtract(
                            const Duration(days: 365 * 5),
                          ),
                          lastDay: DateTime.now().add(
                            const Duration(days: 365 * 5),
                          ),
                          focusedDay: _focusedDay,
                          locale: context.locale.languageCode,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                            defaultTextStyle: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.textPrimary,
                              fontSize: 15.sp,
                            ),
                            weekendTextStyle: TextStyle(
                              color: AppColors.error.withValues(alpha: 0.7),
                              fontSize: 15.sp,
                            ),
                            outsideDaysVisible: false,
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: context.textTheme.titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                            leftChevronIcon: Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.primary,
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                            weekendStyle: TextStyle(
                              color: AppColors.error.withValues(alpha: 0.4),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      if (_selectedDay != null)
                        _buildPrayerSchedule(context, _selectedDay!),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerSchedule(BuildContext context, DateTime date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = intl.DateFormat(
      'EEEE, d MMMM',
      context.locale.languageCode,
    ).format(date);

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : AppColors.primary.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                color: AppColors.secondary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                dateStr,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            "home.prayer_schedule_hint".tr(context: context),
            style: context.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          // In a real app, you'd calculate prayer times for this specific date here.
          // For now, this is a beautiful placeholder showing the schedule layout.
        ],
      ),
    );
  }
}
