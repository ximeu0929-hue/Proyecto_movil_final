import 'dart:async';

import 'package:uuid/uuid.dart';

import '../core/app_logger.dart';
import '../domain/reserva_exception.dart';
import '../domain/reserva_rules.dart';
import '../local/reserva_local_data_source.dart';
import '../models/estado_reserva.dart';
import '../models/franja.dart';
import '../models/mesa.dart';
import '../models/ocupacion.dart';
import '../models/perfil.dart';
import '../models/reserva.dart';
import '../remote/reserva_remote_data_source.dart';
import 'reserva_repository.dart';

class ReservaRepositoryImpl implements ReservaRepository {
  final ReservaLocalDataSource local;
  final ReservaRemoteDataSource? remote;

  final DateTime Function() clock;
  final Uuid _uuid;

  ReservaRepositoryImpl({
    required this.local,
    this.remote,
    DateTime Function()? clock,
    Uuid? uuid,
  }) : clock = clock ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  StreamSubscription<List<Reserva>>? _escuchaCliente;

  ReservaRemoteDataSource _remoto() {
    final remoteSource = remote;
    if (remoteSource == null) throw const RequiereConexion();
    return remoteSource;
  }

  // Cliente: guardado local y sincronizacion

  @override
  Stream<List<Reserva>> watchMisReservas(String uid) => local.watchReservas(uid);

  @override
  Future<(Reserva, ResultadoEnvio)> solicitarReserva({
    required Perfil cliente,
    required int personas,
    required DateTime inicio,
    String comentario = '',
  }) async {
    final now = clock();
    ReservaRules.validarSolicitud(personas: personas, inicio: inicio, now: now);

    final existentes = await local.getReservas(cliente.uid);
    if (ReservaRules.tieneReservaEnFranja(existentes, Franja(inicio).id)) {
      throw const ReservaDuplicada();
    }

    // mismo id en todos los reintentos
    final reserva = Reserva(
      id: _uuid.v4(),
      clienteUid: cliente.uid,
      clienteNombre: cliente.nombre,
      personas: personas,
      inicio: inicio,
      comentario: comentario.trim(),
      estado: EstadoReserva.solicitada,
      createdAt: now,
      updatedAt: now,
      pendingSync: true,
    );

    // primero en Drift
    await local.save(reserva);
    AppLogger.debug('Reserva ${reserva.id} guardada en Drift (pendiente)');

    final resultado = await _enviar(reserva);
    return (await local.getById(reserva.id) ?? reserva, resultado);
  }

  @override
  Future<(Reserva, ResultadoEnvio)> corregirSolicitud({
    required Reserva reserva,
    required int personas,
    required DateTime inicio,
    String comentario = '',
  }) async {
    if (!reserva.pendingSync) {
      throw const TransicionInvalida('Sincronizada', 'Editada');
    }
    ReservaRules.validarSolicitud(
      personas: personas,
      inicio: inicio,
      now: clock(),
    );

    final existentes = await local.getReservas(reserva.clienteUid);
    if (ReservaRules.tieneReservaEnFranja(
      existentes,
      Franja(inicio).id,
      excluirId: reserva.id,
    )) {
      throw const ReservaDuplicada();
    }

    final corregida = reserva.copyWith(
      personas: personas,
      inicio: inicio,
      comentario: comentario.trim(),
      updatedAt: clock(),
      pendingSync: true,
      syncConflict: false,
      lastError: () => null,
      localVersion: reserva.localVersion + 1,
    );
    await local.save(corregida);

    final resultado = await _enviar(corregida);
    return (await local.getById(reserva.id) ?? corregida, resultado);
  }

  @override
  Future<void> descartarSolicitud(Reserva reserva) async {
    if (!reserva.pendingSync) {
      throw const TransicionInvalida('Sincronizada', 'Descartada');
    }
    await local.delete(reserva.id);
  }

  @override
  Future<ResultadoEnvio> reintentar(Reserva reserva) async {
    final actual = await local.getById(reserva.id);
    if (actual == null || !actual.pendingSync) return ResultadoEnvio.sincronizada;
    return _enviar(actual);
  }

  @override
  Future<(int sent, int failed)> syncPending(String uid) async {
    if (remote == null) return (0, 0);

    final pendientes = await local.getPending(uid);
    var sent = 0;
    var failed = 0;

    for (final reserva in pendientes) {
      final resultado = await _enviar(reserva);
      if (resultado == ResultadoEnvio.sincronizada) {
        sent++;
      } else {
        failed++;
      }
    }

    return (sent, failed);
  }

  Future<ResultadoEnvio> _enviar(Reserva reserva) async {
    final remoteSource = remote;
    if (remoteSource == null) return ResultadoEnvio.pendiente;

    try {
      final remota = await remoteSource.crearReserva(reserva);

      if (remota.version > 1 || remota.estado != EstadoReserva.solicitada) {
        // ya estaba en el servidor
        await local.save(remota);
        return ResultadoEnvio.sincronizada;
      }

      final marcada = await local.markSynced(reserva.id, reserva.localVersion);
      if (!marcada) {
        AppLogger.debug('Reserva ${reserva.id} editada durante el envio');
        return ResultadoEnvio.pendiente;
      }
      return ResultadoEnvio.sincronizada;
    } on RequiereConexion catch (e) {
      await local.markError(reserva.id, e.message);
      return ResultadoEnvio.pendiente;
    } on ReservaException catch (e) {
      AppLogger.warning('Servidor rechazo la reserva ${reserva.id}: ${e.runtimeType}');
      await local.markConflict(reserva.id, e.message);
      return ResultadoEnvio.rechazada;
    } catch (e, st) {
      AppLogger.error(
        'Error inesperado enviando la reserva ${reserva.id}',
        error: e,
        stackTrace: st,
      );
      await local.markError(reserva.id, 'No se pudo enviar. Intenta de nuevo.');
      return ResultadoEnvio.pendiente;
    }
  }

  @override
  Future<Reserva> cancelar({
    required Reserva reserva,
    required Perfil cliente,
  }) async {
    if (reserva.pendingSync) {
      await local.delete(reserva.id);
      return reserva.copyWith(estado: EstadoReserva.cancelada);
    }

    ReservaRules.validarTransicion(
      reserva: reserva,
      destino: EstadoReserva.cancelada,
      rol: cliente.rol,
      now: clock(),
    );

    final actualizada = await _ejecutarTransicion(
      reserva: reserva,
      destino: EstadoReserva.cancelada,
      actor: cliente,
    );
    await local.save(actualizada);
    return actualizada;
  }

  @override
  void iniciarEscuchaCliente(String uid) {
    detenerEscuchaCliente();
    final remoteSource = remote;
    if (remoteSource == null) return;

    _escuchaCliente = remoteSource.watchReservasCliente(uid).listen(
      (remotas) async {
        for (final remota in remotas) {
          await _fusionarRemota(remota);
        }
      },
      onError: (Object e) {
        AppLogger.warning('Escucha de reservas interrumpida', error: e);
      },
    );
  }

  @override
  void detenerEscuchaCliente() {
    _escuchaCliente?.cancel();
    _escuchaCliente = null;
  }

  Future<void> _fusionarRemota(Reserva remota) async {
    final actual = await local.getById(remota.id);
    if (actual != null && !actual.pendingSync && actual.version > remota.version) {
      return; // snapshot viejo
    }
    await local.save(remota);
  }

  // Administrador y anfitrion: siempre en linea

  @override
  Stream<List<Reserva>> watchReservasDelDia(DateTime dia) =>
      _remoto().watchReservasDelDia(Franja.diaId(dia));

  @override
  Stream<List<Ocupacion>> watchOcupacionDelDia(DateTime dia) =>
      _remoto().watchOcupacionDelDia(Franja.diaId(dia));

  @override
  Future<Reserva> confirmar({
    required Reserva reserva,
    required Mesa mesa,
    required Perfil admin,
  }) {
    ReservaRules.validarTransicion(
      reserva: reserva,
      destino: EstadoReserva.confirmada,
      rol: admin.rol,
      now: clock(),
    );
    if (!ReservaRules.tieneCapacidad(mesa, reserva.personas)) {
      throw CapacidadInsuficiente(mesa.capacidad, reserva.personas);
    }

    return _remoto().confirmar(
      reservaId: reserva.id,
      expectedVersion: reserva.version,
      mesa: mesa,
      actor: admin,
    );
  }

  @override
  Future<Reserva> rechazar({
    required Reserva reserva,
    required String motivo,
    required Perfil admin,
  }) {
    if (motivo.trim().isEmpty) throw const MotivoRequerido();
    return _ejecutarTransicion(
      reserva: reserva,
      destino: EstadoReserva.rechazada,
      actor: admin,
      motivo: motivo,
    );
  }

  @override
  Future<void> bloquearMesa({
    required Mesa mesa,
    required Franja franja,
    required String motivo,
    required Perfil admin,
  }) {
    if (motivo.trim().isEmpty) throw const MotivoRequerido();
    if (!ReservaRules.esFutura(franja.inicio, clock())) {
      throw const FechaNoFutura();
    }
    return _remoto().bloquearMesa(
      mesa: mesa,
      franja: franja,
      motivo: motivo.trim(),
      actor: admin,
    );
  }

  @override
  Future<void> desbloquearMesa(Ocupacion ocupacion) =>
      _remoto().desbloquearMesa(ocupacion: ocupacion);

  @override
  Future<Reserva> registrarLlegada({
    required Reserva reserva,
    required Perfil anfitrion,
  }) => _ejecutarTransicion(
    reserva: reserva,
    destino: EstadoReserva.enMesa,
    actor: anfitrion,
  );

  @override
  Future<Reserva> finalizar({
    required Reserva reserva,
    required Perfil anfitrion,
  }) => _ejecutarTransicion(
    reserva: reserva,
    destino: EstadoReserva.finalizada,
    actor: anfitrion,
  );

  @override
  Future<Reserva> marcarAusente({
    required Reserva reserva,
    required Perfil anfitrion,
  }) => _ejecutarTransicion(
    reserva: reserva,
    destino: EstadoReserva.ausente,
    actor: anfitrion,
  );

  Future<Reserva> _ejecutarTransicion({
    required Reserva reserva,
    required EstadoReserva destino,
    required Perfil actor,
    String? motivo,
  }) {
    ReservaRules.validarTransicion(
      reserva: reserva,
      destino: destino,
      rol: actor.rol,
      now: clock(),
    );
    return _remoto().transicion(
      reservaId: reserva.id,
      expectedVersion: reserva.version,
      destino: destino,
      actor: actor,
      motivo: motivo,
    );
  }
}
