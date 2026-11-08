import 'package:drift/drift.dart';

import '../models/estado_reserva.dart';
import '../models/reserva.dart';
import 'app_database.dart';

class ReservaLocalDataSource {
  final AppDatabase db;

  ReservaLocalDataSource(this.db);

  Reserva _toDomain(ReservaRow row) {
    return Reserva(
      id: row.id,
      clienteUid: row.clienteUid,
      clienteNombre: row.clienteNombre,
      personas: row.personas,
      inicio: row.inicio,
      comentario: row.comentario,
      estado: EstadoReserva.fromValue(row.estado),
      mesaId: row.mesaId,
      mesaNombre: row.mesaNombre,
      mesaCapacidad: row.mesaCapacidad,
      motivoRechazo: row.motivoRechazo,
      llegadaAt: row.llegadaAt,
      finalizadaAt: row.finalizadaAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      version: row.version,
      pendingSync: row.pendingSync,
      lastError: row.lastError,
      syncConflict: row.syncConflict,
      localVersion: row.localVersion,
    );
  }

  ReservasCompanion _toCompanion(Reserva r) {
    return ReservasCompanion(
      id: Value(r.id),
      clienteUid: Value(r.clienteUid),
      clienteNombre: Value(r.clienteNombre),
      personas: Value(r.personas),
      inicio: Value(r.inicio),
      comentario: Value(r.comentario),
      estado: Value(r.estado.value),
      mesaId: Value(r.mesaId),
      mesaNombre: Value(r.mesaNombre),
      mesaCapacidad: Value(r.mesaCapacidad),
      motivoRechazo: Value(r.motivoRechazo),
      llegadaAt: Value(r.llegadaAt),
      finalizadaAt: Value(r.finalizadaAt),
      createdAt: Value(r.createdAt),
      updatedAt: Value(r.updatedAt),
      version: Value(r.version),
      pendingSync: Value(r.pendingSync),
      lastError: Value(r.lastError),
      syncConflict: Value(r.syncConflict),
      localVersion: Value(r.localVersion),
    );
  }

  SimpleSelectStatement<$ReservasTable, ReservaRow> _delUsuario(String uid) {
    return db.select(db.reservas)
      ..where((t) => t.clienteUid.equals(uid))
      ..orderBy([(t) => OrderingTerm.desc(t.inicio)]);
  }

  Stream<List<Reserva>> watchReservas(String uid) {
    return _delUsuario(uid).watch().map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<Reserva>> getReservas(String uid) async {
    final rows = await _delUsuario(uid).get();
    return rows.map(_toDomain).toList();
  }

  Future<Reserva?> getById(String id) async {
    final row = await (db.select(db.reservas)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<void> save(Reserva reserva) async {
    await db.into(db.reservas).insertOnConflictUpdate(_toCompanion(reserva));
  }

  Future<List<Reserva>> getPending(String uid) async {
    final rows =
        await (db.select(db.reservas)..where(
              (t) =>
                  t.clienteUid.equals(uid) &
                  t.pendingSync.equals(true) &
                  t.syncConflict.equals(false),
            ))
            .get();
    return rows.map(_toDomain).toList();
  }

  Future<bool> markSynced(String id, int localVersion) async {
    final updated =
        await (db.update(db.reservas)..where(
              (t) => t.id.equals(id) & t.localVersion.equals(localVersion),
            ))
            .write(
              const ReservasCompanion(
                pendingSync: Value(false),
                lastError: Value(null),
                syncConflict: Value(false),
              ),
            );
    return updated > 0;
  }

  Future<void> markError(String id, String message) async {
    await (db.update(db.reservas)..where((t) => t.id.equals(id))).write(
      ReservasCompanion(lastError: Value(message)),
    );
  }

  Future<void> markConflict(String id, String message) async {
    await (db.update(db.reservas)..where((t) => t.id.equals(id))).write(
      ReservasCompanion(
        lastError: Value(message),
        syncConflict: const Value(true),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (db.delete(db.reservas)..where((t) => t.id.equals(id))).go();
  }
}
