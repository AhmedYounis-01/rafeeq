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

    // EXACT matching categories with JSON
    final categories = [
      // ─── الأذكار اليومية ───
      {
        'key': 'quick_parts_screens.azkar.morning',
        'ar': 'أذكار الصباح',
        'icon': Icons.wb_sunny_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.evening',
        'ar': 'أذكار المساء',
        'icon': Icons.nightlight_round,
      },
      {
        'key': 'quick_parts_screens.azkar.after_prayer',
        'ar': 'أذكار بعد الصلاة',
        'icon': Icons.mosque_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.sleep',
        'ar': 'أذكار النوم',
        'icon': Icons.bedtime_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.waking_up',
        'ar': 'أذكار الاستيقاظ',
        'icon': Icons.wb_twilight_rounded,
      },

      // ─── أذكار البيت والتنقل ───
      {
        'key': 'quick_parts_screens.azkar.entering_home',
        'ar': 'أذكار دخول المنزل',
        'icon': Icons.home_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.leaving_home',
        'ar': 'أذكار الخروج من المنزل',
        'icon': Icons.door_front_door_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.travel',
        'ar': 'أذكار السفر',
        'icon': Icons.flight_rounded,
      },

      // ─── أذكار العبادات ───
      {
        'key': 'quick_parts_screens.azkar.wudu',
        'ar': 'أذكار الوضوء',
        'icon': Icons.water_drop_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.adhan',
        'ar': 'أذكار الأذان',
        'icon': Icons.notifications_active_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.mosque',
        'ar': 'أذكار المسجد',
        'icon': Icons.account_balance_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.friday',
        'ar': 'أذكار يوم الجمعة',
        'icon': Icons.event_available_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.hajj',
        'ar': 'أذكار الحج والعمرة',
        'icon': Icons.landscape_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.quran_completion',
        'ar': 'دعاء ختم القرآن',
        'icon': Icons.auto_stories_rounded,
      },

      // ─── أذكار المواقف اليومية ───
      {
        'key': 'quick_parts_screens.azkar.food',
        'ar': 'أذكار الطعام',
        'icon': Icons.restaurant_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.market',
        'ar': 'أذكار السوق',
        'icon': Icons.shopping_cart_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.work',
        'ar': 'أذكار العمل',
        'icon': Icons.work_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.meeting_people',
        'ar': 'أذكار لقاء الناس',
        'icon': Icons.groups_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.rain',
        'ar': 'أذكار المطر',
        'icon': Icons.umbrella_rounded,
      },

      // ─── أذكار الشدة والعافية ───
      {
        'key': 'quick_parts_screens.azkar.fear',
        'ar': 'أذكار الخوف والقلق',
        'icon': Icons.security_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.distress',
        'ar': 'أذكار الكرب والهم',
        'icon': Icons.psychology_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.sickness',
        'ar': 'أذكار المرض',
        'icon': Icons.health_and_safety_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.tranquility',
        'ar': 'أذكار السكينة والراحة',
        'icon': Icons.spa_rounded,
      },

      // ─── التوبة والتحصين ───
      {
        'key': 'quick_parts_screens.azkar.repentance',
        'ar': 'أذكار التوبة والاستغفار',
        'icon': Icons.clean_hands_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.protection',
        'ar': 'أذكار التحصين',
        'icon': Icons.verified_user_rounded,
      },

      // ─── الرزق والعلم ───
      {
        'key': 'quick_parts_screens.azkar.sustenance',
        'ar': 'أذكار الرزق',
        'icon': Icons.payments_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.study',
        'ar': 'أذكار الدراسة والامتحان',
        'icon': Icons.school_rounded,
      },

      // ─── للأطفال والقرارات ───
      {
        'key': 'quick_parts_screens.azkar.children_sleep',
        'ar': 'أذكار النوم للأطفال',
        'icon': Icons.child_care_rounded,
      },
      {
        'key': 'quick_parts_screens.azkar.istikhara',
        'ar': 'أذكار الاستخارة',
        'icon': Icons.help_outline_rounded,
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
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 40.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final catMap = categories[index];
                final title = (catMap['key'] as String).tr();
                final arName = catMap['ar'] as String;
                final icon = catMap['icon'] as IconData;

                return _CategoryListCard(
                  title: title,
                  icon: icon,
                  primary: primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DhikrListScreen(
                          type: QuickPartType.azkar,
                          selectedCategory: arName,
                        ),
                      ),
                    );
                  },
                );
              }, childCount: categories.length),
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
    final isAr = context.locale.languageCode == 'ar';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
          border: Border.all(
            color: primary.withAlpha(isDark ? 40 : 25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12.r),
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
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: primary.withAlpha(100),
            ),
          ],
        ),
      ),
    );
  }
}
