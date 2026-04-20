import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  /// Simple log message that only appears in Debug mode
  static void log(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'APP',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Error log message that only appears in Debug mode
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'ERROR',
        error: error,
        level: 1000,
        stackTrace: stackTrace,
      );
    }
  }

  /// Warning log message that only appears in Debug mode
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'WARNING', level: 900);
    }
  }
}
