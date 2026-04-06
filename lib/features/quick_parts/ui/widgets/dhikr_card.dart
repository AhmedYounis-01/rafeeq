import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/dhikr_item.dart';
import 'package:google_fonts/google_fonts.dart';

class DhikrCard extends StatefulWidget {
  final DhikrItem item;

  const DhikrCard({super.key, required this.item});

  @override
  State<DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<DhikrCard>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  bool _completed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remaining = widget.item.count;
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_completed) return;
    HapticFeedback.lightImpact();
    _pulseController.forward().then((_) => _pulseController.reverse());
    setState(() {
      _remaining--;
      if (_remaining <= 0) {
        _remaining = 0;
        _completed = true;
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _onReset() {
    setState(() {
      _remaining = widget.item.count;
      _completed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary = AppColors.getPrimary(
      context,
    ); // This is usually the green color
    final isAr = context.locale.languageCode == 'ar';

    // Premium light green theme for cards as per the screenshot
    final cardColor = isDark
        ? context.colorScheme.surfaceContainerHighest
        : const Color(0xFFF1F9F6); // Light mint green background

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _pulseAnimation.value, child: child);
      },
      child: GestureDetector(
        onTap: _onTap,
        onLongPress: _onReset,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: 20.h),
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: _completed
                ? (isDark ? primary.withAlpha(40) : const Color(0xFFE8F5EE))
                : cardColor,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: _completed
                  ? primary.withAlpha(150)
                  : (isDark ? Colors.white10 : const Color(0xFFE0EFE8)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withAlpha(5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Dhikr Main Text ──
              Text(
                widget.item.text,
                textAlign: TextAlign.center,
                textDirection: isAr
                    ? ui.TextDirection.rtl
                    : ui.TextDirection.ltr,
                style: GoogleFonts.amiri(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.7,
                  color: isDark ? Colors.white : const Color(0xFF2D312F),
                ),
              ),

              SizedBox(height: 16.h),

              // ── Star Divider with centered star ──
              Row(
                children: [
                  Expanded(
                    child: Divider(color: primary.withAlpha(40), thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Icon(
                      Icons.star_rounded,
                      size: 16.sp,
                      color: primary.withAlpha(80),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: primary.withAlpha(40), thickness: 1),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // ── Description / Meaning Text ──
              Text(
                isAr ? widget.item.meaningAr : widget.item.meaning,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.6,
                  color: isDark ? Colors.white70 : const Color(0xFF707874),
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 24.h),

              // ── Bottom Badges Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Count Badge (Bottom Left)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '×${widget.item.count}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Count Text (Bottom Right)
                  Text(
                    _completed
                        ? (isAr ? "تم بحمد الله" : "Completed")
                        : (isAr
                              ? _getArabicCountText(widget.item.count)
                              : "Count: ${widget.item.count}"),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getArabicCountText(int count) {
    if (count == 1) return "مرة واحدة";
    if (count == 2) return "مرتان";
    if (count <= 10) return "$count مرات";
    return "$count مرة";
  }
}
