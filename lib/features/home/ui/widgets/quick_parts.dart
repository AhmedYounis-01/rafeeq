// quick_parts.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/core/routing/app_router.dart';
import 'package:rafeeq/features/home/ui/widgets/quick_parts_item.dart';

class QuickParts extends StatelessWidget {
  const QuickParts({super.key});

  @override
  Widget build(BuildContext context) {
    final side = MediaQuery.of(context).size.shortestSide;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final isTablet = side >= 600;

    final itemH = isTablet ? screenH * 0.24 : (side * 0.38).clamp(120.0, 170.0);
    final gap = (screenW * 0.03).clamp(8.0, 20.0);
    final hPad = (screenW * (isTablet ? 0.04 : 0.04)).clamp(12.0, 28.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        children: [
          // ✅ Row يعكس ترتيب العناصر تلقائياً مع Directionality
          Row(
            children: [
              QuickPartsItem(
                titleKey: "home.quick_parts.azkar",
                image: Assets.images.azkar.path,
                height: itemH,
                onTap: () => context.push(AppRouter.azkar),
              ),
              SizedBox(width: gap),
              QuickPartsItem(
                titleKey: "home.quick_parts.ruqiah",
                image: Assets.images.ruqiah.path,
                height: itemH,
                onTap: () => context.push(AppRouter.ruqiah),
              ),
            ],
          ),
          SizedBox(height: gap),
          Row(
            children: [
              QuickPartsItem(
                titleKey: "home.quick_parts.dua",
                image: Assets.images.dua.path,
                height: itemH,
                onTap: () => context.push(AppRouter.dua),
              ),
              SizedBox(width: gap),
              QuickPartsItem(
                titleKey: "home.quick_parts.seerah",
                image: Assets.images.seerah.path,
                height: itemH,
                onTap: () => context.push(AppRouter.seerah),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
