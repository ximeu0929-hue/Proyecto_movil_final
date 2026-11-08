import 'package:flutter/foundation.dart';

class CrashService {
  const CrashService();

  Future<void> configure() async {
    debugPrint('[CrashService] Stub: sin Crashlytics');
  }

  Future<void> setUserIdentifier(String id) async {
    debugPrint('[CrashService] usuario asociado');
  }

  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    debugPrint('[CrashService] $reason: $error');
  }

  Future<void> simulateNonFatalError() async {
    try {
      throw Exception('Evento de prueba controlado G62-2');
    } catch (error, stackTrace) {
      await recordNonFatal(error, stackTrace, reason: 'Prueba QA');
    }
  }

  void simulateFatalCrash() {
    throw StateError('Crash fatal de prueba (stub)');
  }
}
