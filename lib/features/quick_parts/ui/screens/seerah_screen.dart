import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final primary = AppColors.getPrimary(context);
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: FutureBuilder<List<SeerahItem>>(
        key: ValueKey('seerah_${context.locale.languageCode}'),
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

          final items = snapshot.data!;
          final grouped = QuickPartsRepository.instance.groupSeerahByCategory(
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
                  'quick_parts_screens.seerah_title'.tr(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),

              // ── Spiritual Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "وَإِنَّكَ لَعَلَىٰ خُلُقٍ عَظِيمٍ",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 22.sp,
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Divider(
                        color: primary.withAlpha(40),
                        indent: 80.w,
                        endIndent: 80.w,
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),

              // ── Seerah List ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 40.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, sectionIndex) {
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
                            isFirst: index == 0,
                            isLast: index == sectionItems.length - 1,
                          );
                        }),
                        SizedBox(height: 12.h),
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
