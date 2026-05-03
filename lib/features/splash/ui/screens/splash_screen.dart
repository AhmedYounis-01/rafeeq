// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:rafeeq/core/gen/assets.gen.dart';
// import 'package:rafeeq/core/extensions/theme_extension.dart';
// import 'package:rafeeq/core/routing/app_router.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _runSplashSequence();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _precacheAssets(context);
//     });
//   }

//   void _precacheAssets(BuildContext context) {
//     precacheImage(Assets.images.rafeeqLogo.provider(), context);
//     precacheImage(Assets.images.best.provider(), context);
//     precacheImage(Assets.images.fajr.provider(), context);
//     precacheImage(Assets.images.duhr.provider(), context);
//   }

//   Future<void> _runSplashSequence() async {
//     await Future.delayed(const Duration(milliseconds: 1500));
//     if (mounted) {
//       context.go(AppRouter.home);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.theme.scaffoldBackgroundColor,
//       body: Center(
//         child: Assets.images.rafeeqLogo.image(
//           width: 300.w,
//           fit: BoxFit.contain,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/routing/app_router.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dotControllers;
  late final List<Animation<double>> _dotAnimations;

  static const _dotCount = 3;
  static const _dotDelay = Duration(milliseconds: 200);
  static const _animDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _initDotAnimations();
    _runSplashSequence();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAssets(context);
    });
  }

  void _initDotAnimations() {
    _dotControllers = List.generate(
      _dotCount,
      (i) => AnimationController(vsync: this, duration: _animDuration),
    );

    _dotAnimations = _dotControllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: -12,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _startDotsLoop();
  }

  void _startDotsLoop() async {
    while (mounted) {
      for (int i = 0; i < _dotCount; i++) {
        if (!mounted) return;
        _dotControllers[i].forward().then((_) {
          if (mounted) _dotControllers[i].reverse();
        });
        await Future.delayed(_dotDelay);
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  void _precacheAssets(BuildContext context) {
    precacheImage(Assets.images.rafeeqLogo.provider(), context);
    precacheImage(Assets.images.best.provider(), context);
    precacheImage(Assets.images.fajr.provider(), context);
    precacheImage(Assets.images.duhr.provider(), context);
  }

  Future<void> _runSplashSequence() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      context.go(AppRouter.home);
    }
  }

  @override
  void dispose() {
    for (final c in _dotControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Assets.images.rafeeqLogo.image(width: 300.w, fit: BoxFit.contain),
          const Spacer(),
          _DotsLoader(animations: _dotAnimations),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}

class _DotsLoader extends StatelessWidget {
  const _DotsLoader({required this.animations});

  final List<Animation<double>> animations;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(animations.length, (i) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: AnimatedBuilder(
            animation: animations[i],
            builder: (_, _) => Transform.translate(
              offset: Offset(0, animations[i].value),
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
