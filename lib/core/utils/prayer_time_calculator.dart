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

  /// Converts a standard [DateTime] (usually from adhan pkg) to a DST-aware [tz.TZDateTime].
  /// On older devices where the OS clock hasn't updated to DST, this correctly
  /// translates the moment into the wall-clock time expected in the timezone DB.
  static tz.TZDateTime toTZ(DateTime dateTime) {
    if (dateTime is tz.TZDateTime) return dateTime;
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Calculate prayer times and determine the next prayer.
  /// Returns a map with `prayerTimes`, `nextPrayer`, and `nextPrayerTime` (as [tz.TZDateTime]).
  static Map<String, dynamic> calculateWithNextPrayer({
    required double lat,
    required double lon,
    required tz.TZDateTime now,
  }) {
    final prayerTimes = calculateForDate(lat: lat, lon: lon, date: now);

    // Hardened manual detection of next prayer to handle DST-aware comparison
    final Map<Prayer, tz.TZDateTime?> times = {
      Prayer.fajr: toTZ(prayerTimes.fajr),
      Prayer.dhuhr: toTZ(prayerTimes.dhuhr),
      Prayer.asr: toTZ(prayerTimes.asr),
      Prayer.maghrib: toTZ(prayerTimes.maghrib),
      Prayer.isha: toTZ(prayerTimes.isha),
    };

    Prayer nextPrayer = Prayer.none;
    tz.TZDateTime? nextPrayerTime;

    // Ordered list for comparison
    const orderedPrayers = [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    for (final p in orderedPrayers) {
      final time = times[p];
      // Use a 30-second buffer to handle processing delay and prevent early skipping
      if (time != null &&
          time.isAfter(now.subtract(const Duration(seconds: 30)))) {
        nextPrayer = p;
        nextPrayerTime = time;
        break;
      }
    }

    if (nextPrayer == Prayer.none) {
      // All prayers passed today — next is tomorrow's Fajr
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowPrayers = calculateForDate(
        lat: lat,
        lon: lon,
        date: tomorrow,
      );
      nextPrayer = Prayer.fajr;
      nextPrayerTime = toTZ(tomorrowPrayers.fajr);
    }

    return {
      'prayerTimes': prayerTimes,
      'nextPrayer': nextPrayer,
      'nextPrayerTime': nextPrayerTime,
    };
  }
}
