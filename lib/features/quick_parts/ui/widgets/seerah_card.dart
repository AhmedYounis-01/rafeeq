import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import '../../data/models/seerah_item.dart';

class SeerahCard extends StatefulWidget {
  final SeerahItem item;
  final bool isFirst;
  final bool isLast;

  const SeerahCard({
    super.key,
    required this.item,
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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInQuart,
    );
    _arrowTurns = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
    final isArabic = context.locale.languageCode == 'ar';
    final title = isArabic ? widget.item.title : widget.item.titleEn;
    final content = isArabic ? widget.item.content : widget.item.contentEn;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Timeline column ──
        SizedBox(
          width: 28.w,
          child: Column(
            children: [
              Container(
                width: 2,
                height: 12.h,
                color: widget.isFirst
                    ? Colors.transparent
                    : primary.withAlpha(60),
              ),
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withAlpha(80),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Container(
                width: 2,
                height: 40.h,
                color: widget.isLast
                    ? Colors.transparent
                    : primary.withAlpha(60),
              ),
            ],
          ),
        ),

        SizedBox(width: 8.w),

        // ── Card ──
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: _expanded
                        ? primary.withAlpha(120)
                        : (isDark
                              ? Colors.white.withAlpha(15)
                              : Colors.black.withAlpha(8)),
                    width: _expanded ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black38
                          : Colors.black.withAlpha(15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            textDirection: isArabic
                                ? ui.TextDirection.rtl
                                : ui.TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        RotationTransition(
                          turns: _arrowTurns,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: primary,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Divider(color: primary.withAlpha(30)),
                          ),
                          Text(
                            content,
                            textDirection: isArabic
                                ? ui.TextDirection.rtl
                                : ui.TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.7,
                              color: isDark
                                  ? Colors.white.withAlpha(200)
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
