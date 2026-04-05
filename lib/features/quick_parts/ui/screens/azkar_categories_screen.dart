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
    final primary = AppColors.getPrimary(context);

    final categories = [
      {'key': 'quick_parts_screens.azkar.morning', 'ar': 'أذكار الصباح'},
      {'key': 'quick_parts_screens.azkar.evening', 'ar': 'أذكار المساء'},
      {
        'key': 'quick_parts_screens.azkar.after_prayer',
        'ar': 'أذكار بعد الصلاة',
      },
      {'key': 'quick_parts_screens.azkar.sleep', 'ar': 'أذكار النوم'},
      {'key': 'quick_parts_screens.azkar.waking_up', 'ar': 'أذكار الاستيقاظ'},
      {
        'key': 'quick_parts_screens.azkar.entering_home',
        'ar': 'أذكار دخول المنزل',
      },
      {
        'key': 'quick_parts_screens.azkar.leaving_home',
        'ar': 'أذكار الخروج من المنزل',
      },
      {'key': 'quick_parts_screens.azkar.food', 'ar': 'أذكار الطعام'},
      {'key': 'quick_parts_screens.azkar.wudu', 'ar': 'أذكار الوضوء'},
      {'key': 'quick_parts_screens.azkar.adhan', 'ar': 'أذكار الأذان'},
      {'key': 'quick_parts_screens.azkar.mosque', 'ar': 'أذكار المسجد'},
      {'key': 'quick_parts_screens.azkar.travel', 'ar': 'أذكار السفر'},
      {'key': 'quick_parts_screens.azkar.rain', 'ar': 'أذكار المطر'},
      {'key': 'quick_parts_screens.azkar.fear', 'ar': 'أذكار الخوف والقلق'},
      {'key': 'quick_parts_screens.azkar.sickness', 'ar': 'أذكار المرض'},
      {'key': 'quick_parts_screens.azkar.distress', 'ar': 'أذكار الكرب والهم'},
      {
        'key': 'quick_parts_screens.azkar.repentance',
        'ar': 'أذكار التوبة والاستغفار',
      },
      {'key': 'quick_parts_screens.azkar.sustenance', 'ar': 'أذكار الرزق'},
      {'key': 'quick_parts_screens.azkar.work', 'ar': 'أذكار العمل'},
      {'key': 'quick_parts_screens.azkar.market', 'ar': 'أذكار السوق'},
      {
        'key': 'quick_parts_screens.azkar.meeting_people',
        'ar': 'أذكار لقاء الناس',
      },
      {
        'key': 'quick_parts_screens.azkar.children_sleep',
        'ar': 'أذكار النوم للأطفال',
      },
      {'key': 'quick_parts_screens.azkar.protection', 'ar': 'أذكار التحصين'},
      {'key': 'quick_parts_screens.azkar.friday', 'ar': 'أذكار يوم الجمعة'},
      {'key': 'quick_parts_screens.azkar.hajj', 'ar': 'أذكار الحج والعمرة'},
      {
        'key': 'quick_parts_screens.azkar.quran_completion',
        'ar': 'دعاء ختم القرآن',
      },
    ];

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'quick_parts_screens.azkar_title'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurface,
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
          final catMap = categories[index];
          final catTitle = catMap['key']!.tr();
          final catAr = catMap['ar']!;
          return _CategoryTile(
            title: catTitle,
            primary: primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DhikrListScreen(
                    type: QuickPartType.azkar,
                    selectedCategory: catAr,
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
