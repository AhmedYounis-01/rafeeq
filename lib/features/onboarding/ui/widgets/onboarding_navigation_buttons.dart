import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

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
          ? _buildStartButton(isDark)
          : _buildNavRow(isDark),
    );
  }

  // ─────────────────────────────────────────
  //  "Let's Start" — full-width gradient pill
  // ─────────────────────────────────────────
  Widget _buildStartButton(bool isDark) {
    return SizedBox(
      key: const ValueKey('start'),
      width: double.infinity,
      height: 56.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
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
            borderRadius: BorderRadius.circular(28.r),
            onTap: widget.onSkip,
            splashColor: Colors.white.withAlpha(40),
            highlightColor: Colors.white.withAlpha(20),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Let's Start",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20.sp,
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
  Widget _buildNavRow(bool isDark) {
    return Row(
      key: const ValueKey('nav'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Skip ──
        TextButton(
          onPressed: widget.onSkip,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            foregroundColor: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Skip',
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),

        // ── Next circle button with animated arrow ──
        GestureDetector(
          onTap: widget.onNext,
          child: Container(
            width: 58.w,
            height: 58.h,
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
                    offset: Offset(_pulseAnimation.value, 0),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
