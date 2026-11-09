import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:final_movil/core/hora_restaurante.dart';
import 'package:final_movil/domain/reserva_exception.dart';
import 'package:final_movil/local/app_database.dart';
import 'package:final_movil/local/reserva_local_data_source.dart';
import 'package:final_movil/models/estado_reserva.dart';
import 'package:final_movil/models/franja.dart';
import 'package:final_movil/models/mesa.dart';
import 'package:final_movil/models/ocupacion.dart';
import 'package:final_movil/models/perfil.dart';
import 'package:final_movil/models/reserva.dart';
import 'package:final_movil/models/rol.dart';
import 'package:final_movil/remote/reserva_remote_data_source.dart';
import 'package:final_movil/repositories/reserva_repository.dart';
import 'package:final_movil/repositories/reserva_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRemote implements ReservaRemoteDataSource {
  final Map<String, Reserva> reservas = {};
  final Set<String> slots = {};
  final Set<String> candados = {};
  bool offline = false;
  bool rechazarCreacion = false;
  int creaciones = 0;

  void _red() {
    if (offline) throw const RequiereConexion();
  }

  @override
  Future<Reserva> crearReserva(Reserva reserva) async {
    _red();
    if (rechazarCreacion) throw const PermisoDenegado();
    final existente = reservas[reserva.id];
    if (existente != null) return existente;
    creaciones++;
    final creada = reserva.copyWith(pendingSync: false, version: 1);
    reservas[reserva.id] = creada;
    return creada;
  }

  @override
  Future<Reserva> confirmar({
    required String reservaId,
    required int expectedVersion,
    required Mesa mesa,
    required Perfil actor,
  }) async {
    _red();
    final actual = reservas[reservaId]!;
    if (actual.version != expectedVersion) throw const ConflictoVersion();
    if (actual.estado != EstadoReserva.solicitada) {
      throw TransicionInvalida(actual.estado.label, 'Confirmada');
    }
    final slot = Reserva.slotIdDe(mesa.id, actual.franjaId);
    if (slots.contains(slot)) throw const MesaOcupada();
    if (candados.contains(actual.clienteFranjaId)) throw const ReservaDuplicada();
    slots.add(slot);
    candados.add(actual.clienteFranjaId);
    final confirmada = actual.copyWith(
      estado: EstadoReserva.confirmada,
      version: actual.version + 1,
    );
    reservas[reservaId] = confirmada;
    return confirmada;
  }

  @override
  Future<Reserva> transicion({
    required String reservaId,
    required int expectedVersion,
    required EstadoReserva destino,
    required Perfil actor,
    String? motivo,
  }) async {
    _red();
    final actual = reservas[reservaId]!;
    if (actual.version != expectedVersion) throw const ConflictoVersion();
    final nueva = actual.copyWith(estado: destino, version: actual.version + 1);
    reservas[reservaId] = nueva;
    return nueva;
  }

  @override
  Future<Reserva?> getReserva(String id) async => reservas[id];

  final snapshotsCliente = StreamController<List<Reserva>>.broadcast();

  @override
  Stream<List<Reserva>> watchReservasCliente(String uid) => snapshotsCliente.stream;

  @override
  Stream<List<Reserva>> watchReservasDelDia(String dia) => const Stream.empty();

  @override
  Stream<List<Ocupacion>> watchOcupacionDelDia(String dia) => const Stream.empty();

  @override
  Future<void> bloquearMesa({
    required Mesa mesa,
    required Franja franja,
    required String motivo,
    required Perfil actor,
  }) async {}

  @override
  Future<void> desbloquearMesa({required Ocupacion ocupacion}) async {}
}

const _ana = Perfil(uid: 'ana', email: 'ana@test.co', nombre: 'Ana', rol: Rol.cliente);
const _beto = Perfil(uid: 'beto', email: 'beto@test.co', nombre: 'Beto', rol: Rol.cliente);
const _admin = Perfil(uid: 'adm', email: 'adm@test.co', nombre: 'Admin', rol: Rol.adminSalon);

Mesa _mesa(String id, int capacidad) => Mesa(
  id: id,
  nombre: 'Mesa $id',
  capacidad: capacidad,
  ubicacion: 'Salon',
  caracteristicas: const [],
);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late ReservaLocalDataSource local;
  late FakeRemote remote;
  late ReservaRepositoryImpl repo;

  final ahora = HoraRestaurante.instante(2030, 3, 15, 10, 0);
  final cena = HoraRestaurante.instante(2030, 3, 15, 19, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = ReservaLocalDataSource(db);
    remote = FakeRemote();
    repo = ReservaRepositoryImpl(local: local, remote: remote, clock: () => ahora);
  });

  tearDown(() => db.close());

  test('sin conexion: se guarda en Drift como pendiente', () async {
    remote.offline = true;

    final (reserva, resultado) = await repo.solicitarReserva(
      cliente: _ana,
      personas: 4,
      inicio: cena,
    );

    expect(resultado, ResultadoEnvio.pendiente);
    final guardada = await local.getById(reserva.id);
    expect(guardada, isNotNull);
    expect(guardada!.pendingSync, isTrue);
    expect(guardada.estado, EstadoReserva.solicitada);
    expect(remote.reservas, isEmpty);
  });

  test('al volver la red sincroniza con el mismo id y sin duplicados', () async {
    remote.offline = true;
    final (reserva, _) = await repo.solicitarReserva(cliente: _ana, personas: 4, inicio: cena);

    remote.offline = false;
    final (sent, failed) = await repo.syncPending(_ana.uid);
    expect((sent, failed), (1, 0));

    // Reintentar otra vez no crea otro documento.
    await repo.reintentar(reserva);
    await repo.syncPending(_ana.uid);

    expect(remote.creaciones, 1);
    expect(remote.reservas.keys, [reserva.id]);
    expect((await local.getById(reserva.id))!.pendingSync, isFalse);
  });

  test('un reintento no sobrescribe la confirmacion del administrador', () async {
    final (reserva, _) = await repo.solicitarReserva(cliente: _ana, personas: 4, inicio: cena);
    final remota = remote.reservas[reserva.id]!;
    await repo.confirmar(reserva: remota, mesa: _mesa('M3', 4), admin: _admin);

    // se pierde la respuesta
    await local.save(reserva.copyWith(pendingSync: true));
    await repo.syncPending(_ana.uid);

    expect(remote.reservas[reserva.id]!.estado, EstadoReserva.confirmada);
    final localActual = await local.getById(reserva.id);
    expect(localActual!.estado, EstadoReserva.confirmada);
    expect(localActual.pendingSync, isFalse);
  });

  test('rechazo del servidor: guarda el motivo y no se reenvia solo', () async {
    remote.rechazarCreacion = true;
    final (reserva, resultado) = await repo.solicitarReserva(
      cliente: _ana,
      personas: 2,
      inicio: cena,
    );

    expect(resultado, ResultadoEnvio.rechazada);
    final guardada = (await local.getById(reserva.id))!;
    expect(guardada.syncConflict, isTrue);
    expect(guardada.lastError, isNotNull);

    final (sent, failed) = await repo.syncPending(_ana.uid);
    expect((sent, failed), (0, 0), reason: 'los conflictos esperan correccion');
  });

  test('corregir un intento rechazado lo reenvia con el mismo id', () async {
    remote.rechazarCreacion = true;
    final (reserva, _) = await repo.solicitarReserva(cliente: _ana, personas: 2, inicio: cena);

    remote.rechazarCreacion = false;
    final rechazada = (await local.getById(reserva.id))!;
    final (corregida, resultado) = await repo.corregirSolicitud(
      reserva: rechazada,
      personas: 3,
      inicio: cena,
    );

    expect(resultado, ResultadoEnvio.sincronizada);
    expect(corregida.id, reserva.id);
    expect(corregida.localVersion, 2);
    expect(remote.reservas[reserva.id]!.personas, 3);
  });

  test('una edicion local no se marca sincronizada por un envio anterior', () async {
    final reserva = Reserva(
      id: 'fijo',
      clienteUid: _ana.uid,
      clienteNombre: 'Ana',
      personas: 2,
      inicio: cena,
      estado: EstadoReserva.solicitada,
      createdAt: ahora,
      updatedAt: ahora,
      pendingSync: true,
      localVersion: 2,
    );
    await local.save(reserva);

    final marcada = await local.markSynced('fijo', 1);
    expect(marcada, isFalse);
    expect((await local.getById('fijo'))!.pendingSync, isTrue);
  });

  test('una correccion no se marca sincronizada si el envio anterior si llego', () async {
    final (reserva, _) = await repo.solicitarReserva(cliente: _ana, personas: 2, inicio: cena);

    await local.save(reserva.copyWith(pendingSync: true));
    final pendiente = (await local.getById(reserva.id))!;
    final (resultado, enviada) = await repo
        .corregirSolicitud(reserva: pendiente, personas: 5, inicio: cena)
        .then((r) => (r.$2, r.$1));

    expect(resultado, ResultadoEnvio.rechazada);
    expect(remote.creaciones, 1);
    expect(remote.reservas[reserva.id]!.personas, 2);
    expect(enviada.personas, 2);
    expect(enviada.pendingSync, isFalse);
    expect(enviada.lastError, ReservaRepositoryImpl.correccionNoAplicada);
  });

  test('la escucha acepta el servidor aunque baje la version si es mas reciente', () async {
    final vieja = Reserva(
      id: 'seed-confirmada',
      clienteUid: _ana.uid,
      clienteNombre: 'Ana',
      personas: 2,
      inicio: cena,
      estado: EstadoReserva.cancelada,
      createdAt: ahora.subtract(const Duration(days: 7)),
      updatedAt: ahora.subtract(const Duration(days: 6)),
      version: 3,
    );
    await local.save(vieja);

    repo.iniciarEscuchaCliente(_ana.uid);
    remote.snapshotsCliente.add([
      vieja.copyWith(estado: EstadoReserva.confirmada, version: 2, updatedAt: ahora),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final actual = (await local.getById('seed-confirmada'))!;
    expect(actual.estado, EstadoReserva.confirmada);
    expect(actual.version, 2);
    repo.detenerEscuchaCliente();
  });

  test('la escucha ignora un snapshot viejo que llega tarde', () async {
    final reciente = Reserva(
      id: 'r1',
      clienteUid: _ana.uid,
      clienteNombre: 'Ana',
      personas: 2,
      inicio: cena,
      estado: EstadoReserva.cancelada,
      createdAt: ahora,
      updatedAt: ahora,
      version: 3,
    );
    await local.save(reciente);

    repo.iniciarEscuchaCliente(_ana.uid);
    remote.snapshotsCliente.add([
      reciente.copyWith(
        estado: EstadoReserva.confirmada,
        version: 2,
        updatedAt: ahora.subtract(const Duration(minutes: 5)),
      ),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect((await local.getById('r1'))!.estado, EstadoReserva.cancelada);
    repo.detenerEscuchaCliente();
  });

  test('cada cuenta solo ve y sincroniza sus propias reservas', () async {
    remote.offline = true;
    await repo.solicitarReserva(cliente: _ana, personas: 2, inicio: cena);
    await repo.solicitarReserva(cliente: _beto, personas: 2, inicio: cena);

    expect(await local.getReservas(_ana.uid), hasLength(1));
    expect((await local.getPending(_beto.uid)).single.clienteUid, _beto.uid);

    remote.offline = false;
    final (sent, _) = await repo.syncPending(_beto.uid);
    expect(sent, 1);
    expect(remote.reservas.values.single.clienteUid, _beto.uid);
    expect((await local.getPending(_ana.uid)), hasLength(1));
  });

  test('regla 1: 9 personas no se guarda', () async {
    expect(
      repo.solicitarReserva(cliente: _ana, personas: 9, inicio: cena),
      throwsA(isA<PersonasInvalidas>()),
    );
  });

  test('regla 3: no permite dos solicitudes activas en la misma franja', () async {
    await repo.solicitarReserva(cliente: _ana, personas: 2, inicio: cena);
    expect(
      repo.solicitarReserva(cliente: _ana, personas: 3, inicio: cena),
      throwsA(isA<ReservaDuplicada>()),
    );
  });

  test('escenario 1: una mesa pequena no se asigna a un grupo mayor', () async {
    final (reserva, _) = await repo.solicitarReserva(cliente: _ana, personas: 6, inicio: cena);
    expect(
      () => repo.confirmar(
        reserva: remote.reservas[reserva.id]!,
        mesa: _mesa('M1', 2),
        admin: _admin,
      ),
      throwsA(isA<CapacidadInsuficiente>()),
    );
    expect(remote.slots, isEmpty);
  });

  test('escenario 2: dos confirmaciones no ocupan la misma mesa y franja', () async {
    final (a, _) = await repo.solicitarReserva(cliente: _ana, personas: 2, inicio: cena);
    final (b, _) = await repo.solicitarReserva(cliente: _beto, personas: 2, inicio: cena);
    final mesa = _mesa('M2', 4);

    final resultados = await Future.wait([
      repo
          .confirmar(reserva: remote.reservas[a.id]!, mesa: mesa, admin: _admin)
          .then<Object>((r) => r, onError: (Object e) => e),
      repo
          .confirmar(reserva: remote.reservas[b.id]!, mesa: mesa, admin: _admin)
          .then<Object>((r) => r, onError: (Object e) => e),
    ]);

    expect(resultados.whereType<Reserva>(), hasLength(1));
    expect(resultados.whereType<MesaOcupada>(), hasLength(1));
    expect(remote.slots, hasLength(1));
  });

  test('el cliente no puede confirmar su propia reserva', () async {
    final (reserva, _) = await repo.solicitarReserva(cliente: _ana, personas: 2, inicio: cena);
    expect(
      () => repo.confirmar(
        reserva: remote.reservas[reserva.id]!,
        mesa: _mesa('M2', 4),
        admin: _ana,
      ),
      throwsA(isA<TransicionInvalida>()),
    );
  });
}
