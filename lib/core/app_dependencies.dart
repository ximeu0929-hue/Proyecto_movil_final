import 'package:flutter/material.dart';

import '../repositories/mesa_repository.dart';
import '../repositories/reserva_repository.dart';
import '../services/auth_service.dart';
import '../services/crash/crash_service.dart';
import '../services/preferences_service.dart';
import '../services/sync_service.dart';

class AppDependencies {
  final AuthService authService;
  final CrashService crashService;
  final MesaRepository mesaRepository;
  final ReservaRepository reservaRepository;
  final SyncService syncService;
  final PreferencesService preferences;
  final ValueNotifier<ThemeMode> themeMode;

  AppDependencies({
    required this.authService,
    required this.crashService,
    required this.mesaRepository,
    required this.reservaRepository,
    required this.syncService,
    required this.preferences,
    required this.themeMode,
  });
}
