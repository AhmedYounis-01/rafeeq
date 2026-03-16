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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerCubit(),
      child: Column(
        children: [
          SafeArea(child: CustomAppBar(title: "home.app_name".tr())),
          Expanded(
            child: Builder(
              builder: (context) => RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  await context.read<PrayerTimeCubit>().loadPrayerTimes(
                    isManual: true,
                  );
                },
                // نفس الـ ListView للاتنين — الفرق في الـ padding والأحجام جوا كل widget
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    // tablet: padding أكبر من الجانبين عشان المحتوى ما يتمددش لآخر الشاشة
                    horizontal: isTablet(context)
                        ? MediaQuery.of(context).size.width * 0.06
                        : 0,
                  ),
                  children: [
                    const HomePrayerHeader(),
                    SizedBox(height: isTablet(context) ? 20 : 16.h),
                    const PrayerTime(),
                    SizedBox(height: isTablet(context) ? 20 : 16.h),
                    const QuickParts(),
                    SizedBox(height: isTablet(context) ? 40 : 50.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// // ─── Mobile Layout ────────────────────────────────────────────────────────────
// class _MobileLayout extends StatelessWidget {
//   const _MobileLayout();

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       children: [
//         const HomePrayerHeader(),
//         SizedBox(height: 16.h),
//         const PrayerTime(),
//         SizedBox(height: 16.h),
//         const QuickParts(),
//         SizedBox(height: 50.h),
//       ],
//     );
//   }
// }

// // ─── Tablet Layout ─────────────────────────────────────────────────────────────
// class _TabletLayout extends StatelessWidget {
//   const _TabletLayout();

//   @override
//   Widget build(BuildContext context) {
//     final screenW = MediaQuery.of(context).size.width;
//     final screenH = MediaQuery.of(context).size.height;
//     final pad = screenW * 0.025; // 2.5% padding جانبي

//     return SingleChildScrollView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── العمود الأيمن (58%) ──────────────────────────────────────────
//           Expanded(
//             flex: 58,
//             child: Column(
//               children: [
//                 const TabletHeader(),
//                 SizedBox(height: screenH * 0.02),
//                 const TabletPrayerGrid(),
//               ],
//             ),
//           ),
//           SizedBox(width: pad),
//           // ── العمود الأيسر (42%) ──────────────────────────────────────────
//           Expanded(flex: 42, child: const TabletQuickParts()),
//         ],
//       ),
//     );
//   }
// }
