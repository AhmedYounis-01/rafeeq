import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:rafeeq/core/gen/assets.gen.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

// ─── Responsive Config ────────────────────────────────────────────────────────
class _QiblaConfig {
  final double shortestSide;
  _QiblaConfig(BuildContext context)
    : shortestSide = MediaQuery.of(context).size.shortestSide;

  bool get isTablet => shortestSide >= 600;

  double get kaabaPrefixSize => (shortestSide * 0.12).clamp(40.0, 80.0);
  double get arrowSize => (shortestSide * 0.09).clamp(32.0, 56.0);
  double get qiblaMarkerSize => (shortestSide * 0.11).clamp(38.0, 64.0);
  double get labelFontSize => (shortestSide * 0.045).clamp(16.0, 24.0);
  double get bodyFontSize => (shortestSide * 0.037).clamp(13.0, 19.0);
  double get iconSize => (shortestSide * 0.06).clamp(22.0, 34.0);
  double get btnHeight => (shortestSide * 0.13).clamp(48.0, 64.0);
  double get hPad => isTablet ? shortestSide * 0.06 : 24.0;
}

// ─── Helper ───────────────────────────────────────────────────────────────────
double _calculateOffset(double deviceDirection, double qiblahDirection) {
  double diff = qiblahDirection - deviceDirection;
  while (diff > 180) diff -= 360;
  while (diff < -180) diff += 360;
  return diff;
}

double _angleDiff(double target, double current) {
  double d = target - current;
  while (d > math.pi) d -= 2 * math.pi;
  while (d < -math.pi) d += 2 * math.pi;
  return d;
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
            // ── Top Bar ──
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: cfg.isTablet ? 16 : 8,
                vertical: 4,
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
            _CalibrationBanner(notifier: _calibNotifier, isDark: isDark),
            // ── Main Content ──
            Expanded(
              child: RefreshIndicator(
                onRefresh: _checkLocationStatus,
                color: AppColors.getPrimary(context),
                backgroundColor: isDark
                    ? const Color(0xFF0A1F17)
                    : AppColors.white,
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
          ],
        ),
      ),
    );
  }

  void _showInstructions(BuildContext context, bool isDark, _QiblaConfig cfg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: cfg.isTablet ? 560.0 : double.infinity,
      ),
      builder: (_) => Container(
        padding: EdgeInsets.all(cfg.isTablet ? 32 : 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1F18) : AppColors.backgroundLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: AppColors.getPrimary(context).withValues(alpha: 0.4),
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
                color: AppColors.getPrimary(context).withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.explore_rounded,
                color: AppColors.getPrimary(context),
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
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(context),
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
            const SizedBox(height: 16),
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

// ─── Calibration Banner ───────────────────────────────────────────────────────
class _CalibrationBanner extends StatelessWidget {
  final ValueNotifier<bool> notifier;
  final bool isDark;

  const _CalibrationBanner({required this.notifier, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (_, isUnstable, _) => AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        offset: isUnstable ? Offset.zero : const Offset(0, -1.5),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: isUnstable ? 1.0 : 0.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.6)
                  : AppColors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.rotate_90_degrees_ccw_outlined,
                  color: AppColors.warning,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "qibla.calibration_hint".tr(),
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
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
    with TickerProviderStateMixin {
  // ── Animations ──
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // ── ValueNotifiers للـ rotation (بدل setState في كل tick) ──
  final _compassAngleNotifier = ValueNotifier<double>(0);
  final _qiblaAngleNotifier = ValueNotifier<double>(0);
  final _isLockedNotifier = ValueNotifier<bool>(false);
  final _offsetNotifier = ValueNotifier<double>(0);

  // ── Internal tracking (not notifiers) ──
  double _compassAngle = 0;
  double _qiblaAngle = 0;
  double _targetCompassAngle = 0;
  double _targetQiblaAngle = 0;

  // ── State (تتغير مرة واحدة بس) ──
  bool _hasData = false;
  bool _hasError = false;

  // ── Ticker ──
  late final Ticker _ticker;
  StreamSubscription<QiblahDirection>? _qiblaSubscription;

  // ── Throttle ──
  DateTime? _lastUpdate;
  static const _kThrottle = Duration(milliseconds: 80);

  // ── Calibration ──
  final List<double> _recentDirs = [];
  Timer? _calibTimer;

  // ── Haptic ──
  DateTime? _lastVib;

  static const double _kLerpFactor = 0.18;

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

    _ticker = createTicker(_onTick)..start();

    _qiblaSubscription = FlutterQiblah.qiblahStream.listen(
      _onQiblahData,
      onError: (_) {
        if (mounted) setState(() => _hasError = true);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ── Pre-cache kaaba image ──
    precacheImage(AssetImage(Assets.images.kaaba.path), context);
  }

  @override
  void dispose() {
    _qiblaSubscription?.cancel();
    _ticker.dispose();
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    _calibTimer?.cancel();
    _compassAngleNotifier.dispose();
    _qiblaAngleNotifier.dispose();
    _isLockedNotifier.dispose();
    _offsetNotifier.dispose();
    super.dispose();
  }

  // ── Ticker: يحدّث الـ notifiers مباشرة بدون setState ──
  void _onTick(Duration _) {
    final newCompass =
        _compassAngle +
        _angleDiff(_targetCompassAngle, _compassAngle) * _kLerpFactor;
    final newQibla =
        _qiblaAngle + _angleDiff(_targetQiblaAngle, _qiblaAngle) * _kLerpFactor;

    if (_angleDiff(newCompass, _compassAngle).abs() > 0.0005 ||
        _angleDiff(newQibla, _qiblaAngle).abs() > 0.0005) {
      _compassAngle = newCompass;
      _qiblaAngle = newQibla;
      // ← لا setState هنا! بس تحديث الـ notifiers
      _compassAngleNotifier.value = newCompass;
      _qiblaAngleNotifier.value = newQibla;
    }
  }

  void _onQiblahData(QiblahDirection qd) {
    // setState مرة واحدة بس لما تيجي أول بيانات
    if (!_hasData && mounted) setState(() => _hasData = true);

    final now = DateTime.now();
    if (_lastUpdate != null && now.difference(_lastUpdate!) < _kThrottle) {
      return;
    }
    _lastUpdate = now;

    final offset = _calculateOffset(qd.direction, qd.qiblah);
    _targetCompassAngle = qd.direction * (math.pi / 180) * -1;
    _targetQiblaAngle = qd.qiblah * (math.pi / 180) * -1;

    // تحديث الـ offset بدون setState
    if ((_offsetNotifier.value - offset).abs() > 0.3) {
      _offsetNotifier.value = offset;
    }

    _sideEffects(qd, offset);
  }

  void _sideEffects(QiblahDirection qd, double offset) {
    if (!mounted) return;
    final absOff = offset.abs();

    // Calibration
    _recentDirs.add(qd.direction);
    if (_recentDirs.length > 20) _recentDirs.removeAt(0);
    if (_recentDirs.length == 20) {
      final span = _recentDirs.reduce(math.max) - _recentDirs.reduce(math.min);
      if (span > 35 && !widget.calibNotifier.value) {
        widget.calibNotifier.value = true;
        _calibTimer?.cancel();
        _calibTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) widget.calibNotifier.value = false;
        });
      }
    }

    // Pulse
    if (absOff <= 10) {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    } else {
      if (_pulseCtrl.isAnimating) {
        _pulseCtrl.stop();
        _pulseCtrl.reset();
      }
    }

    // Lock (بدون setState، بنستخدم الـ notifier)
    final nowLocked = absOff <= 3;
    if (nowLocked != _isLockedNotifier.value) {
      _isLockedNotifier.value = nowLocked;
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

    // Haptic
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
    final cfg = widget.cfg;
    const accent = Color(0xFFC9A24D);

    if (_hasError) return _NoSensorView(cfg: cfg);

    if (!_hasData) {
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
              // تم إضافة المفتاح الناقص في الترجمة
              "qibla.detecting".tr(),
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: cfg.bodyFontSize,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(height: cfg.isTablet ? 24 : 16),

        // ── أيقونة الكعبة (static - لا تتغير) ──
        Image.asset(
          Assets.images.kaaba.path,
          height: cfg.kaabaPrefixSize,
          width: cfg.kaabaPrefixSize,
        ),
        const SizedBox(height: 4),

        // ── سهم للأعلى (static) ──
        Icon(
          Icons.keyboard_arrow_up_rounded,
          color: accent,
          size: cfg.arrowSize,
        ),
        const SizedBox(height: 8),

        // ── البوصلة ──
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: cfg.hPad),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── Progress Arc: يستمع للـ offsetNotifier فقط ──
                    RepaintBoundary(
                      child: ValueListenableBuilder<double>(
                        valueListenable: _offsetNotifier,
                        builder: (_, offset, _) {
                          final progress =
                              1.0 - (offset.abs() / 90).clamp(0.0, 1.0);
                          return CustomPaint(
                            size: Size.infinite,
                            painter: _ProgressArcPainter(
                              progress: progress,
                              color: accent,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
                    ),

                    // ── Ornamental Ring (static - لا تتغير) ──
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _OrnamentalRingPainter(isDark: isDark),
                      ),
                    ),

                    // ── Lock Glow: يستمع للـ isLockedNotifier فقط ──
                    ValueListenableBuilder<bool>(
                      valueListenable: _isLockedNotifier,
                      builder: (_, isLocked, _) => isLocked
                          ? RepaintBoundary(
                              child: AnimatedBuilder(
                                animation: _glowAnim,
                                builder: (_, _) => CustomPaint(
                                  size: Size.infinite,
                                  painter: _LockGlowPainter(
                                    intensity: _glowAnim.value,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // ── Compass Disk: يستمع للـ compassAngleNotifier فقط ──
                    ValueListenableBuilder<double>(
                      valueListenable: _compassAngleNotifier,
                      builder: (_, angle, child) =>
                          Transform.rotate(angle: angle, child: child),
                      // child ثابت لا يُعاد بناؤه مع كل rotation
                      child: LayoutBuilder(
                        builder: (_, constraints) {
                          final outerSize = constraints.maxWidth;
                          final innerDiskSize = outerSize * 0.82;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
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
                              RepaintBoundary(
                                child: CustomPaint(
                                  size: Size(innerDiskSize, innerDiskSize),
                                  painter: _CompassTicksPainter(isDark: isDark),
                                ),
                              ),
                              _DirectionLabels(
                                size: outerSize,
                                isDark: isDark,
                                cfg: cfg,
                              ),
                              RepaintBoundary(
                                child: CustomPaint(
                                  size: Size(
                                    innerDiskSize * 0.72,
                                    innerDiskSize * 0.72,
                                  ),
                                  painter: _CompassNeedlePainter(
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // ── Qibla Marker: يستمع للـ qiblaAngleNotifier ──
                    ValueListenableBuilder<double>(
                      valueListenable: _qiblaAngleNotifier,
                      builder: (_, angle, _) => Transform.rotate(
                        angle: angle,
                        child: Align(
                          alignment: Alignment.topCenter,
                          // isLockedNotifier في داخل عشان الـ shadow يتحدث لما يتقفل
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isLockedNotifier,
                            builder: (_, isLocked, _) => AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, child) => Transform.scale(
                                scale: isLocked ? 1.0 : _pulseAnim.value,
                                child: child,
                              ),
                              child: Container(
                                width: cfg.qiblaMarkerSize,
                                height: cfg.qiblaMarkerSize,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? AppColors.white
                                      : const Color(0xFFFAF8F0),
                                  border: Border.all(color: accent, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withValues(
                                        alpha: isLocked ? 0.9 : 0.5,
                                      ),
                                      blurRadius: isLocked ? 20 : 10,
                                      spreadRadius: isLocked ? 4 : 1,
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
                                  margin: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF014D28),
                                  ),
                                  child: ClipOval(
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Lock / Near Banner: يستمع للـ notifiers فقط ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: cfg.hPad, vertical: 12),
          child: ValueListenableBuilder<bool>(
            valueListenable: _isLockedNotifier,
            builder: (_, isLocked, _) => ValueListenableBuilder<double>(
              valueListenable: _offsetNotifier,
              builder: (_, offset, _) {
                final absOff = offset.abs();
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: isLocked
                      ? _StatusBanner(
                          key: const ValueKey('locked'),
                          icon: Icons.check_circle_rounded,
                          label: "qibla.qibla_locked".tr(),
                          color: AppColors.getPrimary(context),
                          cfg: cfg,
                        )
                      : absOff <= 15
                      ? _StatusBanner(
                          key: const ValueKey('near'),
                          icon: Icons.my_location_rounded,
                          label: "qibla.almost_there".tr(),
                          color: accent,
                          cfg: cfg,
                        )
                      : const SizedBox(key: ValueKey('empty'), height: 0),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Status Banner ────────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final _QiblaConfig cfg;

  const _StatusBanner({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.cfg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: cfg.isTablet ? 14 : 11,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: cfg.iconSize),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: cfg.labelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Direction Labels (const-friendly) ────────────────────────────────────────
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
    final base = TextStyle(
      color: isDark ? AppColors.white : const Color(0xFF2D5F3F),
      fontWeight: FontWeight.bold,
      fontSize: (size * 0.055).clamp(13.0, 18.0),
      letterSpacing: 1.2,
    );
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: const Alignment(0, -0.68),
              child: Text(
                'N',
                style: base.copyWith(
                  color: AppColors.getPrimary(context),
                  fontSize: (base.fontSize ?? 14) + 2,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.68, 0),
              child: Text('E', style: base),
            ),
            Align(
              alignment: const Alignment(0, 0.68),
              child: Text('S', style: base),
            ),
            Align(
              alignment: const Alignment(-0.68, 0),
              child: Text('W', style: base),
            ),
          ],
        ),
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
            const SizedBox(height: 24),
            Text(
              "qibla.sensor_error_title".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.textPrimary,
                fontSize: cfg.labelFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cfg.hPad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SvgPicture.asset(
              Assets.images.locationOff.path,
              width: cfg.isTablet ? 250 : 200,
              height: cfg.isTablet ? 250 : 200,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "qibla.location_error_title".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.textPrimary,
              fontSize: cfg.labelFontSize + 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white60 : AppColors.textSecondary,
              fontSize: cfg.bodyFontSize,
              height: 1.6,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: cfg.btnHeight,
            child: ElevatedButton(
              onPressed: onEnable,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimary(context),
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_rounded, size: cfg.iconSize),
                  const SizedBox(width: 8),
                  Text(
                    "qibla.activate".tr(),
                    style: TextStyle(
                      fontSize: cfg.bodyFontSize + 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ─── Custom Painters ──────────────────────────────────────────────────────────
class _ProgressArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  const _ProgressArcPainter({
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
            ? AppColors.white.withValues(alpha: 0.06)
            : AppColors.black.withValues(alpha: 0.06)
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
  bool shouldRepaint(covariant _ProgressArcPainter old) =>
      old.progress != progress || old.color != color || old.isDark != isDark;
}

class _LockGlowPainter extends CustomPainter {
  final double intensity;
  final bool isDark;

  const _LockGlowPainter({required this.intensity, required this.isDark});

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
  bool shouldRepaint(covariant _LockGlowPainter old) =>
      old.intensity != intensity || old.isDark != isDark;
}

class _OrnamentalRingPainter extends CustomPainter {
  final bool isDark;

  const _OrnamentalRingPainter({required this.isDark});

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

    const petalCount = 16;
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
      canvas.drawCircle(pt, (i % 6 == 0) ? 2.5 : 1.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrnamentalRingPainter old) =>
      old.isDark != isDark;
}

class _CompassTicksPainter extends CustomPainter {
  final bool isDark;

  const _CompassTicksPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final tickColor = isDark ? AppColors.white : const Color(0xFF2D5F3F);

    for (int i = 0; i < 360; i += 5) {
      final angle = i * (math.pi / 180);
      final isMajor = i % 90 == 0;
      final isMinor = i % 30 == 0;
      final innerR = isMajor
          ? radius - 12
          : (isMinor ? radius - 8 : radius - 5);

      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * innerR,
          center.dy + math.sin(angle) * innerR,
        ),
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
        Paint()
          ..color = isMajor
              ? tickColor.withValues(alpha: 0.8)
              : (isMinor
                    ? tickColor.withValues(alpha: 0.4)
                    : tickColor.withValues(alpha: 0.15))
          ..strokeWidth = isMajor ? 2.0 : (isMinor ? 1.2 : 0.5)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassTicksPainter old) =>
      old.isDark != isDark;
}

class _CompassNeedlePainter extends CustomPainter {
  final bool isDark;

  const _CompassNeedlePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfW = size.width * 0.06;
    final len = size.height * 0.42;

    final primaryGreen = isDark ? AppColors.primaryDark : AppColors.primary;
    final secondaryGreen = isDark
        ? const Color(0xFF1B7A4A)
        : const Color(0xFF3A9D6A);
    final darkGreen = isDark
        ? const Color(0xFF0F2D1E)
        : const Color(0xFF2D7A4A);

    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - len)
        ..lineTo(center.dx - halfW, center.dy)
        ..lineTo(center.dx + halfW, center.dy)
        ..close(),
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

    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy + len)
        ..lineTo(center.dx - halfW, center.dy)
        ..lineTo(center.dx + halfW, center.dy)
        ..close(),
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

    canvas.drawPath(
      Path()
        ..moveTo(center.dx + len, center.dy)
        ..lineTo(center.dx, center.dy - halfW)
        ..lineTo(center.dx, center.dy + halfW)
        ..close(),
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

    canvas.drawPath(
      Path()
        ..moveTo(center.dx - len, center.dy)
        ..lineTo(center.dx, center.dy - halfW)
        ..lineTo(center.dx, center.dy + halfW)
        ..close(),
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
      canvas.drawPath(
        Path()
          ..moveTo(tipX, tipY)
          ..lineTo(
            center.dx + math.cos(perpAngle) * diagW,
            center.dy + math.sin(perpAngle) * diagW,
          )
          ..lineTo(
            center.dx - math.cos(perpAngle) * diagW,
            center.dy - math.sin(perpAngle) * diagW,
          )
          ..close(),
        diagPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassNeedlePainter old) =>
      old.isDark != isDark;
}
