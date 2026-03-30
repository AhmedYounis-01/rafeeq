import 'package:flutter/material.dart';
import '../../../../core/gen/assets.gen.dart';

class SplashLogo extends StatelessWidget {
  final double size;
  final double radius;

  const SplashLogo({super.key, required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Assets.images.rafeeqLogo.image(fit: BoxFit.cover),
      ),
    );
  }
}
