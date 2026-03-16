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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimerCubit(),
      child: Column(
        children: [
          SafeArea(child: CustomAppBar(title: "home.app_name".tr())),
          Expanded(
            child: Builder(
              builder: (context) {
                return RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.mediumImpact();
                    await context.read<PrayerTimeCubit>().loadPrayerTimes(
                      isManual: true,
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const HomePrayerHeader(),
                      SizedBox(height: 16.h),
                      const PrayerTime(),
                      SizedBox(height: 16.h),
                      const QuickParts(),
                      SizedBox(height: 50.h),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
