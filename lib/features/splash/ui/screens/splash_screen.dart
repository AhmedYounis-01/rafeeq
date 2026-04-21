import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/routing/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _runSplashSequence();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAssets(context);
    });
  }

  void _precacheAssets(BuildContext context) {
    precacheImage(Assets.images.rafeeqLogo.provider(), context);
    precacheImage(Assets.images.best.provider(), context);
    precacheImage(Assets.images.fajr.provider(), context);
    precacheImage(Assets.images.duhr.provider(), context);
  }

  Future<void> _runSplashSequence() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Center(
        child: Assets.images.rafeeqLogo.image(width: 300.w, fit: BoxFit.contain),
      ),
    );
  }
}
