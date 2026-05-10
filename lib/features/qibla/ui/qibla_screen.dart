import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

// ─── Responsive Config ────────────────────────────────────────────────────────
class _QiblaConfig {
  final BuildContext context;
  final double shortestSide;
  _QiblaConfig(this.context)
    : shortestSide = MediaQuery.of(context).size.shortestSide;

  bool get isTablet => shortestSide >= 600;

  double get kaabaSize => isTablet ? 150 : 70.w;
  double get arrowSize => isTablet ? 80 : 48.w;
  double get qiblaMarkerSize => isTablet ? 100 : 60.w;
  double get labelFontSize => isTablet ? 24 : 18.sp;
  double get bodyFontSize => isTablet ? 18 : 15.sp;
  double get iconSize => isTablet ? 36 : 28.sp;
  double get btnHeight => isTablet ? 64 : 54.h;
  double get hPad => isTablet ? shortestSide * 0.08 : 32.w;
  double get compassSize => isTablet ? 480 : 280.w;
  double get degFontSize => isTablet ? 32 : 24.sp;
}

// ─── Helper ───────────────────────────────────────────────────────────────────
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
    if (state == AppLifecycleState.resumed) _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    final status = await FlutterQiblah.checkLocationStatus();
    if (status.enabled && status.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final updated = await FlutterQiblah.checkLocationStatus();
      if (!_locationStreamController.isClosed) {
        _locationStreamController.sink.add(updated);
      }
    } else {
      if (!_locationStreamController.isClosed) {
        _locationStreamController.sink.add(status);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = _QiblaConfig(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        color: context.colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: cfg.hPad / 2,
                  vertical: 8.h,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _showInstructions(context, isDark, cfg),
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                        size: cfg.iconSize,
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: cfg.isTablet ? 850 : double.infinity,
                    ),
                    child: RefreshIndicator(
                      onRefresh: _checkLocationStatus,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                      backgroundColor: isDark
                          ? const Color(0xFF0A1F17)
                          : Colors.white,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildCompassSection(isDark, cfg),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Reserve space for floating bottom nav bar (SharedNavigation)
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalibrationBanner(bool isDark) {
    return ValueListenableBuilder<bool>(
      valueListenable: _calibNotifier,
      builder: (context, show, child) {
        if (!show) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          color: AppColors.warning.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "qibla.calibration_hint".tr(),
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInstructions(BuildContext context, bool isDark, _QiblaConfig cfg) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: cfg.isTablet ? 560.0 : double.infinity,
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(cfg.isTablet ? 32 : 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1F18) : AppColors.backgroundLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: AppColors.getPrimary(ctx).withValues(alpha: 0.4),
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: cfg.isTablet ? 28 : 24),
            Container(
              padding: EdgeInsets.all(cfg.isTablet ? 20 : 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.getPrimary(ctx).withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.explore_rounded,
                color: AppColors.getPrimary(ctx),
                size: cfg.isTablet ? 52 : 40,
              ),
            ),
            SizedBox(height: cfg.isTablet ? 20 : 16),
            Text(
              "qibla.instructions_title".tr(),
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.textPrimary,
                fontSize: cfg.labelFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "qibla.activate_location_message".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.6)
                    : AppColors.textSecondary,
                fontSize: cfg.bodyFontSize,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: cfg.btnHeight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(ctx),
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "qibla.understand".tr(),
                  style: TextStyle(
                    fontSize: cfg.bodyFontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16 + MediaQuery.of(ctx).viewPadding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassSection(bool isDark, _QiblaConfig cfg) {
    return FutureBuilder<bool?>(
      future: _sensorSupportFuture,
      builder: (context, sensorSnap) {
        if (sensorSnap.connectionState == ConnectionState.waiting) {
          return _LoadingView(isDark: isDark, cfg: cfg);
        }
        if (!(sensorSnap.data ?? true)) {
          return _NoSensorView(cfg: cfg);
        }

        return StreamBuilder<LocationStatus>(
          stream: _locationStream,
          builder: (context, locSnap) {
            if (locSnap.connectionState == ConnectionState.waiting) {
              return _LoadingView(isDark: isDark, cfg: cfg);
            }
            final loc = locSnap.data;
            if (loc == null || !loc.enabled) {
              return _LocationErrorView(
                message: "qibla.activate_location".tr(),
                onEnable: () async => await Geolocator.openLocationSettings(),
                cfg: cfg,
              );
            }
            if (loc.status == LocationPermission.denied ||
                loc.status == LocationPermission.deniedForever) {
              return _LocationErrorView(
                message: loc.status == LocationPermission.deniedForever
                    ? "qibla.permission_denied_forever".tr()
                    : "qibla.activate_location".tr(),
                onEnable: loc.status == LocationPermission.deniedForever
                    ? () async {
                        await Geolocator.openAppSettings();
                        await Future.delayed(const Duration(milliseconds: 500));
                        _checkLocationStatus();
                      }
                    : _checkLocationStatus,
                cfg: cfg,
              );
            }

            return _QiblaCompassWidget(calibNotifier: _calibNotifier, cfg: cfg);
          },
        );
      },
    );
  }
}

// ─── Loading View ─────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  final bool isDark;
  final _QiblaConfig cfg;

  const _LoadingView({required this.isDark, required this.cfg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.getPrimary(context),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            "common.loading".tr(),
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: cfg.bodyFontSize,
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
  final _QiblaConfig cfg;

  const _QiblaCompassWidget({required this.calibNotifier, required this.cfg});

  @override
  State<_QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<_QiblaCompassWidget>
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
          return _LoadingView(isDark: isDark, cfg: widget.cfg);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _NoSensorView(cfg: widget.cfg);
        }

        final data = snapshot.data!;
        final offset = _calculateOffset(data.direction, data.qiblah);
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
                          painter: _LockGlowPainter(
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
                      painter: _InnerRingPainter(
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
                            painter: _OrnamentalRingPainter(isDark: isDark),
                          ),
                          CustomPaint(
                            size: Size(
                              widget.cfg.compassSize,
                              widget.cfg.compassSize,
                            ),
                            painter: _CompassTicksPainter(isDark: isDark),
                          ),
                          _DirectionLabels(
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
                            painter: _CompassNeedlePainter(isDark: isDark),
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

// ─── Direction Labels ─────────────────────────────────────────────────────────
class _DirectionLabels extends StatelessWidget {
  final double size;
  final bool isDark;
  final _QiblaConfig cfg;

  const _DirectionLabels({
    required this.size,
    required this.isDark,
    required this.cfg,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: isDark ? AppColors.white : const Color(0xFF2D5F3F),
      fontWeight: FontWeight.bold,
      fontSize: (size * 0.055).clamp(13.0, 18.0),
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
                color: const Color(0xFF029E50),
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

// ─── No Sensor View ───────────────────────────────────────────────────────────
class _NoSensorView extends StatelessWidget {
  final _QiblaConfig cfg;
  const _NoSensorView({required this.cfg});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(cfg.hPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(cfg.isTablet ? 32 : 24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.sensors_off_rounded,
                size: cfg.isTablet ? 80 : 64,
                color: isDark ? AppColors.secondaryDark : AppColors.secondary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "qibla.sensor_error_title".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.textPrimary,
                fontSize: cfg.labelFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "qibla.sensor_error_desc".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textSecondary,
                fontSize: cfg.bodyFontSize,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location Error View ──────────────────────────────────────────────────────
class _LocationErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onEnable;
  final _QiblaConfig cfg;

  const _LocationErrorView({
    required this.message,
    this.onEnable,
    required this.cfg,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(cfg.hPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SvgPicture.asset(
              Assets.images.locationOff.path,
              width: cfg.isTablet ? 520 : 250.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: cfg.isTablet ? 40 : 24),
            Text(
              "qibla.location_error_title".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.textPrimary,
                fontSize: cfg.labelFontSize + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                fontSize: cfg.bodyFontSize + 2,
                height: 1.6,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: cfg.btnHeight + (cfg.isTablet ? 10 : 0),
              child: ElevatedButton(
                onPressed: onEnable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(context),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "qibla.activate".tr(),
                      style: TextStyle(
                        fontSize: cfg.isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.location_on, size: cfg.isTablet ? 28 : 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

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

/// Draws a subtle inner decorative ring inside the compass.
class _InnerRingPainter extends CustomPainter {
  final bool isDark;
  final bool isLocked;

  _InnerRingPainter({required this.isDark, required this.isLocked});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final color = isLocked
        ? const Color(0xFF029E50)
        : (isDark ? const Color(0xFF1B7A4A) : const Color(0xFF3A9D6A));

    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: isDark ? 0.18 : 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner ring
    canvas.drawCircle(
      center,
      radius * 0.82,
      Paint()
        ..color = color.withValues(alpha: isDark ? 0.10 : 0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 8 small diamond marks
    final diamondPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.35 : 0.25)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (math.pi / 180);
      final cx = center.dx + math.cos(angle) * radius;
      final cy = center.dy + math.sin(angle) * radius;
      final half = i % 2 == 0 ? 3.5 : 2.5;
      final path = Path()
        ..moveTo(cx, cy - half)
        ..lineTo(cx + half * 0.6, cy)
        ..lineTo(cx, cy + half)
        ..lineTo(cx - half * 0.6, cy)
        ..close();
      canvas.drawPath(path, diamondPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InnerRingPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.isLocked != isLocked;
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
