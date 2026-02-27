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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      emit(
        TimerState(
          currentTime: DateFormat('hh:mm').format(now),
          amPm: DateFormat('a').format(now),
          now: now,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
