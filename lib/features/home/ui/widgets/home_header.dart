// ═══════════════════════════════════════════════════════════════════════════
// FILE: features/home/ui/widgets/home_header.dart
// ═══════════════════════════════════════════════════════════════════════════
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
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final screenW  = MediaQuery.of(context).size.width;
    final screenH  = MediaQuery.of(context).size.height;
 
    // على التابلت: padding أصغر من الجانب عشان الـ ListView عنده padding خارجي
    final hPad = isTablet ? screenW * 0.02 : 16.w.toDouble();
 
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        // الهيدر يأخذ نسبة من ارتفاع الشاشة
        constraints: BoxConstraints(
          minHeight: isTablet ? screenH * 0.32 : 280.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 36 : 40.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF061F14), const Color(0xFF0B3D26)]
                : [
                    const Color(0xFF028544).withValues(alpha: 0.9),
                    const Color(0xFF016D38).withValues(alpha: 0.9),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isTablet ? 36 : 40.r),
                child: Opacity(
                  opacity: 0.15,
                  child: Image.asset(Assets.images.best.path, fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              // padding داخلي أكبر على التابلت
              padding: EdgeInsets.all(isTablet ? screenW * 0.04 : 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LocationInfo(isTablet: isTablet),
                      _CalendarBtn(isTablet: isTablet),
                    ],
                  ),
                  SizedBox(height: isTablet ? screenH * 0.025 : 20.h),
                  _Greeting(isTablet: isTablet),
                  SizedBox(height: isTablet ? 8 : 12.h),
                  _Clock(isTablet: isTablet, screenW: screenW),
                  SizedBox(height: isTablet ? screenH * 0.025 : 20.h),
                  _NextPrayerCard(isTablet: isTablet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _Greeting extends StatelessWidget {
  final bool isTablet;
  const _Greeting({required this.isTablet});
 
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      buildWhen: (p, c) => p.now.hour != c.now.hour,
      builder: (context, s) {
        final h = s.now.hour;
        final greeting = h >= 4 && h < 11
            ? "home.greetings.morning".tr()
            : h >= 11 && h < 16
                ? "home.greetings.afternoon".tr()
                : h >= 16 && h < 21
                    ? "home.greetings.evening".tr()
                    : "home.greetings.night".tr();
        return Text(
          greeting,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
            // حجم الخط يتحسب من عرض الشاشة
            fontSize: MediaQuery.of(context).size.width * (isTablet ? 0.022 : 0.034),
            letterSpacing: 0.6,
          ),
        );
      },
    );
  }
}
 
class _Clock extends StatelessWidget {
  final bool isTablet;
  final double screenW;
  const _Clock({required this.isTablet, required this.screenW});
 
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, s) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              s.currentTime,
              style: TextStyle(
                color: Colors.white,
                // الساعة تاخد نسبة من عرض الشاشة — تبقى كبيرة على التابلت
                fontSize: screenW * (isTablet ? 0.14 : 0.18),
                fontWeight: FontWeight.w200,
                height: 1,
                letterSpacing: -2,
              ),
            ),
            SizedBox(width: screenW * 0.025),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.amPm.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                    fontSize: screenW * (isTablet ? 0.038 : 0.055),
                  ),
                ),
                Container(
                  height: 3,
                  width: screenW * 0.03,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
 
class _LocationInfo extends StatelessWidget {
  final bool isTablet;
  const _LocationInfo({required this.isTablet});
 
  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).size.width * (isTablet ? 0.019 : 0.031);
    return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
      builder: (context, state) {
        final loc = state is PrayerTimeLoaded
            ? "${state.cityName}, ${state.countryName}"
            : "home.loading_location".tr();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded, color: AppColors.secondary,
                size: MediaQuery.of(context).size.width * (isTablet ? 0.025 : 0.04)),
            SizedBox(width: 6),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * (isTablet ? 0.28 : 0.38)),
              child: Text(
                loc,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
 
class _CalendarBtn extends StatelessWidget {
  final bool isTablet;
  const _CalendarBtn({required this.isTablet});
 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconSize = MediaQuery.of(context).size.width * (isTablet ? 0.032 : 0.05);
    return Material(
      color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _show(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 11 : 10),
          child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
 
  void _show(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
      builder: (_) => _CalendarModal(),
    );
  }
}
 
class _NextPrayerCard extends StatelessWidget {
  final bool isTablet;
  const _NextPrayerCard({required this.isTablet});
 
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final fontSize = screenW * (isTablet ? 0.022 : 0.038);
 
    return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
      builder: (context, state) {
        if (state is! PrayerTimeLoaded) return const SizedBox.shrink();
        final nextTime = state.nextPrayerTime;
        final timeStr = intl.DateFormat.jm(context.locale.languageCode).format(nextTime);
        final name = _prayerName(state.nextPrayer);
 
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenW * (isTablet ? 0.03 : 0.045),
            vertical: isTablet ? 16 : 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(isTablet ? 22 : 24.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
          ),
          child: Row(
            children: [
              _prayerIcon(state.nextPrayer, screenW, isTablet),
              SizedBox(width: screenW * 0.025),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "home.next_prayer".tr(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: fontSize * 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$name - $timeStr",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ),
              _Countdown(nextTime: nextTime, isTablet: isTablet),
            ],
          ),
        );
      },
    );
  }
 
  Widget _prayerIcon(Prayer prayer, double screenW, bool isTablet) {
    IconData icon;
    if (prayer == Prayer.fajr || prayer == Prayer.isha) {
      icon = Icons.nights_stay_rounded;
    } else if (prayer == Prayer.maghrib) {
      icon = Icons.wb_twilight_rounded;
    } else {
      icon = Icons.wb_sunny_rounded;
    }
    return Container(
      padding: EdgeInsets.all(screenW * (isTablet ? 0.018 : 0.022)),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.secondary,
          size: screenW * (isTablet ? 0.032 : 0.05)),
    );
  }
 
  String _prayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:    return "home.prayer_names.fajr".tr();
      case Prayer.sunrise: return "home.prayer_names.sunrise".tr();
      case Prayer.dhuhr:   return "home.prayer_names.dhuhr".tr();
      case Prayer.asr:     return "home.prayer_names.asr".tr();
      case Prayer.maghrib: return "home.prayer_names.maghrib".tr();
      case Prayer.isha:    return "home.prayer_names.isha".tr();
      default:             return "---";
    }
  }
}
 
class _Countdown extends StatelessWidget {
  final DateTime nextTime;
  final bool isTablet;
  const _Countdown({required this.nextTime, required this.isTablet});
 
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, s) {
        final diff = nextTime.difference(s.now);
        final text = diff.isNegative
            ? "--:--:--"
            : "${diff.inHours.toString().padLeft(2,'0')}:"
              "${(diff.inMinutes%60).toString().padLeft(2,'0')}:"
              "${(diff.inSeconds%60).toString().padLeft(2,'0')}";
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenW * (isTablet ? 0.022 : 0.025),
            vertical: isTablet ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
              fontSize: screenW * (isTablet ? 0.02 : 0.028),
            ),
          ),
        );
      },
    );
  }
}
 
// Calendar Modal بدون تغيير
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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("home.calendar_title".tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w900, fontSize: 20)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded,
                      color: isDark ? Colors.white60 : Colors.black45),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365 * 5)),
                lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
                focusedDay: _focusedDay,
                locale: context.locale.languageCode,
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                onDaySelected: (s, f) => setState(() { _selectedDay = s; _focusedDay = f; }),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false, titleCentered: true,
                  leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                  rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                  todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  outsideDaysVisible: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
