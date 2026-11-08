import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashService {
  const CrashService();

  Future<void> configure() async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[FATAL] $error\n$stack');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  Future<void> setUserIdentifier(String id) {
    return FirebaseCrashlytics.instance.setUserIdentifier(id);
  }

  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) {
    return FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: false,
    );
  }

  Future<void> simulateNonFatalError() async {
    try {
      throw Exception('Evento de prueba controlado G62-2');
    } catch (error, stackTrace) {
      await recordNonFatal(
        error,
        stackTrace,
        reason: 'QA: verificacion de Crashlytics desde modo debug',
      );
      await FirebaseCrashlytics.instance.sendUnsentReports();
    }
  }

  void simulateFatalCrash() {
    FirebaseCrashlytics.instance.crash();
  }
}
