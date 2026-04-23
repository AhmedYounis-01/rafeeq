// ═══════════════════════════════════════════════════════════════════════════
// FILE: features/home/ui/home_screen.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/widgets/custom_app_bar.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';
import 'package:rafeeq/features/home/logic/timer_cubit.dart';
import 'widgets/home_header.dart';
import 'widgets/prayer_time.dart';
import 'widgets/quick_parts.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PrayerTimeCubit>().loadPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = HomeScreen.isTablet(context);
    return BlocProvider(
      create: (_) => TimerCubit(),
      child: Builder(
        builder: (context) => RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            // ✅ Only refresh data using current settings (don't force GPS if we have location)
            await context.read<PrayerTimeCubit>().loadPrayerTimes(
              isManual: false,
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet
                  ? MediaQuery.of(context).size.width * 0.02
                  : 0,
            ),
            children: [
              SafeArea(
                bottom: false,
                child: CustomAppBar(title: "home.app_name".tr()),
              ),
              SizedBox(height: isTablet ? 20 : 16.h),
              const HomePrayerHeader(),
              SizedBox(height: isTablet ? 20 : 16.h),
              const PrayerTime(),
              SizedBox(height: isTablet ? 20 : 16.h),
              const QuickParts(),
              SizedBox(height: isTablet ? 120.h : 110.h),
            ],
          ),
        ),
      ),
    );
  }
}
