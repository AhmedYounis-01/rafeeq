import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rafeeq/core/cache/storage_manager.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../widgets/splash_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _runSplashSequence();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 20,
      ),
    ]).animate(_mainController);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_mainController);

    _slideAnimation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
  }

  Future<void> _runSplashSequence() async {
    try {
      await _mainController.forward();
    } catch (e) {
      // Handle dispose
    }

    if (!mounted) return;
    final hasSeenOnboarding = StorageManager.instance.hasSeenOnboarding();
    if (hasSeenOnboarding) {
      context.go(AppRouter.home);
    } else {
      context.go(AppRouter.onboarding);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = SplashConfig(context);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: context.scaffoldBackgroundColor,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: SplashLogo(
                      size: config.logoSize,
                      radius: config.logoRadius,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SplashConfig {
  final double shortestSide;
  SplashConfig(BuildContext context)
    : shortestSide = MediaQuery.of(context).size.shortestSide;

  double get logoSize => (shortestSide * 0.7).clamp(160.0, 320.0);
  double get spacing => (shortestSide * 0.08).clamp(24.0, 48.0);
  double get fontSize => (shortestSide * 0.1).clamp(32.0, 64.0);
  double get logoRadius => (shortestSide * 0.08).clamp(28.0, 48.0);
}
