import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:rafeeq/core/cache/storage_manager.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/core/routing/app_router.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/onboarding/data/models/onboarding_item.dart';
import 'package:rafeeq/features/onboarding/ui/widgets/onboarding_page_item.dart';
import 'package:rafeeq/features/onboarding/ui/widgets/onboarding_navigation_buttons.dart';

// ─── Responsive Config ────────────────────────────────────────────────────────
class _Cfg {
  final double side, width, height;
  _Cfg(BuildContext ctx)
    : side = MediaQuery.sizeOf(ctx).shortestSide,
      width = MediaQuery.sizeOf(ctx).width,
      height = MediaQuery.sizeOf(ctx).height;

  bool get isTablet => side >= 600;

  double get hPad => (side * 0.06).clamp(24.0, 48.0);
  double get indicatorSpacing => (side * 0.08).clamp(32.0, 48.0);
  double get bottomSpacing => (side * 0.06).clamp(24.0, 36.0);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      titleKey: 'onboarding.page1_title',
      descriptionKey: 'onboarding.page1_desc',
      imagePath: Assets.images.onboarding1.path,
    ),
    OnboardingItem(
      titleKey: 'onboarding.page2_title',
      descriptionKey: 'onboarding.page2_desc',
      imagePath: Assets.images.onboarding2.path,
    ),
    OnboardingItem(
      titleKey: 'onboarding.page3_title',
      descriptionKey: 'onboarding.page3_desc',
      imagePath: Assets.images.onboarding3.path,
    ),
  ];

  final PageController pageController = PageController();
  int _currentPage = 0;

  // ── Entrance animation (single controller, staggered intervals) ──
  late AnimationController _entranceController;
  late Animation<double> _imageScale;
  late Animation<double> _imageFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _descSlide;
  late Animation<double> _descFade;
  late Animation<double> _indicatorFade;
  late Animation<double> _buttonSlide;
  late Animation<double> _buttonFade;

  // ── Continuous subtle float for the image ──
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _setupEntranceAnimations();
    _setupFloatAnimation();
    _entranceController.forward();
  }

  void _setupEntranceAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Image: 0% → 50%
    _imageScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack),
      ),
    );
    _imageFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
    );

    // Title: 20% → 60%
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.20, 0.60, curve: Curves.easeOutCubic),
          ),
        );
    _titleFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.20, 0.55, curve: Curves.easeOut),
    );

    // Description: 35% → 70%
    _descSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.35, 0.70, curve: Curves.easeOutCubic),
          ),
        );
    _descFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
    );

    // Indicator: 50% → 80%
    _indicatorFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.50, 0.80, curve: Curves.easeOut),
    );

    // Buttons: 60% → 100%
    _buttonSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _buttonFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
    );
  }

  void _setupFloatAnimation() {
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _floatController.repeat(reverse: true);
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _entranceController.reset();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    pageController.dispose();
    super.dispose();
  }

  void _submitOnboarding() {
    StorageManager.instance.setHasSeenOnboarding();
    context.go(AppRouter.home);
    Logger().i('Onboarding Done');
  }

  bool get _isLastPage => _currentPage == onboardingItems.length - 1;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cfg = _Cfg(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark.withAlpha(240),
                  ]
                : [AppColors.backgroundLight, const Color(0xFFF5F9F7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Page content ──
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: onboardingItems.length,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return OnboardingPageItem(
                      item: onboardingItems[index],
                      imageScale: _imageScale,
                      imageFade: _imageFade,
                      floatAnimation: _floatAnimation,
                      titleSlide: _titleSlide,
                      titleFade: _titleFade,
                      descSlide: _descSlide,
                      descFade: _descFade,
                    );
                  },
                ),
              ),

              // ── Dot indicator ──
              FadeTransition(
                opacity: _indicatorFade,
                child: _PremiumDotIndicator(
                  currentPage: _currentPage,
                  itemCount: onboardingItems.length,
                  cfg: cfg,
                ),
              ),

              SizedBox(height: cfg.indicatorSpacing),

              // ── Navigation buttons ──
              AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _buttonSlide.value),
                    child: Opacity(opacity: _buttonFade.value, child: child),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: cfg.hPad),
                  child: OnboardingNavigationButtons(
                    isLastPage: _isLastPage,
                    onSkip: _submitOnboarding,
                    onNext: () {
                      if (_isLastPage) {
                        _submitOnboarding();
                      } else {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                  ),
                ),
              ),

              SizedBox(height: cfg.bottomSpacing),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Premium Dot Indicator with glow & expand effect
// ─────────────────────────────────────────────────
class _PremiumDotIndicator extends StatelessWidget {
  final int currentPage;
  final int itemCount;
  final _Cfg cfg;

  const _PremiumDotIndicator({
    required this.currentPage,
    required this.itemCount,
    required this.cfg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? AppColors.secondary
                : (context.isDarkMode
                      ? Colors.white.withAlpha(40)
                      : Colors.black.withAlpha(30)),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withAlpha(100),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}
