// ═══════════════════════════════════════════════════════════════════════════
// FILE: features/home/ui/widgets/quick_parts.dart + quick_parts_item.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/features/home/ui/widgets/quick_parts_item.dart';
import 'package:easy_localization/easy_localization.dart';
 
class QuickParts extends StatelessWidget {
  const QuickParts({super.key});
 
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final screenW  = MediaQuery.of(context).size.width;
    final screenH  = MediaQuery.of(context).size.height;
 
    final items = [
      (title: "home.quick_parts.azkar".tr(),  image: Assets.images.azkar.path),
      (title: "home.quick_parts.ruqiah".tr(), image: Assets.images.ruqiah.path),
      (title: "home.quick_parts.dua".tr(),    image: Assets.images.dua.path),
      (title: "home.quick_parts.seerah".tr(), image: Assets.images.seerah.path),
    ];
 
    // ارتفاع كل item نسبة من الشاشة
    final itemH = isTablet ? screenH * 0.24 : 140.h.toDouble();
    // gap بين العناصر نسبة من العرض
    final gap   = isTablet ? screenW * 0.02 : 12.w.toDouble();
 
    final hPad  = isTablet ? screenW * 0.02 : 16.w.toDouble();
 
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        children: [
          Row(children: [
            QuickPartsItem(title: items[0].title, image: items[0].image, height: itemH),
            SizedBox(width: gap),
            QuickPartsItem(title: items[1].title, image: items[1].image, height: itemH),
          ]),
          SizedBox(height: gap),
          Row(children: [
            QuickPartsItem(title: items[2].title, image: items[2].image, height: itemH),
            SizedBox(width: gap),
            QuickPartsItem(title: items[3].title, image: items[3].image, height: itemH),
          ]),
        ],
      ),
    );
  }
}
 
