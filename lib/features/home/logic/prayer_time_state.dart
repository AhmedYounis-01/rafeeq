import 'package:adhan/adhan.dart';
import 'package:equatable/equatable.dart';

abstract class PrayerTimeState extends Equatable {
  @override
  List<Object?> get props => [];
}

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

  @override
  List<Object?> get props => [
    prayerTimes,
    cityName,
    countryName,
    nextPrayer,
    nextPrayerTime,
  ];
}

class PrayerTimeLocationDenied extends PrayerTimeState {
  final String message;
  final bool isPermanentlyDenied;

  PrayerTimeLocationDenied({
    required this.message,
    this.isPermanentlyDenied = false,
  });

  @override
  List<Object?> get props => [message, isPermanentlyDenied];
}

class PrayerTimeError extends PrayerTimeState {
  final String message;
  PrayerTimeError(this.message);

  @override
  List<Object?> get props => [message];
}
