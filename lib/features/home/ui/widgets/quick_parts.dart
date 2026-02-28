import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/features/home/ui/widgets/quick_parts_item.dart';
import 'package:easy_localization/easy_localization.dart';

class QuickParts extends StatelessWidget {
  const QuickParts({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Row 1
          Row(
            children: [
              QuickPartsItem(
                title: "home.quick_parts.azkar".tr(context: context),
                image: Assets.images.azkar.path,
              ),
              SizedBox(width: 12.w),
              QuickPartsItem(
                title: "home.quick_parts.ruqiah".tr(context: context),
                image: Assets.images.ruqiah.path,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Row 2
          Row(
            children: [
              QuickPartsItem(
                title: "home.quick_parts.dua".tr(context: context),
                image: Assets.images.dua.path,
              ),
              SizedBox(width: 12.w),
              QuickPartsItem(
                title: "home.quick_parts.seerah".tr(context: context),
                image: Assets.images.seerah.path,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
