import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Echo 💫
/// A creative logger with unique styles & sections.
/// Works for API, errors, warnings, debug, or just soul-friendly print lines.
///
/// Usage:
/// Echo.info("App started");
/// Echo.api("GET /users", data: {...}, response: {...});
/// Echo.error("Login failed", error: e, stack: st);
/// Echo.success("User created successfully!");
class EchoPrint {
  /// toggle logs off in production
  static bool enabled = kDebugMode;

  /// 🔹 Info Logs
  static void info(String message) {
    _log("💡 INFO", message, color: "\x1B[36m");
  }

  /// 🐛 Debug Logs
  static void debug(String message) {
    _log("🐛 DEBUG", message, color: "\x1B[35m");
  }

  /// ⚠️ Warning Logs
  static void warn(String message) {
    _log("⚠️ WARNING", message, color: "\x1B[33m");
  }

  /// ❌ Error Logs
  static void error(String message, {dynamic error, StackTrace? stack}) {
    _log(
      "❌ ERROR",
      "$message\nError: $error\nStack: $stack",
      color: "\x1B[31m",
    );
  }

  /// ✅ Success Logs
  static void success(String message) {
    _log("✅ SUCCESS", message, color: "\x1B[32m");
  }

  /// 🔥 Fatal / WTF
  static void fatal(String message) {
    _log("🔥 FATAL", message, color: "\x1B[41m");
  }

  /// 🌐 API Logs
  static void api(
    String endpoint, {
    String method = "GET",
    dynamic data,
    dynamic response,
  }) {
    final msg =
        """
🌐 API CALL
➡️ Endpoint: $endpoint
📡 Method: $method
📦 Request: $data
📬 Response: $response
""";
    _log("📡 API", msg, color: "\x1B[34m");
  }

  /// 📝 Simple Print (no styles)
  static void plain(dynamic message) {
    if (!enabled) return;
    debugPrint("📝 $message");
  }

  /// ✨ Core log method
  static void _log(String tag, String message, {String color = "\x1B[0m"}) {
    if (!enabled) return;

    final time = DateTime.now().toIso8601String();
    final formatted =
        """
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏰ $time | $tag
$color$message\x1B[0m
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
""";

    // print to console
    debugPrint(formatted);

    // also forward to Dart's developer log
    developer.log(message, name: tag);
  }
}
