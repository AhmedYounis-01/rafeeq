import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'prayer_time_state.dart';

class PrayerTimeCubit extends Cubit<PrayerTimeState> {
  PrayerTimeCubit() : super(PrayerTimeInitial());

  Future<void> loadPrayerTimes({bool isManual = false}) async {
    if (state is PrayerTimeLoading && !isManual) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final watch = Stopwatch()..start();
      emit(PrayerTimeLoading());
      try {
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

        if (isManual && !isManualLocation) {
          shouldTryAutomatic = true;
        }

        if (shouldTryAutomatic) {
          if (!isAuthorized && !hasAskedBefore) {
            await prefs.setBool('has_asked_location', true);
          }

          try {
            await _fetchWithPermission(isManual: isManual, stopwatch: watch);
            return;
          } catch (e) {
            if (savedLat != null && savedLon != null) {
              await _emitFromCoordinates(
                latitude: savedLat,
                longitude: savedLon,
                cityName: savedCity ?? 'موقع محفوظ',
                countryName: savedCountry ?? '',
                stopwatch: watch,
              );
              return;
            }
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
          if (!serviceEnabled)
            msg = 'خدمة الموقع غير مفعلة، يرجى تفعيلها أو تحديد الموقع يدوياً';

          emit(
            PrayerTimeLocationDenied(
              message: msg,
              isPermanentlyDenied:
                  permission == LocationPermission.deniedForever,
            ),
          );
        }
      } catch (e) {
        debugPrint('PrayerTimeCubit Error: $e');
        emit(PrayerTimeError('حدث خطأ: $e'));
      }
    });
  }

  Future<void> _fetchWithPermission({
    required bool isManual,
    required Stopwatch stopwatch,
  }) async {
    final result = await LocationService.requestAndGetLocation(
      forceRequest: isManual,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('location_lat', result.latitude);
    await prefs.setDouble('location_lon', result.longitude);
    await prefs.setString('location_city', result.cityName);
    await prefs.setString('location_country', result.countryName);
    await prefs.setBool('is_manual_location', false);

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
    // Reverting compute for now as per ChatGPT feedback (to prove if it's needed)
    final result = _calculatePrayerTimes({
      'lat': latitude,
      'lon': longitude,
      'now': DateTime.now(),
    });

    emit(
      PrayerTimeLoaded(
        prayerTimes: result['prayerTimes'] as PrayerTimes,
        cityName: cityName,
        countryName: countryName,
        nextPrayer: result['nextPrayer'] as Prayer,
        nextPrayerTime: result['nextPrayerTime'] as DateTime,
      ),
    );
    debugPrint(
      'Performance: Prayer times loaded in ${stopwatch.elapsedMilliseconds}ms',
    );
  }

  static Map<String, dynamic> _calculatePrayerTimes(Map<String, dynamic> data) {
    final lat = data['lat'] as double;
    final lon = data['lon'] as double;
    final now = data['now'] as DateTime;

    final coordinates = Coordinates(lat, lon);
    CalculationParameters params;
    if (lat >= 10 && lat <= 45 && lon >= 25 && lon <= 65) {
      params = CalculationMethod.muslim_world_league.getParameters();
    } else if (lat >= 22 && lat <= 32 && lon >= 25 && lon <= 37) {
      params = CalculationMethod.egyptian.getParameters();
    } else if (lon <= -60) {
      params = CalculationMethod.north_america.getParameters();
    } else {
      params = CalculationMethod.muslim_world_league.getParameters();
    }

    final date = DateComponents.from(now);
    final prayerTimes = PrayerTimes(coordinates, date, params);

    Prayer nextPrayer = prayerTimes.nextPrayer();
    DateTime? nextPrayerTime;

    if (nextPrayer != Prayer.none) {
      nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
    } else {
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowPrayers = PrayerTimes(
        coordinates,
        DateComponents.from(tomorrow),
        params,
      );
      nextPrayer = Prayer.fajr;
      nextPrayerTime = tomorrowPrayers.fajr;
    }

    return {
      'prayerTimes': prayerTimes,
      'nextPrayer': nextPrayer,
      'nextPrayerTime': nextPrayerTime,
    };
  }
}
