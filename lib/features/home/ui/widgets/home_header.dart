// ═══════════════════════════════════════════════════════════════════════════
// FILE: features/home/ui/widgets/home_header.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';
import 'package:rafeeq/features/home/logic/prayer_time_state.dart';
import 'package:rafeeq/features/home/logic/timer_cubit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:adhan/adhan.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:rafeeq/core/helpers/location_helper.dart';

class HomePrayerHeader extends StatelessWidget {
  const HomePrayerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hPad = isTablet ? screenW * 0.02 : 16.w.toDouble();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        constraints: BoxConstraints(
          minHeight: isTablet ? screenH * 0.32 : 280.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 36 : 40.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF061F14), const Color(0xFF0B3D26)]
                : [
                    const Color(0xFF026635).withValues(alpha: 0.90),
                    const Color(0xFF028544).withValues(alpha: 0.80),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.09),
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
                  opacity: isDark ? 0.15 : 0.12,
                  child: Image.asset(
                    Assets.images.best.path,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            color: Colors.white.withValues(alpha: isDark ? 0.85 : 0.93),
            fontWeight: FontWeight.w600,
            fontSize:
                MediaQuery.of(context).size.width * (isTablet ? 0.022 : 0.034),
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
        final locale = context.locale.languageCode;
        final timeStr = intl.DateFormat('hh:mm', locale).format(s.now);
        final amPmStr = intl.DateFormat('a', locale).format(s.now);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              timeStr,
              style: TextStyle(
                color: Colors.white,
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
                  amPmStr.toUpperCase(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final fontSize =
        MediaQuery.of(context).size.width * (isTablet ? 0.019 : 0.031);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        LocationHelper.showLocationOptions(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
        buildWhen: (prev, curr) => prev != curr,
        builder: (context, state) {
          final loc = state is PrayerTimeLoaded
              ? "${state.cityName}, ${state.countryName}"
              : "home.loading_location".tr();

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: isDark ? colorScheme.secondary : Colors.white,
                size:
                    MediaQuery.of(context).size.width *
                    (isTablet ? 0.025 : 0.04),
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width *
                      (isTablet ? 0.28 : 0.38),
                ),
                child: Text(
                  loc,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: isDark ? 0.9 : 0.95),
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CalendarBtn extends StatelessWidget {
  final bool isTablet;
  const _CalendarBtn({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconSize =
        MediaQuery.of(context).size.width * (isTablet ? 0.032 : 0.05);
    return Material(
      color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.25),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _show(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 11 : 10),
          child: Icon(
            Icons.calendar_month_outlined,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  void _show(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: false,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final accentColor = isDark ? colorScheme.secondary : colorScheme.primary;
    final fontSize = screenW * (isTablet ? 0.022 : 0.038);

    return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        if (state is! PrayerTimeLoaded) return const SizedBox.shrink();

        final nextTime = state.nextPrayerTime;
        final timeStr = intl.DateFormat.jm(
          context.locale.languageCode,
        ).format(nextTime);
        final name = _prayerName(state.nextPrayer);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenW * (isTablet ? 0.03 : 0.045),
            vertical: isTablet ? 16 : 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.22),
            borderRadius: BorderRadius.circular(isTablet ? 22 : 24.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.28),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              _prayerIcon(state.nextPrayer, screenW, isTablet, accentColor),
              SizedBox(width: screenW * 0.025),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "home.next_prayer_after".tr(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
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

  Widget _prayerIcon(
    Prayer prayer,
    double screenW,
    bool isTablet,
    Color accentColor,
  ) {
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
        color: AppColors.primary.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColors.secondary,
        size: screenW * (isTablet ? 0.032 : 0.05),
      ),
    );
  }

  String _prayerName(Prayer prayer) {
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

class _Countdown extends StatefulWidget {
  final DateTime nextTime;
  final bool isTablet;
  const _Countdown({required this.nextTime, required this.isTablet});

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  late final ValueNotifier<DateTime> _timeNotifier;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeNotifier = ValueNotifier(DateTime.now());

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeNotifier.value = DateTime.now();

    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;

    _timer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      if (!mounted) return;
      _timeNotifier.value = DateTime.now();
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (!mounted) return;
        _timeNotifier.value = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final accentColor = isDark ? colorScheme.secondary : colorScheme.primary;

    return ValueListenableBuilder<DateTime>(
      valueListenable: _timeNotifier,
      builder: (context, now, _) {
        final diff = widget.nextTime.difference(now);
        final hUnit = "home.units.hour".tr();
        final mUnit = "home.units.minute".tr();
        final locale = context.locale.languageCode;

        final dummy = DateTime(0, 1, 1, diff.inHours, diff.inMinutes % 60);
        final localizedHours = intl.DateFormat('HH', locale).format(dummy);
        final localizedMinutes = intl.DateFormat('mm', locale).format(dummy);

        final text = diff.isNegative
            ? "-- $hUnit -- $mUnit"
            : "$localizedHours $hUnit $localizedMinutes $mUnit";

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenW * (widget.isTablet ? 0.022 : 0.025),
            vertical: widget.isTablet ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
              fontSize: screenW * (widget.isTablet ? 0.028 : 0.032),
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }
}

// Calendar Modal
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
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "home.calendar_title".tr(),
                  style: TextStyle(
                    color: const Color(0xffFFFFFF),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                Material(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.3),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: const Color(0xffFFFFFF),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundCardDark.withValues(alpha: 0.8)
                      : AppColors.backgroundCard.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(
                      const Duration(days: 365 * 5),
                    ),
                    lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
                    focusedDay: _focusedDay,
                    locale: context.locale.languageCode,
                    selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                    onDaySelected: (s, f) => setState(() {
                      _selectedDay = s;
                      _focusedDay = f;
                    }),
                    weekendDays: const [DateTime.friday, DateTime.saturday],
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) =>
                          _buildDayCell(day, colorScheme, isDark),
                      selectedBuilder: (context, day, focusedDay) =>
                          _buildDayCell(
                            day,
                            colorScheme,
                            isDark,
                            isSelected: true,
                          ),
                      todayBuilder: (context, day, focusedDay) => _buildDayCell(
                        day,
                        colorScheme,
                        isDark,
                        isToday: true,
                      ),
                      outsideBuilder: (context, day, focusedDay) =>
                          _buildDayCell(
                            day,
                            colorScheme,
                            isDark,
                            isOutside: true,
                          ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      weekendStyle: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                      leftChevronIcon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      rightChevronIcon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                    ),
                    rowHeight: 52,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    ColorScheme colorScheme,
    bool isDark, {
    bool isSelected = false,
    bool isToday = false,
    bool isOutside = false,
  }) {
    final hijriDate = HijriCalendar.fromDate(day);
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: isSelected
          ? BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : isToday
          ? BoxDecoration(
              border: Border.all(color: colorScheme.primary, width: 2),
              shape: BoxShape.circle,
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isOutside
                        ? (isDark ? Colors.white24 : Colors.black26)
                        : (isDark ? Colors.white : Colors.black87)),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '${hijriDate.hDay}',
            style: TextStyle(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.7)
                  : (isOutside
                        ? (isDark ? Colors.white10 : Colors.black12)
                        : (isDark ? Colors.white38 : Colors.black38)),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
