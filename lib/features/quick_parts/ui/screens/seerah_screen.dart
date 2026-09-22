import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:google_fonts/google_fonts.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/quick_parts/data/models/seerah_item.dart';
import 'package:rafeeq/features/quick_parts/logic/seerah_cubit.dart';
import 'package:rafeeq/features/quick_parts/ui/widgets/seerah_index_bottom_sheet.dart';

class SeerahScreen extends StatefulWidget {
  const SeerahScreen({super.key});

  @override
  State<SeerahScreen> createState() => _SeerahScreenState();
}

class _SeerahScreenState extends State<SeerahScreen> {
  late final SeerahCubit _cubit;
  PageController? _pageController;
  int _lastKnownIndex = -1;

  @override
  void initState() {
    super.initState();
    _cubit = SeerahCubit();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _cubit.close();
    super.dispose();
  }

  void _initPageControllerIfNeeded(int initialIndex) {
    if (_pageController == null) {
      _pageController = PageController(initialPage: initialIndex);
      _lastKnownIndex = initialIndex;
    } else if (_lastKnownIndex != initialIndex) {
      if (_pageController!.hasClients &&
          _pageController!.page?.round() != initialIndex) {
        _pageController!.jumpToPage(initialIndex);
      }
      _lastKnownIndex = initialIndex;
    }
  }

  void _animateToTopic(int index) {
    _cubit.goToTopic(index);
    if (_pageController != null && _pageController!.hasClients) {
      _pageController!.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showFontSizeDialog(
    BuildContext context,
    Color primary,
    Color textColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg = isDark
            ? AppColors.bottomSheetDark
            : AppColors.bottomSheetLight;

        return BlocBuilder<SeerahCubit, SeerahState>(
          bloc: _cubit,
          builder: (context, state) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44.w,
                    height: 4.h,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    'حجم خط القراءة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Decrease
                      IconButton.filledTonal(
                        onPressed: state.fontSize > 14.0
                            ? () => _cubit.changeFontSize(-2.0)
                            : null,
                        icon: const Icon(Icons.text_decrease_rounded),
                        tooltip: 'تصغير الخط',
                      ),
                      SizedBox(width: 20.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.fontSize.toInt()} نقطة',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      // Increase
                      IconButton.filledTonal(
                        onPressed: state.fontSize < 32.0
                            ? () => _cubit.changeFontSize(2.0)
                            : null,
                        icon: const Icon(Icons.text_increase_rounded),
                        tooltip: 'تكبير الخط',
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TextButton.icon(
                    onPressed: () => _cubit.resetFontSize(),
                    icon: const Icon(Icons.restore_rounded, size: 16),
                    label: const Text('إعادة تعيين الحجم الافتراضي'),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _copyTopicContent(BuildContext context, SeerahItem item) {
    final text = '${item.title}\n\n${item.content}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('تم نسخ نص الموضوع بنجاح'),
          ],
        ),
        backgroundColor: AppColors.getPrimary(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.getPrimary(context);
    final bgCol = context.colorScheme.surface;
    final textCol = context.colorScheme.onSurface;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<SeerahCubit, SeerahState>(
        listener: (context, state) {
          if (state.isLoaded) {
            _initPageControllerIfNeeded(state.currentIndex);
          }
        },
        builder: (context, state) {
          if (state.isLoading || state.status == SeerahStatus.initial) {
            return Scaffold(
              backgroundColor: bgCol,
              appBar: AppBar(
                backgroundColor: bgCol,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20.sp,
                    color: textCol,
                  ),
                ),
                title: Text(
                  'quick_parts_screens.seerah_title'.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                  ),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: primary),
                    SizedBox(height: 16.h),
                    Text(
                      'جاري تحميل السيرة النبوية...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: textCol.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.status == SeerahStatus.error) {
            return Scaffold(
              backgroundColor: bgCol,
              appBar: AppBar(
                backgroundColor: bgCol,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20.sp,
                    color: textCol,
                  ),
                ),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 48.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.errorMessage ?? 'حدث خطأ غير متوقع',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, color: textCol),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () => _cubit.loadSeerah(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final currentItem = state.currentItem;
          _initPageControllerIfNeeded(state.currentIndex);

          return Scaffold(
            backgroundColor: bgCol,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: bgCol,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20.sp,
                  color: textCol,
                ),
              ),
              title: Column(
                children: [
                  Text(
                    'quick_parts_screens.seerah_title'.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                  ),
                  if (currentItem != null)
                    Text(
                      'الموضوع ${state.currentIndex + 1} من ${state.items.length}',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              actions: [
                // Font Size Adjuster
                IconButton(
                  onPressed: () =>
                      _showFontSizeDialog(context, primary, textCol),
                  tooltip: 'تغيير حجم الخط',
                  icon: Icon(
                    Icons.format_size_rounded,
                    size: 22.sp,
                    color: textCol,
                  ),
                ),
                // Table of contents (الفهرس)
                IconButton(
                  onPressed: () {
                    SeerahIndexBottomSheet.show(
                      context,
                      cubit: _cubit,
                      items: state.items,
                      currentIndex: state.currentIndex,
                      onTopicSelected: (newIdx) {
                        _animateToTopic(newIdx);
                      },
                    );
                  },
                  tooltip: 'الفهرس',
                  icon: Icon(
                    Icons.menu_book_rounded,
                    size: 22.sp,
                    color: primary,
                  ),
                ),
                // Share / Copy Topic
                if (currentItem != null)
                  IconButton(
                    onPressed: () => _copyTopicContent(context, currentItem),
                    tooltip: 'نسخ الموضوع',
                    icon: Icon(Icons.copy_rounded, size: 20.sp, color: textCol),
                  ),
                SizedBox(width: 4.w),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Linear progress bar across the 59 topics
                  LinearProgressIndicator(
                    value: state.items.isNotEmpty
                        ? (state.currentIndex + 1) / state.items.length
                        : 0.0,
                    backgroundColor: primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                    minHeight: 2.5.h,
                  ),

                  // Swipeable reader view
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.items.length,
                      onPageChanged: (idx) {
                        _lastKnownIndex = idx;
                        _cubit.goToTopic(idx);
                      },
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return _TopicContentView(
                          item: item,
                          fontSize: state.fontSize,
                          primary: primary,
                          textCol: textCol,
                        );
                      },
                    ),
                  ),

                  // Bottom Navigation Bar
                  _buildBottomNavigationBar(context, state, primary, textCol),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    SeerahState state,
    Color primary,
    Color textColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFirst = state.currentIndex <= 0;
    final isLast = state.currentIndex >= state.items.length - 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181D1B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Next Button (التالي)
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: isLast
                    ? null
                    : () => _animateToTopic(state.currentIndex + 1),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  disabledForegroundColor: textColor.withValues(alpha: 0.25),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(
                  'التالي',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Saved Indicator & Index Button
          InkWell(
            onTap: () {
              SeerahIndexBottomSheet.show(
                context,
                cubit: _cubit,
                items: state.items,
                currentIndex: state.currentIndex,
                onTopicSelected: (newIdx) {
                  _animateToTopic(newIdx);
                },
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_added_rounded,
                    size: 14.sp,
                    color: primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${state.currentIndex + 1} / ${state.items.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Previous Button (السابق)
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: isFirst
                    ? null
                    : () => _animateToTopic(state.currentIndex - 1),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  disabledForegroundColor: textColor.withValues(alpha: 0.25),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  visualDensity: VisualDensity.compact,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'السابق',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicContentView extends StatelessWidget {
  final SeerahItem item;
  final double fontSize;
  final Color primary;
  final Color textCol;

  const _TopicContentView({
    required this.item,
    required this.fontSize,
    required this.primary,
    required this.textCol,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161C1A) : const Color(0xFFFBFBF9);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card with Category & Title
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: primary.withValues(alpha: 0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category Chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 14.sp,
                        color: primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        item.category,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),

                // Title
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 10.h),

                // Islamic Ornamental Divider
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50.w,
                      height: 1,
                      color: primary.withValues(alpha: 0.3),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: primary.withValues(alpha: 0.7),
                      ),
                    ),
                    Container(
                      width: 50.w,
                      height: 1,
                      color: primary.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 18.h),

          // Topic Body Content
          SelectableText(
            item.content,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            style: GoogleFonts.amiri(
              fontSize: fontSize.sp,
              height: 2.0,
              letterSpacing: 0.2,
              color: isDark ? const Color(0xFFEDECE8) : const Color(0xFF232323),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
