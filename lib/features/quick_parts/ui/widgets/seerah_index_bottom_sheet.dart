import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/quick_parts/data/models/seerah_item.dart';
import 'package:rafeeq/features/quick_parts/logic/seerah_cubit.dart';

class SeerahIndexBottomSheet extends StatefulWidget {
  final SeerahCubit cubit;
  final List<SeerahItem> items;
  final int currentIndex;
  final void Function(int index) onTopicSelected;

  const SeerahIndexBottomSheet({
    super.key,
    required this.cubit,
    required this.items,
    required this.currentIndex,
    required this.onTopicSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required SeerahCubit cubit,
    required List<SeerahItem> items,
    required int currentIndex,
    required void Function(int index) onTopicSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SeerahIndexBottomSheet(
        cubit: cubit,
        items: items,
        currentIndex: currentIndex,
        onTopicSelected: onTopicSelected,
      ),
    );
  }

  @override
  State<SeerahIndexBottomSheet> createState() => _SeerahIndexBottomSheetState();
}

class _SeerahIndexBottomSheetState extends State<SeerahIndexBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final list = <String>[];
    for (final item in widget.items) {
      if (item.category.isNotEmpty && !list.contains(item.category)) {
        list.add(item.category);
      }
    }
    return list;
  }

  List<MapEntry<int, SeerahItem>> get _filteredEntries {
    final query = _searchQuery.trim().toLowerCase();
    final results = <MapEntry<int, SeerahItem>>[];

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final matchesCategory = _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          item.category == _selectedCategory;

      if (!matchesCategory) continue;

      if (query.isEmpty) {
        results.add(MapEntry(i, item));
      } else {
        final titleMatch = item.title.toLowerCase().contains(query);
        final contentMatch = item.content.toLowerCase().contains(query);
        if (titleMatch || contentMatch) {
          results.add(MapEntry(i, item));
        }
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.getPrimary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.bottomSheetDark
        : AppColors.bottomSheetLight;
    final cardBg = isDark
        ? const Color(0xFF262520)
        : Colors.white;
    final textColor = context.colorScheme.onSurface;

    final filtered = _filteredEntries;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 48.w,
            height: 4.5.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فهرس السيرة النبوية',
                      style: GoogleFonts.amiri(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${widget.items.length} موضوعاً مرتبة زمنياً',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: textColor.withValues(alpha: 0.7),
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 14.sp, color: textColor),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث في موضوعات وأحداث السيرة...',
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: textColor.withValues(alpha: 0.45),
                  ),
                  hintTextDirection: TextDirection.rtl,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: primary,
                    size: 20.sp,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            size: 18.sp,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'الكل (${widget.items.length})',
                  isSelected: _selectedCategory == null,
                  primary: primary,
                  textColor: textColor,
                  cardBg: cardBg,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                ..._categories.map((cat) {
                  final count = widget.items
                      .where((item) => item.category == cat)
                      .length;
                  final isSelected = _selectedCategory == cat;
                  return _buildFilterChip(
                    label: '$cat ($count)',
                    isSelected: isSelected,
                    primary: primary,
                    textColor: textColor,
                    cardBg: cardBg,
                    onTap: () {
                      setState(() {
                        _selectedCategory = isSelected ? null : cat;
                      });
                    },
                  );
                }),
              ],
            ),
          ),

          Divider(
            height: 16.h,
            thickness: 0.6,
            color: isDark ? Colors.white12 : Colors.black12,
          ),

          // Topics List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48.sp,
                          color: textColor.withValues(alpha: 0.35),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'لا توجد مواضيع مطابقة لبحثك',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: textColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      bottom: 24.h,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      final originalIndex = entry.key;
                      final item = entry.value;
                      final isCurrent = originalIndex == widget.currentIndex;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onTopicSelected(originalIndex);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? primary.withValues(alpha: 0.12)
                                    : cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCurrent
                                      ? primary
                                      : (isDark
                                          ? Colors.white10
                                          : Colors.black.withValues(alpha: 0.05)),
                                  width: isCurrent ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Topic index badge
                                  Container(
                                    width: 38.w,
                                    height: 38.h,
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? primary
                                          : primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${item.id}',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? Colors.white
                                            : primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),

                                  // Title & category
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: isCurrent
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: isCurrent
                                                ? primary
                                                : textColor,
                                          ),
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          item.category,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11.5.sp,
                                            color: textColor.withValues(
                                              alpha: 0.55,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Active reading badge
                                  if (isCurrent)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.bookmark_rounded,
                                            color: Colors.white,
                                            size: 13.sp,
                                          ),
                                          SizedBox(width: 3.w),
                                          Text(
                                            'أنت هنا',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 14.sp,
                                      color: textColor.withValues(alpha: 0.3),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color primary,
    required Color textColor,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? primary : cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? primary : primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : textColor,
            ),
          ),
        ),
      ),
    );
  }
}
