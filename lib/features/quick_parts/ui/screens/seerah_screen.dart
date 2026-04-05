import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import '../../data/models/seerah_item.dart';
import '../../data/quick_parts_repository.dart';
import '../widgets/category_header.dart';
import '../widgets/seerah_card.dart';

class SeerahScreen extends StatefulWidget {
  const SeerahScreen({super.key});

  @override
  State<SeerahScreen> createState() => _SeerahScreenState();
}

class _SeerahScreenState extends State<SeerahScreen> {
  late Future<List<SeerahItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = QuickPartsRepository.instance.loadSeerah();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isArabic = context.locale.languageCode == 'ar';
    final primary = AppColors.getPrimary(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: Text(
          'quick_parts_screens.seerah_title'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              children: [
                Text(
                  "وَإِنَّكَ لَعَلَىٰ خُلُقٍ عَظِيمٍ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontStyle: FontStyle.italic,
                    color: primary.withAlpha(200),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SeerahItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: primary,
                      strokeWidth: 2.5,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48.sp,
                          color: Colors.red.withAlpha(180),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'common.error'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? Colors.white.withAlpha(160)
                                : Colors.black.withAlpha(120),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.red.withAlpha(180),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!;
                final grouped = QuickPartsRepository.instance
                    .groupSeerahByCategory(items, isArabic);

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                  itemCount: grouped.length,
                  itemBuilder: (context, sectionIndex) {
                    final category = grouped.keys.elementAt(sectionIndex);
                    final sectionItems = grouped[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryHeader(
                          title: category,
                          itemCount: sectionItems.length,
                        ),
                        ...sectionItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return SeerahCard(
                            item: item,
                            isArabic: isArabic,
                            isFirst: index == 0,
                            isLast: index == sectionItems.length - 1,
                          );
                        }),
                        SizedBox(height: 8.h),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
