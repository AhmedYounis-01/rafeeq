import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/quick_parts/data/quick_parts_repository.dart';
import 'dhikr_list_screen.dart';

class AzkarCategoriesScreen extends StatelessWidget {
  const AzkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary = AppColors.getPrimary(context);

    final categories = [
      "أذكار الصباح",
      "أذكار المساء",
      "أذكار بعد الصلاة",
      "أذكار النوم",
      "أذكار الاستيقاظ",
      "أذكار دخول المنزل",
      "أذكار الخروج من المنزل",
      "أذكار الطعام",
      "أذكار الوضوء",
      "أذكار الأذان",
      "أذكار المسجد",
      "أذكار السفر",
      "أذكار المطر",
      "أذكار الخوف والقلق",
      "أذكار المرض",
      "أذكار الكرب والهم",
      "أذكار التوبة والاستغفار",
      "أذكار الرزق",
      "أذكار العمل",
      "أذكار السوق",
      "أذكار لقاء الناس",
      "أذكار النوم للأطفال",
      "أذكار التحصين",
      "أذكار يوم الجمعة",
      "أذكار الحج والعمرة",
      "دعاء ختم القرآن",
    ];

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'quick_parts_screens.azkar_title'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _CategoryTile(
            title: cat,
            primary: primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DhikrListScreen(
                    type: QuickPartType.azkar,
                    selectedCategory: cat,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final Color primary;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.title,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
          border: Border.all(color: primary.withAlpha(30), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book_rounded, color: primary, size: 20.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
