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
    if (widget.selectedCategory != null) {
      // If we have a category, we might want to localize it if it's a key,
      // but here selectedCategory is usually the Arabic name for filtering.
      // So we return it directly.
      return widget.selectedCategory!;
    }
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
    final primary = AppColors.getPrimary(context);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: FutureBuilder<List<DhikrItem>>(
        key: ValueKey('dhikr_${widget.type}_${context.locale.languageCode}'),
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primary, strokeWidth: 3),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var items = snapshot.data!;
          if (widget.selectedCategory != null) {
            // Aggressive normalization for robust matching (ignores all spaces/tabs)
            final normalizedSelected = widget.selectedCategory!.replaceAll(
              RegExp(r'\s+'),
              '',
            );
            items = items
                .where(
                  (i) =>
                      i.cat.replaceAll(RegExp(r'\s+'), '') ==
                      normalizedSelected,
                )
                .toList();
          }

          final isArabic = context.locale.languageCode == 'ar';
          final grouped = QuickPartsRepository.instance.groupByCategory(
            items,
            isArabic,
          );

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Sliver AppBar ──
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
                  _getTitle(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),

              // ── Dhikr List ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, sectionIndex) {
                    final category = grouped.keys.elementAt(sectionIndex);
                    final sectionItems = grouped[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.selectedCategory == null)
                          CategoryHeader(
                            title: category,
                            itemCount: sectionItems.length,
                          ),
                        ...sectionItems.map((item) => DhikrCard(item: item)),
                      ],
                    );
                  }, childCount: grouped.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
