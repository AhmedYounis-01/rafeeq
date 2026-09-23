import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/extensions/theme_extension.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

import 'widgets/calibration_banner.dart';
import 'widgets/loading_view.dart';
import 'widgets/location_error_view.dart';
import 'widgets/no_sensor_view.dart';
import 'widgets/qibla_compass_widget.dart';
import 'widgets/qibla_config.dart';
import 'widgets/qibla_instructions_sheet.dart';

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
    final cfg = QiblaConfig(context);

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
                      onPressed: () =>
                          QiblaInstructionsSheet.show(context, isDark, cfg),
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
              CalibrationBanner(
                calibNotifier: _calibNotifier,
                isDark: isDark,
              ),
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

  Widget _buildCompassSection(bool isDark, QiblaConfig cfg) {
    return FutureBuilder<bool?>(
      future: _sensorSupportFuture,
      builder: (context, sensorSnap) {
        if (sensorSnap.connectionState == ConnectionState.waiting) {
          return LoadingView(isDark: isDark, cfg: cfg);
        }
        if (!(sensorSnap.data ?? true)) {
          return NoSensorView(cfg: cfg);
        }

        return StreamBuilder<LocationStatus>(
          stream: _locationStream,
          builder: (context, locSnap) {
            if (locSnap.connectionState == ConnectionState.waiting) {
              return LoadingView(isDark: isDark, cfg: cfg);
            }
            final loc = locSnap.data;
            if (loc == null || !loc.enabled) {
              return LocationErrorView(
                message: "qibla.activate_location".tr(),
                onEnable: () async => await Geolocator.openLocationSettings(),
                cfg: cfg,
              );
            }
            if (loc.status == LocationPermission.denied ||
                loc.status == LocationPermission.deniedForever) {
              return LocationErrorView(
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

            return QiblaCompassWidget(
              calibNotifier: _calibNotifier,
              cfg: cfg,
            );
          },
        );
      },
    );
  }
}
