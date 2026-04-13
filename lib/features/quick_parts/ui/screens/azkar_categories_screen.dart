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

    // الأذكار اليومية الأساسية (14 عنصر)
    final azkarCategories = [
      {
        'key': 'quick_parts_screens.azkar.morning',
        'ar': 'أذكار الصباح',
        'icon': Icons.wb_sunny_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.evening',
        'ar': 'أذكار المساء',
        'icon': Icons.nightlight_round,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.after_prayer',
        'ar': 'أذكار بعد الصلاة',
        'icon': Icons.mosque_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.sleep',
        'ar': 'أذكار النوم',
        'icon': Icons.bedtime_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.waking_up',
        'ar': 'أذكار الاستيقاظ',
        'icon': Icons.wb_twilight_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.entering_home',
        'ar': 'أذكار دخول المنزل',
        'icon': Icons.home_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.leaving_home',
        'ar': 'أذكار الخروج من المنزل',
        'icon': Icons.door_front_door_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.travel',
        'ar': 'أذكار السفر',
        'icon': Icons.flight_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.wudu',
        'ar': 'أذكار الوضوء',
        'icon': Icons.water_drop_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.adhan',
        'ar': 'أذكار سماع الأذان',
        'icon': Icons.notifications_active_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.mosque',
        'ar': 'أذكار المسجد',
        'icon': Icons.account_balance_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.friday',
        'ar': 'أذكار يوم الجمعة',
        'icon': Icons.event_available_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.protection',
        'ar': 'أذكار التحصين',
        'icon': Icons.verified_user_rounded,
        'type': 'azkar',
      },
      {
        'key': 'quick_parts_screens.azkar.food',
        'ar': 'أذكار الطعام والشراب',
        'icon': Icons.restaurant_rounded,
        'type': 'azkar',
      },
    ];

    // الأدعية المأثورة (13 عنصر)
    final duaCategories = [
      {
        'key': 'quick_parts_screens.dua.quran_completion',
        'ar': 'دعاء ختم القرآن',
        'icon': Icons.auto_stories_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.istikhara',
        'ar': 'دعاء الاستخارة',
        'icon': Icons.help_outline_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.sustenance',
        'ar': 'أدعية الرزق والبركة',
        'icon': Icons.payments_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.study',
        'ar': 'أدعية الدراسة والتوفيق',
        'icon': Icons.school_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.parents',
        'ar': 'دعاء للوالدين',
        'icon': Icons.favorite_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.distress',
        'ar': 'دعاء الكرب والهم',
        'icon': Icons.psychology_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.fear',
        'ar': 'دعاء الخوف والقلق',
        'icon': Icons.security_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.sickness',
        'ar': 'دعاء المرض والشفاء',
        'icon': Icons.health_and_safety_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.tranquility',
        'ar': 'دعاء السكينة وراحة البال',
        'icon': Icons.spa_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.forgiveness',
        'ar': 'دعاء الاستغفار والتوبة',
        'icon': Icons.clean_hands_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.rain',
        'ar': 'دعاء المطر',
        'icon': Icons.umbrella_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.children',
        'ar': 'دعاء للأولاد والذرية الصالحة',
        'icon': Icons.child_care_rounded,
        'type': 'dua',
      },
      {
        'key': 'quick_parts_screens.dua.hajj',
        'ar': 'أدعية الحج والعمرة',
        'icon': Icons.landscape_rounded,
        'type': 'dua',
      },
    ];

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            centerTitle: true,
            backgroundColor: context.colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20.sp,
                color: context.colorScheme.onSurface,
              ),
            ),
            title: Text(
              'quick_parts_screens.azkar_title'.tr(),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
            ),
          ),

          // ─── Azkar Section ───
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'quick_parts_screens.headers.azkar'.tr(),
              primary: primary,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final catMap = azkarCategories[index];
                return _CategoryListCard(
                  title: (catMap['key'] as String).tr(),
                  icon: catMap['icon'] as IconData,
                  primary: primary,
                  onTap: () => _navigateToDhikr(context, catMap),
                );
              }, childCount: azkarCategories.length),
            ),
          ),

          // ─── Dua Section ───
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'quick_parts_screens.headers.dua'.tr(),
              primary: primary,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 40.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final catMap = duaCategories[index];
                return _CategoryListCard(
                  title: (catMap['key'] as String).tr(),
                  icon: catMap['icon'] as IconData,
                  primary: primary,
                  onTap: () => _navigateToDhikr(context, catMap),
                );
              }, childCount: duaCategories.length),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDhikr(BuildContext context, Map<String, dynamic> catMap) {
    final type = catMap['type'] == 'dua'
        ? QuickPartType.dua
        : QuickPartType.azkar;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DhikrListScreen(
          type: type,
          selectedCategory: catMap['ar'] as String,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color primary;

  const _SectionHeader({required this.title, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color primary;
  final VoidCallback onTap;

  const _CategoryListCard({
    required this.title,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(15) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
          border: Border.all(
            color: primary.withAlpha(isDark ? 50 : 30),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: primary.withAlpha(20),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: primary, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withAlpha(230)
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: primary.withAlpha(120),
            ),
          ],
        ),
      ),
    );
  }
}
