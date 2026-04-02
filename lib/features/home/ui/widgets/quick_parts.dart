// quick_parts.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/core/routing/app_router.dart';
import 'package:rafeeq/features/home/ui/widgets/quick_parts_item.dart';
import 'package:easy_localization/easy_localization.dart';

class QuickParts extends StatelessWidget {
  const QuickParts({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ يسجل dependency على اللغة عشان يعمل rebuild فوراً
    final locale = context.locale;
    final side = MediaQuery.of(context).size.shortestSide;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final isTablet = side >= 600;

    final items = [
      (
        title: "home.quick_parts.azkar".tr(),
        image: Assets.images.azkar.path,
        route: AppRouter.azkar,
      ),
      (
        title: "home.quick_parts.ruqiah".tr(),
        image: Assets.images.ruqiah.path,
        route: AppRouter.ruqiah,
      ),
      (
        title: "home.quick_parts.dua".tr(),
        image: Assets.images.dua.path,
        route: AppRouter.dua,
      ),
      (
        title: "home.quick_parts.seerah".tr(),
        image: Assets.images.seerah.path,
        route: AppRouter.seerah,
      ),
    ];

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
                title: items[0].title,
                image: items[0].image,
                height: itemH,
                onTap: () => context.push(items[0].route),
              ),
              SizedBox(width: gap),
              QuickPartsItem(
                title: items[1].title,
                image: items[1].image,
                height: itemH,
                onTap: () => context.push(items[1].route),
              ),
            ],
          ),
          SizedBox(height: gap),
          Row(
            children: [
              QuickPartsItem(
                title: items[2].title,
                image: items[2].image,
                height: itemH,
                onTap: () => context.push(items[2].route),
              ),
              SizedBox(width: gap),
              QuickPartsItem(
                title: items[3].title,
                image: items[3].image,
                height: itemH,
                onTap: () => context.push(items[3].route),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
