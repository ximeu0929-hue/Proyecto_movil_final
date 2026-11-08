import 'package:drift/drift.dart';

@DataClassName('ReservaRow')
class Reservas extends Table {
  TextColumn get id => text()();
  TextColumn get clienteUid => text()();
  TextColumn get clienteNombre => text()();
  IntColumn get personas => integer()();
  DateTimeColumn get inicio => dateTime()();
  TextColumn get comentario => text().withDefault(const Constant(''))();
  TextColumn get estado => text()();

  TextColumn get mesaId => text().nullable()();
  TextColumn get mesaNombre => text().nullable()();
  IntColumn get mesaCapacidad => integer().nullable()();
  TextColumn get motivoRechazo => text().nullable()();
  DateTimeColumn get llegadaAt => dateTime().nullable()();
  DateTimeColumn get finalizadaAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // Sincronizacion
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  TextColumn get lastError => text().nullable()();
  BoolColumn get syncConflict => boolean().withDefault(const Constant(false))();
  IntColumn get localVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
