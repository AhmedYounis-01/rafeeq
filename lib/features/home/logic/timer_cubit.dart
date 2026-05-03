import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TimerState {
  final String currentTime;
  final String amPm;
  final DateTime now;

  TimerState({
    required this.currentTime,
    required this.amPm,
    required this.now,
  });
}

class TimerCubit extends Cubit<TimerState> {
  Timer? _timer;

  TimerCubit()
    : super(
        TimerState(
          currentTime: DateFormat('hh:mm').format(DateTime.now()),
          amPm: DateFormat('a').format(DateTime.now()),
          now: DateTime.now(),
        ),
      ) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _emitCurrentTime();

    // Calculate seconds remaining until the next minute starts
    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;

    // Schedule the first update at the start of the next minute
    _timer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      _emitCurrentTime();
      // Then schedule periodic updates every minute
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _emitCurrentTime();
      });
    });
  }

  void _emitCurrentTime() {
    final now = DateTime.now();
    emit(
      TimerState(
        currentTime: DateFormat('hh:mm').format(now),
        amPm: DateFormat('a').format(now),
        now: now,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
