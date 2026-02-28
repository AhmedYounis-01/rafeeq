import 'package:adhan/adhan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prayer_time_state.dart';

class PrayerTimeCubit extends Cubit<PrayerTimeState> {
  PrayerTimeCubit() : super(PrayerTimeInitial());

  Future<void> loadPrayerTimes({bool isManual = false}) async {
    if (state is PrayerTimeLoading && !isManual) return;

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

      // Logic: If we have saved data and it's manual, use it.
      // If it's NOT manual, try to get GPS IF authorized.
      bool shouldTryAutomatic =
          !isManualLocation && isAuthorized && serviceEnabled;

      // If manual refresh, we might want to try automatic IF we aren't pinned to a manual location,
      // OR if we were never asked before.
      if (isManual && !isManualLocation) {
        shouldTryAutomatic = true;
      }

      if (shouldTryAutomatic) {
        if (!isAuthorized && !hasAskedBefore) {
          await prefs.setBool('has_asked_location', true);
        }

        try {
          await _fetchWithPermission(isManual: isManual);
          return; // Success
        } catch (e) {
          // If automatic fetch fails but we have saved data, use it!
          if (savedLat != null && savedLon != null) {
            await _emitFromCoordinates(
              latitude: savedLat,
              longitude: savedLon,
              cityName: savedCity ?? 'موقع محفوظ',
              countryName: savedCountry ?? '',
            );
            return;
          }
        }
      }

      // If we reach here, automatic fetch didn't happen or failed.
      if (savedLat != null && savedLon != null) {
        await _emitFromCoordinates(
          latitude: savedLat,
          longitude: savedLon,
          cityName: savedCity ?? 'موقع محفوظ',
          countryName: savedCountry ?? '',
        );
      } else {
        // No saved data and no automatic fetch possible
        String msg = 'يُرجى تحديد موقعك لعرض مواقيت الصلاة';
        if (!serviceEnabled)
          msg = 'خدمة الموقع غير مفعلة، يرجى تفعيلها أو تحديد الموقع يدوياً';

        emit(
          PrayerTimeLocationDenied(
            message: msg,
            isPermanentlyDenied: permission == LocationPermission.deniedForever,
          ),
        );
      }
    } catch (e) {
      print('PrayerTimeCubit Error (loadPrayerTimes): $e');
      emit(PrayerTimeError('حدث خطأ: $e'));
    }
  }

  Future<void> _fetchWithPermission({required bool isManual}) async {
    final result = await LocationService.requestAndGetLocation(
      forceRequest: isManual,
    );

    // Save it
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('location_lat', result.latitude);
    await prefs.setDouble('location_lon', result.longitude);
    await prefs.setString('location_city', result.cityName);
    await prefs.setString('location_country', result.countryName);
    await prefs.setBool(
      'is_manual_location',
      false,
    ); // This was an automatic fetch

    await _emitFromCoordinates(
      latitude: result.latitude,
      longitude: result.longitude,
      cityName: result.cityName,
      countryName: result.countryName,
    );
  }

  /// Selects the best Adhan calculation method based on region
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
      await prefs.setBool(
        'is_manual_location',
        true,
      ); // User manually picked this one

      await _emitFromCoordinates(
        latitude: latitude,
        longitude: longitude,
        cityName: cityName,
        countryName: countryName,
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
  }) async {
    final coordinates = Coordinates(latitude, longitude);
    final params = _getBestCalculationParams(latitude, longitude);
    final date = DateComponents.from(DateTime.now());

    final prayerTimes = PrayerTimes(coordinates, date, params);

    Prayer nextPrayer = prayerTimes.nextPrayer();
    DateTime? nextPrayerTime;

    if (nextPrayer != Prayer.none) {
      nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
    } else {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowPrayers = PrayerTimes(
        coordinates,
        DateComponents.from(tomorrow),
        params,
      );
      nextPrayer = Prayer.fajr;
      nextPrayerTime = tomorrowPrayers.fajr;
    }

    emit(
      PrayerTimeLoaded(
        prayerTimes: prayerTimes,
        cityName: cityName,
        countryName: countryName,
        nextPrayer: nextPrayer,
        nextPrayerTime: nextPrayerTime!,
      ),
    );
  }

  CalculationParameters _getBestCalculationParams(double lat, double lon) {
    // Middle East & North Africa → Muslim World League
    if (lat >= 10 && lat <= 45 && lon >= 25 && lon <= 65) {
      return CalculationMethod.muslim_world_league.getParameters();
    }
    // Egypt
    if (lat >= 22 && lat <= 32 && lon >= 25 && lon <= 37) {
      return CalculationMethod.egyptian.getParameters();
    }
    // North America
    if (lon <= -60) {
      return CalculationMethod.north_america.getParameters();
    }
    // Default fallback
    return CalculationMethod.muslim_world_league.getParameters();
  }
}
