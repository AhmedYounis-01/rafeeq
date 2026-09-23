import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/tasbih/data/model/tasbih_model.dart';
import 'package:rafeeq/features/tasbih/logic/tasbih_state.dart';
import 'tasbih_config.dart';
import 'counter_dhikr_card.dart';
import 'stat_box.dart';
import 'tap_button.dart';
import 'session_log_sheet.dart';

class CounterScreen extends StatelessWidget {
  final bool isDark, isRtl, completed, silentMode;
  final TasbihConfig cfg;
  final Color primary;
  final TasbihModel dhikr;
  final int count, todayTotal;
  final List<TasbihSession> sessions;
  final VoidCallback onTap, onReset, onBack, onNext, onPrev, onSilentToggle;

  const CounterScreen({
    super.key,
    required this.isDark,
    required this.isRtl,
    required this.cfg,
    required this.primary,
    required this.dhikr,
    required this.count,
    required this.completed,
    required this.silentMode,
    required this.sessions,
    required this.todayTotal,
    required this.onTap,
    required this.onReset,
    required this.onBack,
    required this.onNext,
    required this.onPrev,
    required this.onSilentToggle,
  });

  int get _target => dhikr.count;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final subtextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final iconColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sliver AppBar for Navigation ──
          SliverAppBar(
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.background(context),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: iconColor,
                style: IconButton.styleFrom(
                  backgroundColor: primary.withValues(alpha: 0.08),
                  shape: const CircleBorder(),
                ),
              ),
            ),
            actions: [
              if (sessions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () => _sheet(
                      context,
                      SessionLogSheet(
                        sessions: sessions,
                        isDark: isDark,
                        cfg: cfg,
                        primary: primary,
                        todayTotal: todayTotal,
                      ),
                    ),
                    icon: const Icon(Icons.history_rounded, size: 20),
                    color: iconColor,
                    style: IconButton.styleFrom(
                      backgroundColor: primary.withValues(alpha: 0.08),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
            ],
          ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: cfg.isTablet ? 600 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Dhikr Card
                      CounterDhikrCard(
                        dhikr: dhikr,
                        isRtl: isRtl,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        primary: primary,
                        isDark: isDark,
                        cfg: cfg,
                        onNext: onNext,
                        onPrev: onPrev,
                      ),

                      const SizedBox(height: 24),

                      // Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: StatBox(
                                label: 'tasbih.totalBeads'.tr(),
                                value: '$_target',
                                primary: primary,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatBox(
                                label: 'tasbih.current'.tr(),
                                value: '$count',
                                primary: primary,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tap Button
                      Expanded(
                        child: Center(
                          child: TapButton(
                            onTap: onTap,
                            primary: primary,
                            count: count,
                            target: _target,
                            completed: completed,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      // Subtitle
                      if (dhikr.sub.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: Text(
                            dhikr.sub,
                            textAlign: TextAlign.center,
                            maxLines: 8,
                            style: TasbihTextStyles.amiri(
                              cfg.labelFont,
                              subtextColor.withValues(alpha: 0.6),
                              style: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),

                      // Reset Button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: onReset,
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            label: Text(
                              'tasbih.reset'.tr(),
                              style: TasbihTextStyles.amiriBold(
                                cfg.labelFont + 3,
                                Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),

                      // Bottom Padding for Nav Bar
                      SizedBox(height: 110.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sheet(BuildContext ctx, Widget w) => showModalBottomSheet(
    context: ctx,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => w,
  );
}
