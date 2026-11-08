import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app_constants.dart';
import 'core/app_dependencies.dart';
import 'core/app_logger.dart';
import 'firebase_options.dart';
import 'local/app_database.dart';
import 'local/reserva_local_data_source.dart';
import 'remote/firestore_reserva_remote_data_source.dart';
import 'remote/perfil_remote_data_source.dart';
import 'repositories/mesa_repository.dart';
import 'repositories/reserva_repository_impl.dart';
import 'services/auth_service.dart';
import 'services/crash/crash_service.dart';
import 'services/mesa_service.dart';
import 'services/preferences_service.dart';
import 'services/sync_service.dart';
import 'views/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const crashService = CrashService();
  await crashService.configure();
  AppLogger.crashlyticsEnabled = true;

  final firestore = FirebaseFirestore.instance;
  final database = AppDatabase();

  final reservaRepository = ReservaRepositoryImpl(
    local: ReservaLocalDataSource(database),
    remote: FirestoreReservaRemoteDataSource(firestore),
  );

  final preferences = PreferencesService();

  final deps = AppDependencies(
    authService: FirebaseAuthService(
      perfiles: PerfilRemoteDataSource(firestore),
    ),
    crashService: crashService,
    mesaRepository: MesaRepository(
      service: MesaService(AppConstants.catalogoMesasUrl),
    ),
    reservaRepository: reservaRepository,
    syncService: SyncService(repository: reservaRepository),
    preferences: preferences,
    themeMode: ValueNotifier(await preferences.getTema()),
  );

  runApp(MyApp(deps: deps));
}

class MyApp extends StatelessWidget {
  final AppDependencies deps;

  const MyApp({super.key, required this.deps});

  static const _semilla = Color(0xFF4527A0);

  ThemeData _tema(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _semilla, brightness: brightness),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: deps.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Reservas G62-2',
          debugShowCheckedModeBanner: false,
          theme: _tema(Brightness.light),
          darkTheme: _tema(Brightness.dark),
          themeMode: themeMode,
          home: AuthGate(deps: deps),
        );
      },
    );
  }
}
