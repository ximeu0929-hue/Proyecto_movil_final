import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../core/app_logger.dart';
import '../repositories/reserva_repository.dart';

class SyncService {
  final ReservaRepository repository;
  final Connectivity connectivity;

  SyncService({required this.repository, Connectivity? connectivity})
    : connectivity = connectivity ?? Connectivity();

  final ValueNotifier<bool> offline = ValueNotifier(false);

  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _reintento;
  String? _uid;
  int _intentos = 0;
  bool _enCurso = false;

  static const _esperaBase = Duration(seconds: 5);
  static const _esperaMaxima = Duration(minutes: 2);

  Future<void> start(String uid) async {
    await stop();
    _uid = uid;

    try {
      offline.value = _sinRed(await connectivity.checkConnectivity());
    } catch (e) {
      AppLogger.warning('No se pudo leer el estado de la red', error: e);
    }

    _sub = connectivity.onConnectivityChanged.listen((resultados) {
      final estabaOffline = offline.value;
      offline.value = _sinRed(resultados);
      if (estabaOffline && !offline.value) {
        _intentos = 0;
        unawaited(sincronizar());
      }
    });

    unawaited(sincronizar());
  }

  Future<void> stop() async {
    _reintento?.cancel();
    _reintento = null;
    await _sub?.cancel();
    _sub = null;
    _uid = null;
    _intentos = 0;
  }

  Future<(int sent, int failed)> sincronizar() async {
    final uid = _uid;
    if (uid == null || _enCurso) return (0, 0);

    _enCurso = true;
    _reintento?.cancel();
    try {
      final (sent, failed) = await repository.syncPending(uid);
      if (sent > 0 || failed > 0) {
        AppLogger.debug('Sincronizacion: $sent enviadas, $failed fallidas');
      }
      if (failed > 0 && !offline.value) _programarReintento();
      if (failed == 0) _intentos = 0;
      return (sent, failed);
    } finally {
      _enCurso = false;
    }
  }

  void _programarReintento() {
    final espera = esperaParaIntento(_intentos);
    _intentos++;
    _reintento = Timer(espera, () => unawaited(sincronizar()));
  }

  @visibleForTesting
  static Duration esperaParaIntento(int intento) {
    final segundos = _esperaBase.inSeconds * (1 << intento.clamp(0, 10));
    return segundos > _esperaMaxima.inSeconds
        ? _esperaMaxima
        : Duration(seconds: segundos);
  }

  static bool _sinRed(List<ConnectivityResult> resultados) =>
      resultados.isEmpty ||
      resultados.every((r) => r == ConnectivityResult.none);
}
