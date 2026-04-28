import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:rafeeq/core/helpers/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/core/services/adhan_scheduler_service.dart';
import 'package:rafeeq/core/services/location_service.dart';
import 'package:rafeeq/core/utils/prayer_time_calculator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'prayer_time_state.dart';

class PrayerTimeCubit extends Cubit<PrayerTimeState> {
  PrayerTimeCubit() : super(PrayerTimeInitial());

  Timer? _adhanTimer;

  @override
  Future<void> close() {
    _adhanTimer?.cancel();
    return super.close();
  }

  Future<void> loadPrayerTimes({bool isManual = false}) async {
    if (state is PrayerTimeLoading && !isManual) return;

    final watch = Stopwatch()..start();
    emit(PrayerTimeLoading());
    try {
      // Refresh timezone to pick up DST changes (Egypt etc.)
      await AdhanSchedulerService.instance.refreshTimezone();

      final prefs = await SharedPreferences.getInstance();
      final hasAskedBefore = prefs.getBool('has_asked_location') ?? false;

      final savedLat = prefs.getDouble('location_lat');
      final savedLon = prefs.getDouble('location_lon');
      final savedCity = prefs.getString('location_city');
      final savedCountry = prefs.getString('location_country');

      final isManualLocation = prefs.getBool('is_manual_location') ?? false;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await LocationService.checkPermission();
      final isAuthorized =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      bool shouldTryAutomatic =
          !isManualLocation && isAuthorized && serviceEnabled;

      if (isManual) {
        shouldTryAutomatic = true;
      }

      if (shouldTryAutomatic) {
        if (!isAuthorized && !hasAskedBefore) {
          await prefs.setBool('has_asked_location', true);
        }

        try {
          await _fetchWithPermission(isManual: isManual, stopwatch: watch);
          return;
        } on LocationPermanentlyDeniedException {
          emit(
            PrayerTimeLocationDenied(
              message: 'تم رفض إذن الموقع نهائياً، يرجى تفعيله من الإعدادات',
              isPermanentlyDenied: true,
            ),
          );
          return;
        } catch (e) {
          AppLogger.warning(
            'Automatic fetch failed, falling back to saved: $e',
            tag: 'PrayerTimeCubit',
          );
        }
      }

      if (savedLat != null && savedLon != null) {
        await _emitFromCoordinates(
          latitude: savedLat,
          longitude: savedLon,
          cityName: savedCity ?? 'موقع محفوظ',
          countryName: savedCountry ?? '',
          stopwatch: watch,
        );
      } else {
        String msg = 'يُرجى تحديد موقعك لعرض مواقيت الصلاة';
        if (!serviceEnabled) {
          msg = 'خدمة الموقع غير مفعلة، يرجى تفعيلها أو تحديد الموقع يدوياً';
        }

        emit(
          PrayerTimeLocationDenied(
            message: msg,
            isPermanentlyDenied: permission == LocationPermission.deniedForever,
          ),
        );
      }
    } catch (e) {
      AppLogger.error(
        'PrayerTimeCubit Error',
        error: e,
        tag: 'PrayerTimeCubit',
      );
      emit(PrayerTimeError('حدث خطأ: $e'));
    }
  }

  Future<void> _fetchWithPermission({
    required bool isManual,
    required Stopwatch stopwatch,
  }) async {
    final result = await LocationService.requestAndGetLocation(
      forceRequest: isManual,
      useLastKnownIfAvailable: !isManual,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('location_lat', result.latitude);
    await prefs.setDouble('location_lon', result.longitude);
    await prefs.setString('location_city', result.cityName);
    await prefs.setString('location_country', result.countryName);
    await prefs.setBool('is_manual_location', false);

    // Re-schedule adhan notifications for new location
    await AdhanSchedulerService.instance.scheduleAdhanNotifications();

    await _emitFromCoordinates(
      latitude: result.latitude,
      longitude: result.longitude,
      cityName: result.cityName,
      countryName: result.countryName,
      stopwatch: stopwatch,
    );
  }

  Future<void> updateLocationManually({
    required double latitude,
    required double longitude,
    required String cityName,
    required String countryName,
  }) async {
    emit(PrayerTimeLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('location_lat', latitude);
      await prefs.setDouble('location_lon', longitude);
      await prefs.setString('location_city', cityName);
      await prefs.setString('location_country', countryName);
      await prefs.setBool('is_manual_location', true);

      // Re-schedule adhan notifications for new location
      await AdhanSchedulerService.instance.scheduleAdhanNotifications();

      await _emitFromCoordinates(
        latitude: latitude,
        longitude: longitude,
        cityName: cityName,
        countryName: countryName,
        stopwatch: Stopwatch()..start(),
      );
    } catch (e) {
      emit(PrayerTimeError('تعذر تحديث الموقع يدوياً: $e'));
    }
  }

  Future<void> _emitFromCoordinates({
    required double latitude,
    required double longitude,
    required String cityName,
    required String countryName,
    required Stopwatch stopwatch,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final result = PrayerTimeCalculator.calculateWithNextPrayer(
      lat: latitude,
      lon: longitude,
      now: now,
    );

    final nextPrayerTime = result['nextPrayerTime'] as DateTime;

    emit(
      PrayerTimeLoaded(
        prayerTimes: result['prayerTimes'] as PrayerTimes,
        cityName: cityName,
        countryName: countryName,
        nextPrayer: result['nextPrayer'] as Prayer,
        nextPrayerTime: nextPrayerTime,
      ),
    );

    // Schedule foreground adhan trigger
    _scheduleForegroundAdhan(nextPrayerTime);

    AppLogger.log(
      'Performance: Prayer times loaded in ${stopwatch.elapsedMilliseconds}ms',
      tag: 'PrayerTimeCubit',
    );
  }

  /// Schedules a timer to play adhan automatically if the app is open
  void _scheduleForegroundAdhan(DateTime time) {
    _adhanTimer?.cancel();

    final now = tz.TZDateTime.now(tz.local);
    final duration = time.difference(now);

    if (duration.isNegative) return;

    AppLogger.log(
      'Scheduling foreground adhan in ${duration.inMinutes}m ${duration.inSeconds % 60}s',
      tag: 'PrayerTimeCubit',
    );

    _adhanTimer = Timer(duration, () async {
      final soundEnabled = await AdhanSchedulerService.instance
          .isAdhanSoundEnabled();
      if (soundEnabled) {
        AppLogger.log('Foreground Adhan triggered!', tag: 'PrayerTimeCubit');
        await AdhanSchedulerService.instance.playFullAdhan();
      }
      // Reload UI and schedule next timer
      loadPrayerTimes();
    });
  }
}
