import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

// ─── Helper ──────────────────────────────────────────────────────────────────

double _calculateOffset(double deviceDirection, double qiblahDirection) {
  double diff = qiblahDirection - deviceDirection;
  while (diff > 180) {
    diff -= 360;
  }
  while (diff < -180) {
    diff += 360;
  }
  return diff;
}

// ─── QiblaScreen ─────────────────────────────────────────────────────────────
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with WidgetsBindingObserver {
  final Future<bool?> _sensorSupportFuture =
      FlutterQiblah.androidDeviceSensorSupport();

  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();
  Stream<LocationStatus> get _locationStream =>
      _locationStreamController.stream;

  final _calibNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationStreamController.close();
    _calibNotifier.dispose();
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkLocationStatus();
    }
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final updated = await FlutterQiblah.checkLocationStatus();
      if (!_locationStreamController.isClosed) {
        _locationStreamController.sink.add(updated);
      }
    } else {
      if (!_locationStreamController.isClosed) {
        _locationStreamController.sink.add(locationStatus);
      }
    }
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> _onRefresh() async {
    await _checkLocationStatus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0A1F17),
                  const Color(0xFF081812),
                  const Color(0xFF05100C),
                ]
              : [
                  const Color(0xFFF5FAF7),
                  const Color(0xFFEDF5F0),
                  const Color(0xFFE8F2EB),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Top Bar with Info Button ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _showInstructions(context, isDark),
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                      size: 24.sp,
                    ),
                    tooltip: "qibla.instructions".tr(),
                  ),
                ],
              ),
            ),
            // ── Calibration Banner ──
            _buildCalibrationBanner(isDark),
            // ── Main Content ──
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
                backgroundColor: isDark
                    ? const Color(0xFF0A1F17)
                    : Colors.white,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildCompassSection(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstructions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1F18) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.primaryDark.withValues(alpha: 0.4)
                  : AppColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            // Icon
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.primaryDark : AppColors.primary)
                    .withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.explore_rounded,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 16.h),
            // Title
            Text(
              "qibla.instructions_title".tr(),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            // Message
            Text(
              "qibla.activate_location_message".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                fontSize: 15.sp,
                height: 1.6,
              ),
            ),
            SizedBox(height: 28.h),
            // Got it button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.primaryDark
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "qibla.understand".tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationBanner(bool isDark) {
    return ValueListenableBuilder<bool>(
      valueListenable: _calibNotifier,
      builder: (_, isUnstable, _) => AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        offset: isUnstable ? Offset.zero : const Offset(0, -1.5),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: isUnstable ? 1.0 : 0.0,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFFF8F00).withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rotate_90_degrees_ccw_outlined,
                  color: const Color(0xFFFF8F00),
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    "qibla.calibration_hint".tr(),
                    style: TextStyle(
                      color: const Color(0xFFFF8F00),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompassSection() {
    return FutureBuilder<bool?>(
      future: _sensorSupportFuture,
      builder: (context, sensorSnapshot) {
        if (sensorSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingIndicator();
        }

        final hasSensor = sensorSnapshot.data ?? true;

        if (!hasSensor) {
          return const _NoSensorView();
        }

        return StreamBuilder<LocationStatus>(
          stream: _locationStream,
          builder: (context, locSnapshot) {
            if (locSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingIndicator();
            }

            final locStatus = locSnapshot.data;

            if (locStatus == null || !locStatus.enabled) {
              return _LocationErrorView(
                message: "qibla.activate_location".tr(),
                onEnable: _openLocationSettings,
              );
            }

            if (locStatus.status == LocationPermission.denied ||
                locStatus.status == LocationPermission.deniedForever) {
              return _LocationErrorView(
                message: locStatus.status == LocationPermission.deniedForever
                    ? "qibla.permission_denied_forever".tr()
                    : "qibla.activate_location".tr(),
                onEnable: locStatus.status == LocationPermission.deniedForever
                    ? () async {
                        await Geolocator.openAppSettings();
                        await Future.delayed(const Duration(milliseconds: 500));
                        _checkLocationStatus();
                      }
                    : _checkLocationStatus,
              );
            }

            return _QiblaCompassWidget(calibNotifier: _calibNotifier);
          },
        );
      },
    );
  }

  Widget _loadingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppColors.primaryDark : AppColors.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            "common.loading".tr(),
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Compass Widget ───────────────────────────────────────────────────────────
class _QiblaCompassWidget extends StatefulWidget {
  final ValueNotifier<bool> calibNotifier;
  const _QiblaCompassWidget({required this.calibNotifier});

  @override
  State<_QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<_QiblaCompassWidget>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  bool _isLocked = false;
  final List<double> _recentDirs = [];
  Timer? _calibTimer;
  DateTime? _lastVib;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.14,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    _calibTimer?.cancel();
    super.dispose();
  }

  void _sideEffects(QiblahDirection qd, double calculatedOffset) {
    if (!mounted) return;
    final absOff = calculatedOffset.abs();

    // Calibration detection
    _recentDirs.add(qd.direction);
    if (_recentDirs.length > 15) _recentDirs.removeAt(0);
    if (_recentDirs.length == 15) {
      final span =
          _recentDirs.reduce((a, b) => a > b ? a : b) -
          _recentDirs.reduce((a, b) => a < b ? a : b);
      final unstable = span > 35;
      if (unstable && !widget.calibNotifier.value) {
        // Show calibration banner
        widget.calibNotifier.value = true;
        _calibTimer?.cancel();
        // Keep visible for minimum 2 seconds so user can read it
        _calibTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) widget.calibNotifier.value = false;
        });
      }
    }

    // Pulse animation
    if (absOff <= 10) {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    } else {
      if (_pulseCtrl.isAnimating) {
        _pulseCtrl.stop();
        _pulseCtrl.reset();
      }
    }

    // Lock state feedback
    final nowLocked = (absOff <= 3);
    if (nowLocked != _isLocked) {
      setState(() => _isLocked = nowLocked);
      if (nowLocked) {
        _glowCtrl.repeat(reverse: true);
        HapticFeedback.heavyImpact();
        Future.delayed(
          const Duration(milliseconds: 200),
          HapticFeedback.heavyImpact,
        );
      } else {
        _glowCtrl.stop();
        _glowCtrl.reset();
      }
    }

    // Haptic feedback
    if (!nowLocked) {
      final now = DateTime.now();
      final gap = _lastVib == null
          ? const Duration(seconds: 999)
          : now.difference(_lastVib!);
      if (absOff <= 15 && absOff > 5 && gap.inMilliseconds > 1200) {
        HapticFeedback.selectionClick();
        _lastVib = now;
      } else if (absOff <= 5 && gap.inMilliseconds > 700) {
        HapticFeedback.mediumImpact();
        _lastVib = now;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.primaryDark : AppColors.primary,
              strokeWidth: 3,
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _NoSensorView();
        }

        final qiblahDirection = snapshot.data!;
        final calculatedOffset = _calculateOffset(
          qiblahDirection.direction,
          qiblahDirection.qiblah,
        );

        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _sideEffects(qiblahDirection, calculatedOffset),
        );

        final compassAngle = qiblahDirection.direction * (math.pi / 180) * -1;
        final qiblaAngle = qiblahDirection.qiblah * (math.pi / 180) * -1;
        final absOff = calculatedOffset.abs();
        final progress = 1.0 - (absOff / 90).clamp(0.0, 1.0);
        const accent = Color(0xFFC9A24D);

        return Column(
          children: [
            SizedBox(height: 16.h),
            // ── Mosque Icon ──
            Image.asset(Assets.images.kaaba.path, height: 60.h, width: 60.w),
            SizedBox(height: 4.h),
            // ── Direction Indicator Arrow ──
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: accent,
                    size: 40.sp,
                  ),
                );
              },
            ),
            SizedBox(height: 8.h),
            // ── Compass ──
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress Arc
                        CustomPaint(
                          size: Size.infinite,
                          painter: _ProgressArcPainter(
                            progress: progress,
                            color: accent,
                            isDark: isDark,
                          ),
                        ),
                        // Static Ornamental Mandala
                        CustomPaint(
                          size: Size.infinite,
                          painter: _OrnamentalRingPainter(isDark: isDark),
                        ),
                        // Lock Glow
                        if (_isLocked)
                          AnimatedBuilder(
                            animation: _glowAnim,
                            builder: (_, _) => CustomPaint(
                              size: Size.infinite,
                              painter: _LockGlowPainter(
                                intensity: _glowAnim.value,
                                isDark: isDark,
                              ),
                            ),
                          ),
                        // Rotating Compass Disk
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: compassAngle),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (context, angle, child) {
                            return Transform.rotate(angle: angle, child: child);
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final outerSize = constraints.maxWidth;
                              final innerDiskSize = outerSize * 0.82;
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Compass Face Disk
                                  Container(
                                    width: innerDiskSize,
                                    height: innerDiskSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: isDark
                                            ? const [
                                                Color(0xFF1E583A),
                                                Color(0xFF0F2D1E),
                                                Color(0xFF0D2519),
                                                Color(0xFF081A12),
                                              ]
                                            : const [
                                                Color(0xFFE8F5EC),
                                                Color(0xFFD4ECD8),
                                                Color(0xFFC0E3C6),
                                                Color(0xFFB0D9B7),
                                              ],
                                        stops: const [0.0, 0.4, 0.8, 1.0],
                                      ),
                                      border: Border.all(
                                        color: accent.withValues(
                                          alpha: isDark ? 0.3 : 0.4,
                                        ),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black54
                                              : Colors.black12,
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Tick marks
                                  CustomPaint(
                                    size: Size(innerDiskSize, innerDiskSize),
                                    painter: _CompassTicksPainter(
                                      isDark: isDark,
                                    ),
                                  ),
                                  // Direction Labels
                                  _buildDirectionLabels(outerSize, isDark),
                                  // North Pointer
                                  CustomPaint(
                                    size: Size(
                                      innerDiskSize * 0.72,
                                      innerDiskSize * 0.72,
                                    ),
                                    painter: _CompassNeedlePainter(
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        // Qibla Indicator
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: qiblaAngle),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (context, angle, child) {
                            return Transform.rotate(angle: angle, child: child);
                          },
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, child) => Transform.scale(
                                scale: _isLocked ? 1.0 : _pulseAnim.value,
                                child: child,
                              ),
                              child: Container(
                                width: 46.w,
                                height: 46.w,
                                margin: EdgeInsets.only(top: 8.h),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFFFAF8F0),
                                  border: Border.all(
                                    color: const Color(0xFFC9A24D),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withValues(
                                        alpha: _isLocked ? 0.9 : 0.5,
                                      ),
                                      blurRadius: _isLocked ? 20 : 10,
                                      spreadRadius: _isLocked ? 4 : 1,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.6 : 0.15,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(3.r),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF014D28),
                                  ),
                                  child: ClipOval(
                                    child: Padding(
                                      padding: EdgeInsets.all(6.r),
                                      child: Image.asset(
                                        Assets.images.kaaba.path,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ── Lock Banner ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _isLocked
                  ? Container(
                      key: const ValueKey('locked'),
                      margin: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.primaryDark : AppColors.primary)
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color:
                              (isDark
                                      ? AppColors.primaryDark
                                      : AppColors.primary)
                                  .withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primary,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "qibla.qibla_locked".tr(),
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(key: ValueKey('unlocked'), height: 0),
            ),
            SizedBox(height: 4.h),
            // ── Degree Display ──
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isDark
                        ? accent.withValues(alpha: 0.2)
                        : accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  "${calculatedOffset.toStringAsFixed(1)}°",
                  style: TextStyle(
                    color: accent,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        );
      },
    );
  }

  static Widget _buildDirectionLabels(double size, bool isDark) {
    final style = TextStyle(
      color: isDark ? Colors.white : const Color(0xFF2D5F3F),
      fontWeight: FontWeight.bold,
      fontSize: (size * 0.055).clamp(13.0, 18.0).sp,
      letterSpacing: 1.2,
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: const Alignment(0, -0.68),
            child: Text(
              "N",
              style: style.copyWith(
                color: isDark ? const Color(0xFF029E50) : AppColors.primary,
                fontSize: style.fontSize! + 2,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.68, 0),
            child: Text("E", style: style),
          ),
          Align(
            alignment: const Alignment(0, 0.68),
            child: Text("S", style: style),
          ),
          Align(
            alignment: const Alignment(-0.68, 0),
            child: Text("W", style: style),
          ),
        ],
      ),
    );
  }
}

// ─── No Sensor View ──────────────────────────────────────────────────────────
class _NoSensorView extends StatelessWidget {
  const _NoSensorView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.secondaryDark : AppColors.secondary)
                    .withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.sensors_off_rounded,
                size: 64.sp,
                color: isDark ? AppColors.secondaryDark : AppColors.secondary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "qibla.sensor_error_title".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "qibla.sensor_error_desc".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location Error View ─────────────────────────────────────────────────────
class _LocationErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onEnable;

  const _LocationErrorView({required this.message, this.onEnable});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Location illustration
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? AppColors.secondaryDark : AppColors.secondary)
                  .withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.location_off_rounded,
              size: 72.sp,
              color: isDark ? AppColors.secondaryDark : AppColors.secondary,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            "qibla.location_error_title".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white60 : AppColors.textSecondary,
              fontSize: 15.sp,
              height: 1.6,
            ),
          ),
          const Spacer(),
          // Enable button
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: onEnable,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.primaryDark
                    : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_rounded, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "qibla.activate".tr(),
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}

// ─── Custom Painters ─────────────────────────────────────────────────────────

class _ProgressArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  _ProgressArcPainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }

    if (progress > 0.02) {
      final headAngle = -math.pi / 2 + 2 * math.pi * progress;
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(headAngle) * radius,
          center.dy + math.sin(headAngle) * radius,
        ),
        5,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.isDark != isDark;
}

class _LockGlowPainter extends CustomPainter {
  final double intensity;
  final bool isDark;

  _LockGlowPainter({required this.intensity, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.88;
    final glowColor = isDark ? AppColors.primaryDark : AppColors.primary;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = glowColor.withValues(alpha: 0.08 + 0.18 * intensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 + 14 * intensity),
    );

    canvas.drawCircle(
      center,
      radius * 0.75,
      Paint()
        ..color = glowColor.withValues(alpha: 0.05 + 0.1 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _LockGlowPainter oldDelegate) =>
      oldDelegate.intensity != intensity || oldDelegate.isDark != isDark;
}

class _OrnamentalRingPainter extends CustomPainter {
  final bool isDark;

  _OrnamentalRingPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.84;
    final baseColor = isDark
        ? const Color(0xFF1B7A4A)
        : const Color(0xFF3A9D6A);

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = baseColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final petalPaint = Paint()
      ..color = baseColor.withValues(alpha: isDark ? 0.4 : 0.25)
      ..style = PaintingStyle.fill;

    const int petalCount = 16;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * (360 / petalCount)) * (math.pi / 180);
      final p1 = Offset(
        center.dx + math.cos(angle - 0.1) * (innerRadius * 1.05),
        center.dy + math.sin(angle - 0.1) * (innerRadius * 1.05),
      );
      final p2 = Offset(
        center.dx + math.cos(angle + 0.1) * (innerRadius * 1.05),
        center.dy + math.sin(angle + 0.1) * (innerRadius * 1.05),
      );
      final pTip = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(
          center.dx + math.cos(angle) * (outerRadius * 0.9),
          center.dy + math.sin(angle) * (outerRadius * 0.9),
          pTip.dx,
          pTip.dy,
        )
        ..quadraticBezierTo(
          center.dx + math.cos(angle) * (outerRadius * 0.9),
          center.dy + math.sin(angle) * (outerRadius * 0.9),
          p2.dx,
          p2.dy,
        )
        ..close();
      canvas.drawPath(path, petalPaint);
    }

    final arcPaint = Paint()
      ..color = baseColor.withValues(alpha: isDark ? 0.2 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 12; i++) {
      final startAngle = (i * 30 - 15) * (math.pi / 180);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius * 0.95),
        startAngle,
        30 * (math.pi / 180),
        false,
        arcPaint,
      );
    }

    final dotPaint = Paint()
      ..color = baseColor.withValues(alpha: isDark ? 0.4 : 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 72; i++) {
      final angle = (i * 5) * (math.pi / 180);
      final pt = Offset(
        center.dx + math.cos(angle) * (outerRadius * 0.92),
        center.dy + math.sin(angle) * (outerRadius * 0.92),
      );
      final r = (i % 6 == 0) ? 2.5 : 1.2;
      canvas.drawCircle(pt, r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrnamentalRingPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _CompassTicksPainter extends CustomPainter {
  final bool isDark;

  _CompassTicksPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final tickColor = isDark ? Colors.white : const Color(0xFF2D5F3F);

    for (int i = 0; i < 360; i += 5) {
      final angle = i * (math.pi / 180);
      final isMajor = i % 90 == 0;
      final isMinor = i % 30 == 0;

      final outerR = radius;
      final innerR = isMajor
          ? radius - 12
          : (isMinor ? radius - 8 : radius - 5);

      final paint = Paint()
        ..color = isMajor
            ? tickColor.withValues(alpha: 0.8)
            : (isMinor
                  ? tickColor.withValues(alpha: 0.4)
                  : tickColor.withValues(alpha: 0.15))
        ..strokeWidth = isMajor ? 2.0 : (isMinor ? 1.2 : 0.5)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * innerR,
          center.dy + math.sin(angle) * innerR,
        ),
        Offset(
          center.dx + math.cos(angle) * outerR,
          center.dy + math.sin(angle) * outerR,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassTicksPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _CompassNeedlePainter extends CustomPainter {
  final bool isDark;

  _CompassNeedlePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfW = size.width * 0.06;
    final len = size.height * 0.42;

    final Color primaryGreen = isDark
        ? const Color(0xFF029E50)
        : AppColors.primary;
    final Color secondaryGreen = isDark
        ? const Color(0xFF1B7A4A)
        : const Color(0xFF3A9D6A);
    final Color darkGreen = isDark
        ? const Color(0xFF0F2D1E)
        : const Color(0xFF2D7A4A);

    final northPath = Path()
      ..moveTo(center.dx, center.dy - len)
      ..lineTo(center.dx - halfW, center.dy)
      ..lineTo(center.dx + halfW, center.dy)
      ..close();

    canvas.drawPath(
      northPath,
      Paint()
        ..shader =
            LinearGradient(
              colors: [primaryGreen, secondaryGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx, center.dy - len),
                Offset(center.dx, center.dy),
              ),
            ),
    );

    final southPath = Path()
      ..moveTo(center.dx, center.dy + len)
      ..lineTo(center.dx - halfW, center.dy)
      ..lineTo(center.dx + halfW, center.dy)
      ..close();

    canvas.drawPath(
      southPath,
      Paint()
        ..shader =
            LinearGradient(
              colors: [darkGreen, secondaryGreen],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx, center.dy),
                Offset(center.dx, center.dy + len),
              ),
            ),
    );

    final eastPath = Path()
      ..moveTo(center.dx + len, center.dy)
      ..lineTo(center.dx, center.dy - halfW)
      ..lineTo(center.dx, center.dy + halfW)
      ..close();

    canvas.drawPath(
      eastPath,
      Paint()
        ..shader =
            LinearGradient(
              colors: [primaryGreen, secondaryGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx, center.dy - halfW),
                Offset(center.dx + len, center.dy + halfW),
              ),
            ),
    );

    final westPath = Path()
      ..moveTo(center.dx - len, center.dy)
      ..lineTo(center.dx, center.dy - halfW)
      ..lineTo(center.dx, center.dy + halfW)
      ..close();

    canvas.drawPath(
      westPath,
      Paint()
        ..shader =
            LinearGradient(
              colors: [darkGreen, secondaryGreen],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ).createShader(
              Rect.fromPoints(
                Offset(center.dx - len, center.dy - halfW),
                Offset(center.dx, center.dy + halfW),
              ),
            ),
    );

    final diagLen = len * 0.65;
    final diagW = halfW * 0.6;
    final diagPaint = Paint()
      ..color = secondaryGreen.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final angle = (45 + i * 90) * (math.pi / 180);
      final tipX = center.dx + math.cos(angle) * diagLen;
      final tipY = center.dy + math.sin(angle) * diagLen;
      final perpAngle = angle + math.pi / 2;

      final p = Path()
        ..moveTo(tipX, tipY)
        ..lineTo(
          center.dx + math.cos(perpAngle) * diagW,
          center.dy + math.sin(perpAngle) * diagW,
        )
        ..lineTo(
          center.dx - math.cos(perpAngle) * diagW,
          center.dy - math.sin(perpAngle) * diagW,
        )
        ..close();

      canvas.drawPath(p, diagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassNeedlePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
