import 'package:adhan/adhan.dart';
import 'package:timezone/timezone.dart' as tz;

/// Shared utility for calculating prayer times — used by both
/// [PrayerTimeCubit] and [AdhanSchedulerService] to avoid duplication.
class PrayerTimeCalculator {
  PrayerTimeCalculator._();

  /// Returns the appropriate [CalculationParameters] based on coordinates.
  static CalculationParameters getParams(double lat, double lon) {
    if (lat >= 22 && lat <= 32 && lon >= 25 && lon <= 37) {
      // Egypt / North Africa
      return CalculationMethod.egyptian.getParameters();
    } else if (lat >= 10 && lat <= 45 && lon >= 25 && lon <= 65) {
      // Middle East / South Asia
      return CalculationMethod.muslim_world_league.getParameters();
    } else if (lon <= -60) {
      // Americas
      return CalculationMethod.north_america.getParameters();
    } else {
      return CalculationMethod.muslim_world_league.getParameters();
    }
  }

  /// Calculate [PrayerTimes] for a specific [date] at [lat]/[lon].
  static PrayerTimes calculateForDate({
    required double lat,
    required double lon,
    required DateTime date,
  }) {
    final coordinates = Coordinates(lat, lon);
    final params = getParams(lat, lon);
    return PrayerTimes(coordinates, DateComponents.from(date), params);
  }

  /// Converts a [DateTime] (usually UTC from adhan pkg) to [tz.TZDateTime] using [tz.local].
  static tz.TZDateTime toTZ(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Calculate prayer times and determine the next prayer.
  /// Returns a map with `prayerTimes`, `nextPrayer`, and `nextPrayerTime` (as [tz.TZDateTime]).
  static Map<String, dynamic> calculateWithNextPrayer({
    required double lat,
    required double lon,
    required DateTime now,
  }) {
    final prayerTimes = calculateForDate(lat: lat, lon: lon, date: now);

    Prayer nextPrayer = prayerTimes.nextPrayer();
    DateTime? nextPrayerTime;

    if (nextPrayer != Prayer.none) {
      nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
    } else {
      // All prayers passed today — next is tomorrow's Fajr
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowPrayers = calculateForDate(
        lat: lat,
        lon: lon,
        date: tomorrow,
      );
      nextPrayer = Prayer.fajr;
      nextPrayerTime = tomorrowPrayers.fajr;
    }

    return {
      'prayerTimes': prayerTimes,
      'nextPrayer': nextPrayer,
      'nextPrayerTime': nextPrayerTime != null ? toTZ(nextPrayerTime) : null,
    };
  }
}
