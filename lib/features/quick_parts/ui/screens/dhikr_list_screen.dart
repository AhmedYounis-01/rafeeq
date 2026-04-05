import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import '../../data/models/dhikr_item.dart';
import '../../data/quick_parts_repository.dart';
import '../widgets/category_header.dart';
import '../widgets/dhikr_card.dart';

class DhikrListScreen extends StatefulWidget {
  final QuickPartType type;
  final String? selectedCategory;

  const DhikrListScreen({super.key, required this.type, this.selectedCategory});

  @override
  State<DhikrListScreen> createState() => _DhikrListScreenState();
}

class _DhikrListScreenState extends State<DhikrListScreen> {
  late Future<List<DhikrItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = QuickPartsRepository.instance.loadDhikr(widget.type);
  }

  String _getTitle() {
    if (widget.selectedCategory != null) return widget.selectedCategory!;
    switch (widget.type) {
      case QuickPartType.azkar:
        return 'quick_parts_screens.azkar_title'.tr();
      case QuickPartType.ruqiah:
        return 'quick_parts_screens.ruqiah_title'.tr();
      case QuickPartType.dua:
        return 'quick_parts_screens.dua_title'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isArabic = context.locale.languageCode == 'ar';
    final primary = AppColors.getPrimary(context);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _getTitle(),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: context.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            height: 1.h,
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.black.withAlpha(10),
          ),
        ),
      ),
      body: FutureBuilder<List<DhikrItem>>(
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

          var items = snapshot.data!;
          if (widget.selectedCategory != null) {
            items = items
                .where((i) => i.cat == widget.selectedCategory)
                .toList();
          }

          final grouped = QuickPartsRepository.instance.groupByCategory(
            items,
            isArabic,
          );

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
                  ...sectionItems.map(
                    (item) => DhikrCard(item: item, isArabic: isArabic),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
