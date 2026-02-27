import 'package:adhan/adhan.dart';

abstract class PrayerTimeState {}

class PrayerTimeInitial extends PrayerTimeState {}

class PrayerTimeLoading extends PrayerTimeState {}

class PrayerTimeLoaded extends PrayerTimeState {
  final PrayerTimes prayerTimes;
  final String cityName;
  final String countryName;
  final Prayer nextPrayer;
  final DateTime nextPrayerTime;

  PrayerTimeLoaded({
    required this.prayerTimes,
    required this.cityName,
    required this.countryName,
    required this.nextPrayer,
    required this.nextPrayerTime,
  });
}

class PrayerTimeLocationDenied extends PrayerTimeState {
  final String message;
  final bool isPermanentlyDenied;

  PrayerTimeLocationDenied({
    required this.message,
    this.isPermanentlyDenied = false,
  });
}

class PrayerTimeError extends PrayerTimeState {
  final String message;
  PrayerTimeError(this.message);
}
