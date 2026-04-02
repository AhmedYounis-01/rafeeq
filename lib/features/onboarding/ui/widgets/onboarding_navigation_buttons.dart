import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

// ─── Responsive Config ────────────────────────────────────────────────────────
class _Cfg {
  final double side, width, height;
  _Cfg(BuildContext ctx)
    : side = MediaQuery.sizeOf(ctx).shortestSide,
      width = MediaQuery.sizeOf(ctx).width,
      height = MediaQuery.sizeOf(ctx).height;

  bool get isTablet => side >= 600;

  double get btnHeight => (side * 0.15).clamp(56.0, 68.0);
  double get fontSize => (side * 0.042).clamp(14.0, 18.0);
  double get skipFontSize => (side * 0.038).clamp(13.0, 17.0);
  double get iconSize => (side * 0.05).clamp(18.0, 24.0);
  double get nextBtnSize => (side * 0.16).clamp(58.0, 72.0);
  double get nextIconSize => (side * 0.062).clamp(22.0, 30.0);
}

class OnboardingNavigationButtons extends StatefulWidget {
  final bool isLastPage;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const OnboardingNavigationButtons({
    super.key,
    required this.isLastPage,
    required this.onSkip,
    required this.onNext,
  });

  @override
  State<OnboardingNavigationButtons> createState() =>
      _OnboardingNavigationButtonsState();
}

class _OnboardingNavigationButtonsState
    extends State<OnboardingNavigationButtons>
    with SingleTickerProviderStateMixin {
  // Pulse animation for the next button arrow
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cfg = _Cfg(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: widget.isLastPage
          ? _buildStartButton(isDark, cfg, isRtl)
          : _buildNavRow(isDark, cfg, isRtl),
    );
  }

  // ─────────────────────────────────────────
  //  "Start Now" — full-width gradient pill
  // ─────────────────────────────────────────
  Widget _buildStartButton(bool isDark, _Cfg cfg, bool isRtl) {
    return SizedBox(
      key: const ValueKey('start'),
      width: double.infinity,
      height: cfg.btnHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.primaryDark, const Color(0xFF03C464)]
                : [AppColors.primary, const Color(0xFF02A856)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: widget.onSkip,
            splashColor: Colors.white.withAlpha(40),
            highlightColor: Colors.white.withAlpha(20),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                // Natural RTL flip: Icon will be on Left in Ar, Right in En
                children: [
                  Text(
                    "onboarding.lets_start".tr(),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: cfg.fontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: isRtl ? 0 : 0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Forward arrow pointing right for both languages
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_pulseAnimation.value * 0.6, 0),
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  Skip + Next row
  // ─────────────────────────────────────────
  Widget _buildNavRow(bool isDark, _Cfg cfg, bool isRtl) {
    return Row(
      key: const ValueKey('nav'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Skip ──
        TextButton(
          onPressed: widget.onSkip,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            foregroundColor: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'onboarding.skip'.tr(),
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: cfg.skipFontSize,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),

        // ── Next circle button with forward-pointing arrow ──
        Tooltip(
          message: 'onboarding.next'.tr(),
          child: GestureDetector(
            onTap: widget.onNext,
            child: Container(
              width: cfg.nextBtnSize,
              height: cfg.nextBtnSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.primaryDark, const Color(0xFF03C464)]
                      : [AppColors.primary, const Color(0xFF02A856)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withAlpha(25),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Center(
                    child: Transform.translate(
                      // Continuous forward pulse toward the right
                      offset: Offset(_pulseAnimation.value, 0),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
