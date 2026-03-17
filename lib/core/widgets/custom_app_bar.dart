// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:rafeeq/core/extensions/theme_extension.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';
// import 'package:rafeeq/features/home/logic/prayer_time_state.dart';
// import 'package:easy_localization/easy_localization.dart';

// class CustomAppBar extends StatelessWidget {
//   const CustomAppBar({super.key, required this.title});
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 8.w),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Menu Button to open Drawer
//           Builder(
//             builder: (context) => IconButton(
//               onPressed: () {
//                 HapticFeedback.lightImpact();
//                 Scaffold.of(context).openDrawer();
//               },
//               style: IconButton.styleFrom(
//                 minimumSize: Size(44.w, 44.h),
//                 padding: EdgeInsets.zero,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 backgroundColor: context.colorScheme.surfaceContainerHighest
//                     .withValues(alpha: 0.3),
//               ),
//               icon: Icon(
//                 Icons.menu_rounded,
//                 color: context.colorScheme.primary,
//                 size: 28.sp,
//               ),
//             ),
//           ),

//           BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
//             builder: (context, state) {
//               String locationText = "common.loading".tr();
//               if (state is PrayerTimeLoaded) {
//                 locationText = "${state.cityName} - ${state.countryName}";
//               } else if (state is PrayerTimeLocationDenied) {
//                 locationText = "home.unknown_location".tr();
//               }
//               return Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   color: context.colorScheme.surfaceContainerHighest.withValues(
//                     alpha:0.3,
//                   ),
//                   borderRadius: BorderRadius.circular(16.r),
//                 ),
//                 child: Row(
//                   children: [
//                     Text(
//                       locationText,
//                       style: context.textTheme.titleMedium?.copyWith(
//                         color: context.colorScheme.onSurface,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                     SizedBox(width: 4.w),
//                     Icon(
//                       Icons.location_on,
//                       color: context.colorScheme.primary,
//                       size: 20.sp,
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// ═══════════════════════════════════════════════════════════════════════════
// FILE: core/widgets/custom_app_bar.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/features/home/logic/prayer_time_cubit.dart';
import 'package:rafeeq/features/home/logic/prayer_time_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

// ─── Responsive Config ────────────────────────────────────────────────────────
class _AppBarCfg {
  final double side;
  _AppBarCfg(BuildContext ctx) : side = MediaQuery.of(ctx).size.shortestSide;

  bool get isTablet => side >= 600;
  double get hPad => isTablet ? 16.0 : 8.0;
  double get btnSize => (side * 0.1).clamp(36.0, 52.0);
  double get iconSize => (side * 0.06).clamp(22.0, 32.0);
  double get fontSize => (side * 0.036).clamp(13.0, 17.0);
  double get radius => isTablet ? 16.0 : 12.0;
  double get chipVPad => isTablet ? 8.0 : 6.0;
  double get chipHPad => isTablet ? 16.0 : 12.0;
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cfg = _AppBarCfg(context);
    final isDark = context.theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cfg.hPad, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Menu Button ──────────────────────────────────────────────────
          // على التابلت: إما مخفي (لأن السايدبار ظاهر) أو أصغر
          _MenuButton(cfg: cfg, isDark: isDark),

          // ── Location Chip ─────────────────────────────────────────────────
          Spacer(),
          _LocationChip(cfg: cfg),
        ],
      ),
    );
  }
}

// ─── Menu Button ──────────────────────────────────────────────────────────────
class _MenuButton extends StatelessWidget {
  final _AppBarCfg cfg;
  final bool isDark;
  const _MenuButton({required this.cfg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Scaffold.of(context).openDrawer();
        },
        borderRadius: BorderRadius.circular(cfg.radius),
        child: Container(
          width: cfg.btnSize,
          height: cfg.btnSize,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.35,
            ),
            borderRadius: BorderRadius.circular(cfg.radius),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Icon(
            Icons.menu_rounded,
            color: AppColors.getPrimary(context),
            size: cfg.iconSize,
          ),
        ),
      ),
    );
  }
}

// ─── Location Chip ────────────────────────────────────────────────────────────
class _LocationChip extends StatelessWidget {
  final _AppBarCfg cfg;
  const _LocationChip({required this.cfg});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
      builder: (context, state) {
        final String locationText;
        final bool isLoading;

        if (state is PrayerTimeLoaded) {
          locationText = "${state.cityName} - ${state.countryName}";
          isLoading = false;
        } else if (state is PrayerTimeLocationDenied) {
          locationText = "home.unknown_location".tr();
          isLoading = false;
        } else {
          locationText = "common.loading".tr();
          isLoading = true;
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width * (cfg.isTablet ? 0.4 : 0.55),
          ),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: cfg.chipHPad,
              vertical: cfg.chipVPad,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(cfg.radius + 4),
              border: Border.all(
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: cfg.iconSize * 0.6,
                    height: cfg.iconSize * 0.6,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.getPrimary(context),
                    ),
                  )
                else
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.getPrimary(context),
                    size: cfg.iconSize * 0.8,
                  ),
                SizedBox(width: cfg.isTablet ? 8.0 : 4.0),
                Flexible(
                  child: Text(
                    locationText,
                    style: TextStyle(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: cfg.fontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
