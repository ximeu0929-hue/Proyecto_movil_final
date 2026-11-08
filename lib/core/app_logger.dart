import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/crash/crash_service.dart';

class AppLogger {
  AppLogger._();

  static bool crashlyticsEnabled = false;

  static void debug(String message) {
    if (kDebugMode) debugPrint('[DEBUG] $message');
  }

  static void warning(String message, {Object? error}) {
    debugPrint('[WARNING] $message');
    if (error != null) debugPrint('  causa: ${error.runtimeType}');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('  causa: $error');

    if (!crashlyticsEnabled) return;
    unawaited(const CrashService().recordNonFatal(
      error ?? Exception(message),
      stackTrace ?? StackTrace.current,
      reason: message,
    ));
  }
}
