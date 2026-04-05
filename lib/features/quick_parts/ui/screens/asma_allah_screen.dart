import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/quick_parts/data/models/asma_allah_item.dart';
import 'package:rafeeq/features/quick_parts/data/quick_parts_repository.dart';
import 'package:google_fonts/google_fonts.dart';

class AsmaAllahScreen extends StatefulWidget {
  const AsmaAllahScreen({super.key});

  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen> {
  late Future<List<AsmaAllahItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = QuickPartsRepository.instance.loadAsmaAllah();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.getPrimary(context);
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: FutureBuilder<List<AsmaAllahItem>>(
          key: ValueKey('asma_${context.locale.languageCode}'),
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primary));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final items = snapshot.data!;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Sliver AppBar ──
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: false,
                  centerTitle: true,
                  backgroundColor: context.colorScheme.surface,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: const SizedBox.shrink(),
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20.sp,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ],
                  title: Text(
                    'quick_parts_screens.dua_title'.tr(),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),

                // ── Header Verse ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'quick_parts_screens.dua.verse'.tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: 19.sp,
                            color: context.colorScheme.onSurface.withAlpha(200),
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 25.h),
                      ],
                    ),
                  ),
                ),

                // ── Grid of Names ──
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 40.h),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _AsmaCard(item: items[index], primary: primary);
                    }, childCount: items.length),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AsmaCard extends StatelessWidget {
  final AsmaAllahItem item;
  final Color primary;

  const _AsmaCard({required this.item, required this.primary});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isArabic ? item.ar : item.en,
              style: GoogleFonts.amiri(
                fontSize: isArabic ? 23.sp : 18.sp,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              isArabic ? item.en : item.ar,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87.withAlpha(150),
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder: (context) => _AsmaDetailsSheet(item: item),
    );
  }
}

class _AsmaDetailsSheet extends StatelessWidget {
  final AsmaAllahItem item;

  const _AsmaDetailsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 45.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(80),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 40.h),

          // Name Display Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 25.h),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Text(
                  isArabic ? item.ar : item.en,
                  style: GoogleFonts.amiri(
                    fontSize: isArabic ? 48.sp : 36.sp,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                Text(
                  isArabic ? item.en : item.ar,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 35.h),

          // Description Text
          Text(
            isArabic ? item.descriptionAr : item.descriptionEn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              height: 1.6,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface.withAlpha(200),
            ),
          ),

          SizedBox(height: 45.h),

          // Action Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF006D5B), // Premium Green
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF006D5B).withAlpha(80),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                  const Spacer(),
                  Text(
                    isArabic ? "إغلاق" : "Close",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 20.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
