import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import '../../data/models/onboarding_item.dart';

// ─── Responsive Config ────────────────────────────────────────────────────────
class _Cfg {
  final double side, width, height;
  _Cfg(BuildContext ctx)
    : side = MediaQuery.sizeOf(ctx).shortestSide,
      width = MediaQuery.sizeOf(ctx).width,
      height = MediaQuery.sizeOf(ctx).height;

  bool get isTablet => side >= 600;

  double get hPad => (side * 0.08).clamp(24.0, 64.0);
  double get imageMargin => (side * 0.04).clamp(12.0, 40.0);
  double get titleSize => (side * 0.06).clamp(18.0, 28.0);
  double get descSize => (side * 0.04).clamp(13.0, 18.0);
  double get imageFlex => isTablet ? 6 : 5;
  double get spacingAboveTitle => (side * 0.1).clamp(24.0, 48.0);
}

class OnboardingPageItem extends StatelessWidget {
  final OnboardingItem item;
  final Animation<double> imageScale;
  final Animation<double> imageFade;
  final Animation<double> floatAnimation;
  final Animation<Offset> titleSlide;
  final Animation<double> titleFade;
  final Animation<Offset> descSlide;
  final Animation<double> descFade;

  const OnboardingPageItem({
    super.key,
    required this.item,
    required this.imageScale,
    required this.imageFade,
    required this.floatAnimation,
    required this.titleSlide,
    required this.titleFade,
    required this.descSlide,
    required this.descFade,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cfg = _Cfg(context);
    final isAr = context.locale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cfg.hPad),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // ── Floating Image with scale + fade + float ──
          Expanded(
            flex: cfg.imageFlex.toInt(),
            child: FadeTransition(
              opacity: imageFade,
              child: ScaleTransition(
                scale: imageScale,
                child: AnimatedBuilder(
                  animation: floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, floatAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: cfg.imageMargin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withAlpha(60)
                              : AppColors.primary.withAlpha(20),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withAlpha(30)
                              : AppColors.primary.withAlpha(8),
                          blurRadius: 60,
                          offset: const Offset(0, 25),
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: cfg.spacingAboveTitle),

          // ── Title with slide + fade ──
          SlideTransition(
            position: titleSlide,
            child: FadeTransition(
              opacity: titleFade,
              child: Text(
                item.titleKey.tr(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontSize: cfg.titleSize,
                  fontWeight: FontWeight.w700,
                  height: isAr ? 1.5 : 1.35,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Description with delayed slide + fade ──
          SlideTransition(
            position: descSlide,
            child: FadeTransition(
              opacity: descFade,
              child: Text(
                item.descriptionKey.tr(),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontSize: cfg.descSize,
                  height: isAr ? 1.8 : 1.6,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
