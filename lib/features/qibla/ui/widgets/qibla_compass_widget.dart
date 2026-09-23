import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'qibla_config.dart';
import 'compass_painters.dart';
import 'direction_labels.dart';
import 'loading_view.dart';
import 'no_sensor_view.dart';

class QiblaCompassWidget extends StatefulWidget {
  final ValueNotifier<bool> calibNotifier;
  final QiblaConfig cfg;

  const QiblaCompassWidget({
    super.key,
    required this.calibNotifier,
    required this.cfg,
  });

  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  DateTime? _lastVib;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _handleHaptics(double offset) {
    final absOff = offset.abs();
    final now = DateTime.now();

    if (absOff <= 10) {
      final gap = _lastVib == null
          ? const Duration(seconds: 999)
          : now.difference(_lastVib!);

      if (absOff <= 2 && gap.inMilliseconds > 800) {
        HapticFeedback.heavyImpact();
        _lastVib = now;
      } else if (absOff <= 5 && gap.inMilliseconds > 1200) {
        HapticFeedback.mediumImpact();
        _lastVib = now;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.getPrimary(context);

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingView(isDark: isDark, cfg: widget.cfg);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return NoSensorView(cfg: widget.cfg);
        }

        final data = snapshot.data!;
        final offset = calculateOffset(data.direction, data.qiblah);
        final isLocked = offset.abs() <= 5;
        _handleHaptics(offset);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // ── Kaaba indicator above compass (static reference) ──
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  Assets.images.kaaba.path,
                  width: widget.cfg.isTablet ? 70 : 52.w,
                  height: widget.cfg.isTablet ? 70 : 52.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 24.h),
              ],
            ),

            // ── Compass ──
            Center(
              child: SizedBox(
                width: widget.cfg.compassSize,
                height: widget.cfg.compassSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Glow (locked state)
                    if (isLocked)
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: CustomPaint(
                          size: Size(
                            widget.cfg.compassSize,
                            widget.cfg.compassSize,
                          ),
                          painter: LockGlowPainter(
                            intensity: _pulseCtrl.value,
                            isDark: isDark,
                          ),
                        ),
                      ),

                    // Background Disk with gradient
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF0D2B1E),
                                  const Color(0xFF081812),
                                ]
                              : [
                                  const Color(0xFFF0FAF5),
                                  const Color(0xFFE2F3EA),
                                ],
                          center: Alignment.topLeft,
                          radius: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.45 : 0.12,
                            ),
                            blurRadius: 36,
                            spreadRadius: -8,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: (isDark ? const Color(0xFF029E50) : accent)
                                .withValues(alpha: 0.08),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    // Inner subtle ring
                    CustomPaint(
                      size: Size(
                        widget.cfg.compassSize * 0.78,
                        widget.cfg.compassSize * 0.78,
                      ),
                      painter: InnerRingPainter(
                        isDark: isDark,
                        isLocked: isLocked,
                      ),
                    ),

                    // 1. Compass Disk (Rotates with device)
                    Transform.rotate(
                      angle: (data.direction * (math.pi / 180) * -1),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(
                              widget.cfg.compassSize,
                              widget.cfg.compassSize,
                            ),
                            painter: OrnamentalRingPainter(isDark: isDark),
                          ),
                          CustomPaint(
                            size: Size(
                              widget.cfg.compassSize,
                              widget.cfg.compassSize,
                            ),
                            painter: CompassTicksPainter(isDark: isDark),
                          ),
                          DirectionLabels(
                            size: widget.cfg.compassSize,
                            isDark: isDark,
                            cfg: widget.cfg,
                          ),
                        ],
                      ),
                    ),

                    // 2. Qibla Needle (Rotates with Qibla angle)
                    Transform.rotate(
                      angle: (data.qiblah * (math.pi / 180) * -1),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(
                              widget.cfg.compassSize * 0.9,
                              widget.cfg.compassSize * 0.9,
                            ),
                            painter: CompassNeedlePainter(isDark: isDark),
                          ),
                          // Qibla Indicator (Mosque) — larger
                          Align(
                            alignment: const Alignment(0, -0.88),
                            child: Container(
                              padding: EdgeInsets.all(
                                widget.cfg.isTablet ? 10 : 7.w,
                              ),
                              decoration: BoxDecoration(
                                color: isLocked
                                    ? const Color(0xFF029E50)
                                    : accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isLocked
                                                ? const Color(0xFF029E50)
                                                : accent)
                                            .withValues(alpha: 0.45),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.mosque_rounded,
                                size: widget.cfg.isTablet ? 30 : 24.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center dot
                    Container(
                      width: widget.cfg.isTablet ? 18 : 14.w,
                      height: widget.cfg.isTablet ? 18 : 14.w,
                      decoration: BoxDecoration(
                        color: isLocked ? const Color(0xFF029E50) : accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: (isLocked ? const Color(0xFF029E50) : accent)
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ── Locked Status ──
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: isLocked ? 1.0 : 0.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF029E50).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF029E50).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF029E50),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "تم تحديد القبلة",
                      style: TextStyle(
                        color: const Color(0xFF029E50),
                        fontWeight: FontWeight.bold,
                        fontSize: widget.cfg.bodyFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        );
      },
    );
  }
}
