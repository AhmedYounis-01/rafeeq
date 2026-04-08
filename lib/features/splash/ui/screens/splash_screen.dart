import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import '../widgets/splash_logo.dart';

class SplashOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashOverlay({super.key, required this.onComplete});

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay>
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

    // Remove native splash after a small delay to ensure Flutter frame is fully ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAssets(context);
      Future.delayed(const Duration(milliseconds: 100), () {
        FlutterNativeSplash.remove();
      });
    });
  }

  void _precacheAssets(BuildContext context) {
    // 1. Pre-cache large background images
    precacheImage(Assets.images.best.provider(), context);
    precacheImage(Assets.images.fajr.provider(), context);
    precacheImage(Assets.images.duhr.provider(), context);
    precacheImage(Assets.images.asr.provider(), context);
    precacheImage(Assets.images.maghrb.provider(), context);
    precacheImage(Assets.images.isha.provider(), context);
    precacheImage(Assets.images.azkar.provider(), context);
    precacheImage(Assets.images.ruqiah.provider(), context);
    precacheImage(Assets.images.dua.provider(), context);
    precacheImage(Assets.images.seerah.provider(), context);
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 75),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
    ]).animate(_mainController);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 100,
      ),
    ]).animate(_mainController);

    _slideAnimation = Tween<double>(begin: 0.0, end: -15.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  Future<void> _runSplashSequence() async {
    try {
      await _mainController.forward();
    } catch (e) {
      // Handle dispose
    }

    widget.onComplete();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1412) : Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return Center(
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: const SplashLogo(size: 250, radius: 32),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SplashConfig {
  final double shortestSide;
  SplashConfig(BuildContext context)
    : shortestSide = MediaQuery.sizeOf(context).shortestSide;

  double get logoSize => (shortestSide * 0.7).clamp(160.0, 320.0);
  double get spacing => (shortestSide * 0.08).clamp(24.0, 48.0);
  double get fontSize => (shortestSide * 0.1).clamp(32.0, 64.0);
  double get logoRadius => (shortestSide * 0.08).clamp(28.0, 48.0);
}
