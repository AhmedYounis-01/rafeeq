import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import '../../data/models/dhikr_item.dart';

class DhikrCard extends StatefulWidget {
  final DhikrItem item;
  final bool isArabic;

  const DhikrCard({super.key, required this.item, required this.isArabic});

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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
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

  double get _progress =>
      widget.item.count > 0
          ? (widget.item.count - _remaining) / widget.item.count
          : 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary = AppColors.getPrimary(context);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.item.count > 1 ? _onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: _completed
                ? (isDark
                      ? primary.withAlpha(30)
                      : primary.withAlpha(15))
                : AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: _completed
                  ? primary.withAlpha(120)
                  : (isDark
                        ? Colors.white.withAlpha(18)
                        : Colors.black.withAlpha(12)),
              width: _completed ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(50)
                    : Colors.black.withAlpha(12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar (only for multi-count)
              if (widget.item.count > 1)
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                    bottomLeft: _progress < 1.0
                        ? Radius.zero
                        : Radius.circular(18.r),
                    bottomRight: _progress < 1.0
                        ? Radius.zero
                        : Radius.circular(18.r),
                  ),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 3.h,
                    backgroundColor: isDark
                        ? Colors.white.withAlpha(15)
                        : Colors.black.withAlpha(10),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _completed ? primary : primary.withAlpha(180),
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Arabic text
                    Text(
                      widget.item.text,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w600,
                        height: 2.1,
                        color: _completed
                            ? primary
                            : (isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Divider
                    Divider(
                      thickness: 0.5,
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : Colors.black.withAlpha(12),
                    ),

                    SizedBox(height: 8.h),

                    // Transliteration
                    Text(
                      widget.item.transliteration,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? Colors.white.withAlpha(130)
                            : Colors.black.withAlpha(100),
                        letterSpacing: 0.2,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Meaning
                    Text(
                      widget.isArabic
                          ? widget.item.meaningAr
                          : widget.item.meaning,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: isDark
                            ? Colors.white.withAlpha(160)
                            : Colors.black.withAlpha(120),
                        height: 1.6,
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Bottom row: sub note + counter
                    Row(
                      children: [
                        // Sub note chip
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withAlpha(12)
                                  : Colors.black.withAlpha(8),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              widget.isArabic
                                  ? widget.item.sub
                                  : widget.item.subEn,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 10.w),

                        // Counter button
                        if (widget.item.count > 1)
                          GestureDetector(
                            onTap: _onTap,
                            onLongPress: _onReset,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 60.w,
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: _completed
                                    ? primary
                                    : primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: _completed
                                      ? primary
                                      : primary.withAlpha(80),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _completed ? '✓' : '$_remaining',
                                    style: TextStyle(
                                      fontSize: _completed ? 16.sp : 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: _completed
                                          ? Colors.white
                                          : primary,
                                    ),
                                  ),
                                  if (!_completed)
                                    Text(
                                      '/ ${widget.item.count}',
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        color: primary.withAlpha(160),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: primary.withAlpha(60),
                              ),
                            ),
                            child: Text(
                              '${widget.item.count}×',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Long-press hint for counter
                    if (widget.item.count > 1 && !_completed)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          widget.isArabic
                              ? 'اضغط للعد • اضغط مطولاً للإعادة'
                              : 'Tap to count • Long press to reset',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            color: isDark
                                ? Colors.white.withAlpha(60)
                                : Colors.black.withAlpha(50),
                          ),
                        ),
                      ),

                    if (_completed)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: GestureDetector(
                          onTap: _onReset,
                          child: Text(
                            widget.isArabic
                                ? '✓ اكتمل — اضغط للإعادة'
                                : '✓ Completed — tap to reset',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: primary.withAlpha(180),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}