import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import '../../data/models/seerah_item.dart';

class SeerahCard extends StatefulWidget {
  final SeerahItem item;
  final bool isArabic;
  final bool isFirst;
  final bool isLast;

  const SeerahCard({
    super.key,
    required this.item,
    required this.isArabic,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<SeerahCard> createState() => _SeerahCardState();
}

class _SeerahCardState extends State<SeerahCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _arrowTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _arrowTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary = AppColors.getPrimary(context);
    final title = widget.isArabic ? widget.item.title : widget.item.titleEn;
    final content =
        widget.isArabic ? widget.item.content : widget.item.contentEn;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        // crossAxisAlignment.start so the timeline dot aligns to the top
        // of the card, not the bottom — this is what removes the overflow.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline column ──────────────────────────────────────────
          SizedBox(
            width: 28.w,
            child: Column(
              children: [
                if (!widget.isFirst)
                  Container(
                    width: 2,
                    height: 8.h,
                    color: primary.withAlpha(60),
                  ),
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withAlpha(80),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!widget.isLast)
                  Container(
                    width: 2,
                    height: 12.h,
                    color: primary.withAlpha(60),
                  ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // ── Card ─────────────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _expanded
                        ? primary.withAlpha(100)
                        : (isDark
                              ? Colors.white.withAlpha(18)
                              : Colors.black.withAlpha(12)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withAlpha(40)
                          : Colors.black.withAlpha(10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // mainAxisSize.min → card wraps its children, never expands
                // beyond its content. This is the core fix for the overflow.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Title row ──────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            textDirection: widget.isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        RotationTransition(
                          turns: _arrowTurns,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20.sp,
                            color: primary.withAlpha(180),
                          ),
                        ),
                      ],
                    ),

                    // ── Expandable content ─────────────────────────────
                    // SizeTransition correctly collapses to zero height.
                    // AnimatedCrossFade was keeping the old (large) size
                    // during the reverse animation, causing the overflow.
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      axisAlignment: -1.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 10.h),
                          Divider(
                            thickness: 0.5,
                            color: isDark
                                ? Colors.white.withAlpha(20)
                                : Colors.black.withAlpha(12),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            content,
                            textDirection: widget.isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 13.sp,
                              height: 1.8,
                              color: isDark
                                  ? Colors.white.withAlpha(180)
                                  : Colors.black.withAlpha(160),
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
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