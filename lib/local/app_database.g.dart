// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReservasTable extends Reservas
    with TableInfo<$ReservasTable, ReservaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReservasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clienteUidMeta = const VerificationMeta(
    'clienteUid',
  );
  @override
  late final GeneratedColumn<String> clienteUid = GeneratedColumn<String>(
    'cliente_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clienteNombreMeta = const VerificationMeta(
    'clienteNombre',
  );
  @override
  late final GeneratedColumn<String> clienteNombre = GeneratedColumn<String>(
    'cliente_nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personasMeta = const VerificationMeta(
    'personas',
  );
  @override
  late final GeneratedColumn<int> personas = GeneratedColumn<int>(
    'personas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<DateTime> inicio = GeneratedColumn<DateTime>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _comentarioMeta = const VerificationMeta(
    'comentario',
  );
  @override
  late final GeneratedColumn<String> comentario = GeneratedColumn<String>(
    'comentario',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mesaIdMeta = const VerificationMeta('mesaId');
  @override
  late final GeneratedColumn<String> mesaId = GeneratedColumn<String>(
    'mesa_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mesaNombreMeta = const VerificationMeta(
    'mesaNombre',
  );
  @override
  late final GeneratedColumn<String> mesaNombre = GeneratedColumn<String>(
    'mesa_nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mesaCapacidadMeta = const VerificationMeta(
    'mesaCapacidad',
  );
  @override
  late final GeneratedColumn<int> mesaCapacidad = GeneratedColumn<int>(
    'mesa_capacidad',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motivoRechazoMeta = const VerificationMeta(
    'motivoRechazo',
  );
  @override
  late final GeneratedColumn<String> motivoRechazo = GeneratedColumn<String>(
    'motivo_rechazo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _llegadaAtMeta = const VerificationMeta(
    'llegadaAt',
  );
  @override
  late final GeneratedColumn<DateTime> llegadaAt = GeneratedColumn<DateTime>(
    'llegada_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finalizadaAtMeta = const VerificationMeta(
    'finalizadaAt',
  );
  @override
  late final GeneratedColumn<DateTime> finalizadaAt = GeneratedColumn<DateTime>(
    'finalizada_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncConflictMeta = const VerificationMeta(
    'syncConflict',
  );
  @override
  late final GeneratedColumn<bool> syncConflict = GeneratedColumn<bool>(
    'sync_conflict',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_conflict" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteUid,
    clienteNombre,
    personas,
    inicio,
    comentario,
    estado,
    mesaId,
    mesaNombre,
    mesaCapacidad,
    motivoRechazo,
    llegadaAt,
    finalizadaAt,
    createdAt,
    updatedAt,
    version,
    pendingSync,
    lastError,
    syncConflict,
    localVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reservas';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReservaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cliente_uid')) {
      context.handle(
        _clienteUidMeta,
        clienteUid.isAcceptableOrUnknown(data['cliente_uid']!, _clienteUidMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteUidMeta);
    }
    if (data.containsKey('cliente_nombre')) {
      context.handle(
        _clienteNombreMeta,
        clienteNombre.isAcceptableOrUnknown(
          data['cliente_nombre']!,
          _clienteNombreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clienteNombreMeta);
    }
    if (data.containsKey('personas')) {
      context.handle(
        _personasMeta,
        personas.isAcceptableOrUnknown(data['personas']!, _personasMeta),
      );
    } else if (isInserting) {
      context.missing(_personasMeta);
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    } else if (isInserting) {
      context.missing(_inicioMeta);
    }
    if (data.containsKey('comentario')) {
      context.handle(
        _comentarioMeta,
        comentario.isAcceptableOrUnknown(data['comentario']!, _comentarioMeta),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('mesa_id')) {
      context.handle(
        _mesaIdMeta,
        mesaId.isAcceptableOrUnknown(data['mesa_id']!, _mesaIdMeta),
      );
    }
    if (data.containsKey('mesa_nombre')) {
      context.handle(
        _mesaNombreMeta,
        mesaNombre.isAcceptableOrUnknown(data['mesa_nombre']!, _mesaNombreMeta),
      );
    }
    if (data.containsKey('mesa_capacidad')) {
      context.handle(
        _mesaCapacidadMeta,
        mesaCapacidad.isAcceptableOrUnknown(
          data['mesa_capacidad']!,
          _mesaCapacidadMeta,
        ),
      );
    }
    if (data.containsKey('motivo_rechazo')) {
      context.handle(
        _motivoRechazoMeta,
        motivoRechazo.isAcceptableOrUnknown(
          data['motivo_rechazo']!,
          _motivoRechazoMeta,
        ),
      );
    }
    if (data.containsKey('llegada_at')) {
      context.handle(
        _llegadaAtMeta,
        llegadaAt.isAcceptableOrUnknown(data['llegada_at']!, _llegadaAtMeta),
      );
    }
    if (data.containsKey('finalizada_at')) {
      context.handle(
        _finalizadaAtMeta,
        finalizadaAt.isAcceptableOrUnknown(
          data['finalizada_at']!,
          _finalizadaAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('sync_conflict')) {
      context.handle(
        _syncConflictMeta,
        syncConflict.isAcceptableOrUnknown(
          data['sync_conflict']!,
          _syncConflictMeta,
        ),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReservaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReservaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clienteUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cliente_uid'],
      )!,
      clienteNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cliente_nombre'],
      )!,
      personas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}personas'],
      )!,
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio'],
      )!,
      comentario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comentario'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      mesaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mesa_id'],
      ),
      mesaNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mesa_nombre'],
      ),
      mesaCapacidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mesa_capacidad'],
      ),
      motivoRechazo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo_rechazo'],
      ),
      llegadaAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}llegada_at'],
      ),
      finalizadaAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finalizada_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      syncConflict: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_conflict'],
      )!,
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
    );
  }

  @override
  $ReservasTable createAlias(String alias) {
    return $ReservasTable(attachedDatabase, alias);
  }
}

class ReservaRow extends DataClass implements Insertable<ReservaRow> {
  final String id;
  final String clienteUid;
  final String clienteNombre;
  final int personas;
  final DateTime inicio;
  final String comentario;
  final String estado;
  final String? mesaId;
  final String? mesaNombre;
  final int? mesaCapacidad;
  final String? motivoRechazo;
  final DateTime? llegadaAt;
  final DateTime? finalizadaAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool pendingSync;
  final String? lastError;
  final bool syncConflict;
  final int localVersion;
  const ReservaRow({
    required this.id,
    required this.clienteUid,
    required this.clienteNombre,
    required this.personas,
    required this.inicio,
    required this.comentario,
    required this.estado,
    this.mesaId,
    this.mesaNombre,
    this.mesaCapacidad,
    this.motivoRechazo,
    this.llegadaAt,
    this.finalizadaAt,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.pendingSync,
    this.lastError,
    required this.syncConflict,
    required this.localVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cliente_uid'] = Variable<String>(clienteUid);
    map['cliente_nombre'] = Variable<String>(clienteNombre);
    map['personas'] = Variable<int>(personas);
    map['inicio'] = Variable<DateTime>(inicio);
    map['comentario'] = Variable<String>(comentario);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || mesaId != null) {
      map['mesa_id'] = Variable<String>(mesaId);
    }
    if (!nullToAbsent || mesaNombre != null) {
      map['mesa_nombre'] = Variable<String>(mesaNombre);
    }
    if (!nullToAbsent || mesaCapacidad != null) {
      map['mesa_capacidad'] = Variable<int>(mesaCapacidad);
    }
    if (!nullToAbsent || motivoRechazo != null) {
      map['motivo_rechazo'] = Variable<String>(motivoRechazo);
    }
    if (!nullToAbsent || llegadaAt != null) {
      map['llegada_at'] = Variable<DateTime>(llegadaAt);
    }
    if (!nullToAbsent || finalizadaAt != null) {
      map['finalizada_at'] = Variable<DateTime>(finalizadaAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['pending_sync'] = Variable<bool>(pendingSync);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['sync_conflict'] = Variable<bool>(syncConflict);
    map['local_version'] = Variable<int>(localVersion);
    return map;
  }

  ReservasCompanion toCompanion(bool nullToAbsent) {
    return ReservasCompanion(
      id: Value(id),
      clienteUid: Value(clienteUid),
      clienteNombre: Value(clienteNombre),
      personas: Value(personas),
      inicio: Value(inicio),
      comentario: Value(comentario),
      estado: Value(estado),
      mesaId: mesaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mesaId),
      mesaNombre: mesaNombre == null && nullToAbsent
          ? const Value.absent()
          : Value(mesaNombre),
      mesaCapacidad: mesaCapacidad == null && nullToAbsent
          ? const Value.absent()
          : Value(mesaCapacidad),
      motivoRechazo: motivoRechazo == null && nullToAbsent
          ? const Value.absent()
          : Value(motivoRechazo),
      llegadaAt: llegadaAt == null && nullToAbsent
          ? const Value.absent()
          : Value(llegadaAt),
      finalizadaAt: finalizadaAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizadaAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      pendingSync: Value(pendingSync),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      syncConflict: Value(syncConflict),
      localVersion: Value(localVersion),
    );
  }

  factory ReservaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReservaRow(
      id: serializer.fromJson<String>(json['id']),
      clienteUid: serializer.fromJson<String>(json['clienteUid']),
      clienteNombre: serializer.fromJson<String>(json['clienteNombre']),
      personas: serializer.fromJson<int>(json['personas']),
      inicio: serializer.fromJson<DateTime>(json['inicio']),
      comentario: serializer.fromJson<String>(json['comentario']),
      estado: serializer.fromJson<String>(json['estado']),
      mesaId: serializer.fromJson<String?>(json['mesaId']),
      mesaNombre: serializer.fromJson<String?>(json['mesaNombre']),
      mesaCapacidad: serializer.fromJson<int?>(json['mesaCapacidad']),
      motivoRechazo: serializer.fromJson<String?>(json['motivoRechazo']),
      llegadaAt: serializer.fromJson<DateTime?>(json['llegadaAt']),
      finalizadaAt: serializer.fromJson<DateTime?>(json['finalizadaAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      syncConflict: serializer.fromJson<bool>(json['syncConflict']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clienteUid': serializer.toJson<String>(clienteUid),
      'clienteNombre': serializer.toJson<String>(clienteNombre),
      'personas': serializer.toJson<int>(personas),
      'inicio': serializer.toJson<DateTime>(inicio),
      'comentario': serializer.toJson<String>(comentario),
      'estado': serializer.toJson<String>(estado),
      'mesaId': serializer.toJson<String?>(mesaId),
      'mesaNombre': serializer.toJson<String?>(mesaNombre),
      'mesaCapacidad': serializer.toJson<int?>(mesaCapacidad),
      'motivoRechazo': serializer.toJson<String?>(motivoRechazo),
      'llegadaAt': serializer.toJson<DateTime?>(llegadaAt),
      'finalizadaAt': serializer.toJson<DateTime?>(finalizadaAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'lastError': serializer.toJson<String?>(lastError),
      'syncConflict': serializer.toJson<bool>(syncConflict),
      'localVersion': serializer.toJson<int>(localVersion),
    };
  }

  ReservaRow copyWith({
    String? id,
    String? clienteUid,
    String? clienteNombre,
    int? personas,
    DateTime? inicio,
    String? comentario,
    String? estado,
    Value<String?> mesaId = const Value.absent(),
    Value<String?> mesaNombre = const Value.absent(),
    Value<int?> mesaCapacidad = const Value.absent(),
    Value<String?> motivoRechazo = const Value.absent(),
    Value<DateTime?> llegadaAt = const Value.absent(),
    Value<DateTime?> finalizadaAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? pendingSync,
    Value<String?> lastError = const Value.absent(),
    bool? syncConflict,
    int? localVersion,
  }) => ReservaRow(
    id: id ?? this.id,
    clienteUid: clienteUid ?? this.clienteUid,
    clienteNombre: clienteNombre ?? this.clienteNombre,
    personas: personas ?? this.personas,
    inicio: inicio ?? this.inicio,
    comentario: comentario ?? this.comentario,
    estado: estado ?? this.estado,
    mesaId: mesaId.present ? mesaId.value : this.mesaId,
    mesaNombre: mesaNombre.present ? mesaNombre.value : this.mesaNombre,
    mesaCapacidad: mesaCapacidad.present
        ? mesaCapacidad.value
        : this.mesaCapacidad,
    motivoRechazo: motivoRechazo.present
        ? motivoRechazo.value
        : this.motivoRechazo,
    llegadaAt: llegadaAt.present ? llegadaAt.value : this.llegadaAt,
    finalizadaAt: finalizadaAt.present ? finalizadaAt.value : this.finalizadaAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    pendingSync: pendingSync ?? this.pendingSync,
    lastError: lastError.present ? lastError.value : this.lastError,
    syncConflict: syncConflict ?? this.syncConflict,
    localVersion: localVersion ?? this.localVersion,
  );
  ReservaRow copyWithCompanion(ReservasCompanion data) {
    return ReservaRow(
      id: data.id.present ? data.id.value : this.id,
      clienteUid: data.clienteUid.present
          ? data.clienteUid.value
          : this.clienteUid,
      clienteNombre: data.clienteNombre.present
          ? data.clienteNombre.value
          : this.clienteNombre,
      personas: data.personas.present ? data.personas.value : this.personas,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      comentario: data.comentario.present
          ? data.comentario.value
          : this.comentario,
      estado: data.estado.present ? data.estado.value : this.estado,
      mesaId: data.mesaId.present ? data.mesaId.value : this.mesaId,
      mesaNombre: data.mesaNombre.present
          ? data.mesaNombre.value
          : this.mesaNombre,
      mesaCapacidad: data.mesaCapacidad.present
          ? data.mesaCapacidad.value
          : this.mesaCapacidad,
      motivoRechazo: data.motivoRechazo.present
          ? data.motivoRechazo.value
          : this.motivoRechazo,
      llegadaAt: data.llegadaAt.present ? data.llegadaAt.value : this.llegadaAt,
      finalizadaAt: data.finalizadaAt.present
          ? data.finalizadaAt.value
          : this.finalizadaAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      syncConflict: data.syncConflict.present
          ? data.syncConflict.value
          : this.syncConflict,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReservaRow(')
          ..write('id: $id, ')
          ..write('clienteUid: $clienteUid, ')
          ..write('clienteNombre: $clienteNombre, ')
          ..write('personas: $personas, ')
          ..write('inicio: $inicio, ')
          ..write('comentario: $comentario, ')
          ..write('estado: $estado, ')
          ..write('mesaId: $mesaId, ')
          ..write('mesaNombre: $mesaNombre, ')
          ..write('mesaCapacidad: $mesaCapacidad, ')
          ..write('motivoRechazo: $motivoRechazo, ')
          ..write('llegadaAt: $llegadaAt, ')
          ..write('finalizadaAt: $finalizadaAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('lastError: $lastError, ')
          ..write('syncConflict: $syncConflict, ')
          ..write('localVersion: $localVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteUid,
    clienteNombre,
    personas,
    inicio,
    comentario,
    estado,
    mesaId,
    mesaNombre,
    mesaCapacidad,
    motivoRechazo,
    llegadaAt,
    finalizadaAt,
    createdAt,
    updatedAt,
    version,
    pendingSync,
    lastError,
    syncConflict,
    localVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReservaRow &&
          other.id == this.id &&
          other.clienteUid == this.clienteUid &&
          other.clienteNombre == this.clienteNombre &&
          other.personas == this.personas &&
          other.inicio == this.inicio &&
          other.comentario == this.comentario &&
          other.estado == this.estado &&
          other.mesaId == this.mesaId &&
          other.mesaNombre == this.mesaNombre &&
          other.mesaCapacidad == this.mesaCapacidad &&
          other.motivoRechazo == this.motivoRechazo &&
          other.llegadaAt == this.llegadaAt &&
          other.finalizadaAt == this.finalizadaAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.pendingSync == this.pendingSync &&
          other.lastError == this.lastError &&
          other.syncConflict == this.syncConflict &&
          other.localVersion == this.localVersion);
}

class ReservasCompanion extends UpdateCompanion<ReservaRow> {
  final Value<String> id;
  final Value<String> clienteUid;
  final Value<String> clienteNombre;
  final Value<int> personas;
  final Value<DateTime> inicio;
  final Value<String> comentario;
  final Value<String> estado;
  final Value<String?> mesaId;
  final Value<String?> mesaNombre;
  final Value<int?> mesaCapacidad;
  final Value<String?> motivoRechazo;
  final Value<DateTime?> llegadaAt;
  final Value<DateTime?> finalizadaAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> pendingSync;
  final Value<String?> lastError;
  final Value<bool> syncConflict;
  final Value<int> localVersion;
  final Value<int> rowid;
  const ReservasCompanion({
    this.id = const Value.absent(),
    this.clienteUid = const Value.absent(),
    this.clienteNombre = const Value.absent(),
    this.personas = const Value.absent(),
    this.inicio = const Value.absent(),
    this.comentario = const Value.absent(),
    this.estado = const Value.absent(),
    this.mesaId = const Value.absent(),
    this.mesaNombre = const Value.absent(),
    this.mesaCapacidad = const Value.absent(),
    this.motivoRechazo = const Value.absent(),
    this.llegadaAt = const Value.absent(),
    this.finalizadaAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncConflict = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReservasCompanion.insert({
    required String id,
    required String clienteUid,
    required String clienteNombre,
    required int personas,
    required DateTime inicio,
    this.comentario = const Value.absent(),
    required String estado,
    this.mesaId = const Value.absent(),
    this.mesaNombre = const Value.absent(),
    this.mesaCapacidad = const Value.absent(),
    this.motivoRechazo = const Value.absent(),
    this.llegadaAt = const Value.absent(),
    this.finalizadaAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncConflict = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clienteUid = Value(clienteUid),
       clienteNombre = Value(clienteNombre),
       personas = Value(personas),
       inicio = Value(inicio),
       estado = Value(estado),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ReservaRow> custom({
    Expression<String>? id,
    Expression<String>? clienteUid,
    Expression<String>? clienteNombre,
    Expression<int>? personas,
    Expression<DateTime>? inicio,
    Expression<String>? comentario,
    Expression<String>? estado,
    Expression<String>? mesaId,
    Expression<String>? mesaNombre,
    Expression<int>? mesaCapacidad,
    Expression<String>? motivoRechazo,
    Expression<DateTime>? llegadaAt,
    Expression<DateTime>? finalizadaAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? pendingSync,
    Expression<String>? lastError,
    Expression<bool>? syncConflict,
    Expression<int>? localVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteUid != null) 'cliente_uid': clienteUid,
      if (clienteNombre != null) 'cliente_nombre': clienteNombre,
      if (personas != null) 'personas': personas,
      if (inicio != null) 'inicio': inicio,
      if (comentario != null) 'comentario': comentario,
      if (estado != null) 'estado': estado,
      if (mesaId != null) 'mesa_id': mesaId,
      if (mesaNombre != null) 'mesa_nombre': mesaNombre,
      if (mesaCapacidad != null) 'mesa_capacidad': mesaCapacidad,
      if (motivoRechazo != null) 'motivo_rechazo': motivoRechazo,
      if (llegadaAt != null) 'llegada_at': llegadaAt,
      if (finalizadaAt != null) 'finalizada_at': finalizadaAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (lastError != null) 'last_error': lastError,
      if (syncConflict != null) 'sync_conflict': syncConflict,
      if (localVersion != null) 'local_version': localVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReservasCompanion copyWith({
    Value<String>? id,
    Value<String>? clienteUid,
    Value<String>? clienteNombre,
    Value<int>? personas,
    Value<DateTime>? inicio,
    Value<String>? comentario,
    Value<String>? estado,
    Value<String?>? mesaId,
    Value<String?>? mesaNombre,
    Value<int?>? mesaCapacidad,
    Value<String?>? motivoRechazo,
    Value<DateTime?>? llegadaAt,
    Value<DateTime?>? finalizadaAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? pendingSync,
    Value<String?>? lastError,
    Value<bool>? syncConflict,
    Value<int>? localVersion,
    Value<int>? rowid,
  }) {
    return ReservasCompanion(
      id: id ?? this.id,
      clienteUid: clienteUid ?? this.clienteUid,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      personas: personas ?? this.personas,
      inicio: inicio ?? this.inicio,
      comentario: comentario ?? this.comentario,
      estado: estado ?? this.estado,
      mesaId: mesaId ?? this.mesaId,
      mesaNombre: mesaNombre ?? this.mesaNombre,
      mesaCapacidad: mesaCapacidad ?? this.mesaCapacidad,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      llegadaAt: llegadaAt ?? this.llegadaAt,
      finalizadaAt: finalizadaAt ?? this.finalizadaAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      pendingSync: pendingSync ?? this.pendingSync,
      lastError: lastError ?? this.lastError,
      syncConflict: syncConflict ?? this.syncConflict,
      localVersion: localVersion ?? this.localVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clienteUid.present) {
      map['cliente_uid'] = Variable<String>(clienteUid.value);
    }
    if (clienteNombre.present) {
      map['cliente_nombre'] = Variable<String>(clienteNombre.value);
    }
    if (personas.present) {
      map['personas'] = Variable<int>(personas.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<DateTime>(inicio.value);
    }
    if (comentario.present) {
      map['comentario'] = Variable<String>(comentario.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (mesaId.present) {
      map['mesa_id'] = Variable<String>(mesaId.value);
    }
    if (mesaNombre.present) {
      map['mesa_nombre'] = Variable<String>(mesaNombre.value);
    }
    if (mesaCapacidad.present) {
      map['mesa_capacidad'] = Variable<int>(mesaCapacidad.value);
    }
    if (motivoRechazo.present) {
      map['motivo_rechazo'] = Variable<String>(motivoRechazo.value);
    }
    if (llegadaAt.present) {
      map['llegada_at'] = Variable<DateTime>(llegadaAt.value);
    }
    if (finalizadaAt.present) {
      map['finalizada_at'] = Variable<DateTime>(finalizadaAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (syncConflict.present) {
      map['sync_conflict'] = Variable<bool>(syncConflict.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReservasCompanion(')
          ..write('id: $id, ')
          ..write('clienteUid: $clienteUid, ')
          ..write('clienteNombre: $clienteNombre, ')
          ..write('personas: $personas, ')
          ..write('inicio: $inicio, ')
          ..write('comentario: $comentario, ')
          ..write('estado: $estado, ')
          ..write('mesaId: $mesaId, ')
          ..write('mesaNombre: $mesaNombre, ')
          ..write('mesaCapacidad: $mesaCapacidad, ')
          ..write('motivoRechazo: $motivoRechazo, ')
          ..write('llegadaAt: $llegadaAt, ')
          ..write('finalizadaAt: $finalizadaAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('lastError: $lastError, ')
          ..write('syncConflict: $syncConflict, ')
          ..write('localVersion: $localVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReservasTable reservas = $ReservasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [reservas];
}

typedef $$ReservasTableCreateCompanionBuilder =
    ReservasCompanion Function({
      required String id,
      required String clienteUid,
      required String clienteNombre,
      required int personas,
      required DateTime inicio,
      Value<String> comentario,
      required String estado,
      Value<String?> mesaId,
      Value<String?> mesaNombre,
      Value<int?> mesaCapacidad,
      Value<String?> motivoRechazo,
      Value<DateTime?> llegadaAt,
      Value<DateTime?> finalizadaAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> version,
      Value<bool> pendingSync,
      Value<String?> lastError,
      Value<bool> syncConflict,
      Value<int> localVersion,
      Value<int> rowid,
    });
typedef $$ReservasTableUpdateCompanionBuilder =
    ReservasCompanion Function({
      Value<String> id,
      Value<String> clienteUid,
      Value<String> clienteNombre,
      Value<int> personas,
      Value<DateTime> inicio,
      Value<String> comentario,
      Value<String> estado,
      Value<String?> mesaId,
      Value<String?> mesaNombre,
      Value<int?> mesaCapacidad,
      Value<String?> motivoRechazo,
      Value<DateTime?> llegadaAt,
      Value<DateTime?> finalizadaAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<bool> pendingSync,
      Value<String?> lastError,
      Value<bool> syncConflict,
      Value<int> localVersion,
      Value<int> rowid,
    });

class $$ReservasTableFilterComposer
    extends Composer<_$AppDatabase, $ReservasTable> {
  $$ReservasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clienteUid => $composableBuilder(
    column: $table.clienteUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clienteNombre => $composableBuilder(
    column: $table.clienteNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get personas => $composableBuilder(
    column: $table.personas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mesaId => $composableBuilder(
    column: $table.mesaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mesaNombre => $composableBuilder(
    column: $table.mesaNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mesaCapacidad => $composableBuilder(
    column: $table.mesaCapacidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivoRechazo => $composableBuilder(
    column: $table.motivoRechazo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get llegadaAt => $composableBuilder(
    column: $table.llegadaAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finalizadaAt => $composableBuilder(
    column: $table.finalizadaAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncConflict => $composableBuilder(
    column: $table.syncConflict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReservasTableOrderingComposer
    extends Composer<_$AppDatabase, $ReservasTable> {
  $$ReservasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clienteUid => $composableBuilder(
    column: $table.clienteUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clienteNombre => $composableBuilder(
    column: $table.clienteNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get personas => $composableBuilder(
    column: $table.personas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mesaId => $composableBuilder(
    column: $table.mesaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mesaNombre => $composableBuilder(
    column: $table.mesaNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mesaCapacidad => $composableBuilder(
    column: $table.mesaCapacidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivoRechazo => $composableBuilder(
    column: $table.motivoRechazo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get llegadaAt => $composableBuilder(
    column: $table.llegadaAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finalizadaAt => $composableBuilder(
    column: $table.finalizadaAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncConflict => $composableBuilder(
    column: $table.syncConflict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReservasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReservasTable> {
  $$ReservasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clienteUid => $composableBuilder(
    column: $table.clienteUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clienteNombre => $composableBuilder(
    column: $table.clienteNombre,
    builder: (column) => column,
  );

  GeneratedColumn<int> get personas =>
      $composableBuilder(column: $table.personas, builder: (column) => column);

  GeneratedColumn<DateTime> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get mesaId =>
      $composableBuilder(column: $table.mesaId, builder: (column) => column);

  GeneratedColumn<String> get mesaNombre => $composableBuilder(
    column: $table.mesaNombre,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mesaCapacidad => $composableBuilder(
    column: $table.mesaCapacidad,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motivoRechazo => $composableBuilder(
    column: $table.motivoRechazo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get llegadaAt =>
      $composableBuilder(column: $table.llegadaAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finalizadaAt => $composableBuilder(
    column: $table.finalizadaAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get syncConflict => $composableBuilder(
    column: $table.syncConflict,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );
}

class $$ReservasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReservasTable,
          ReservaRow,
          $$ReservasTableFilterComposer,
          $$ReservasTableOrderingComposer,
          $$ReservasTableAnnotationComposer,
          $$ReservasTableCreateCompanionBuilder,
          $$ReservasTableUpdateCompanionBuilder,
          (
            ReservaRow,
            BaseReferences<_$AppDatabase, $ReservasTable, ReservaRow>,
          ),
          ReservaRow,
          PrefetchHooks Function()
        > {
  $$ReservasTableTableManager(_$AppDatabase db, $ReservasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReservasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReservasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReservasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clienteUid = const Value.absent(),
                Value<String> clienteNombre = const Value.absent(),
                Value<int> personas = const Value.absent(),
                Value<DateTime> inicio = const Value.absent(),
                Value<String> comentario = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> mesaId = const Value.absent(),
                Value<String?> mesaNombre = const Value.absent(),
                Value<int?> mesaCapacidad = const Value.absent(),
                Value<String?> motivoRechazo = const Value.absent(),
                Value<DateTime?> llegadaAt = const Value.absent(),
                Value<DateTime?> finalizadaAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> syncConflict = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReservasCompanion(
                id: id,
                clienteUid: clienteUid,
                clienteNombre: clienteNombre,
                personas: personas,
                inicio: inicio,
                comentario: comentario,
                estado: estado,
                mesaId: mesaId,
                mesaNombre: mesaNombre,
                mesaCapacidad: mesaCapacidad,
                motivoRechazo: motivoRechazo,
                llegadaAt: llegadaAt,
                finalizadaAt: finalizadaAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                pendingSync: pendingSync,
                lastError: lastError,
                syncConflict: syncConflict,
                localVersion: localVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clienteUid,
                required String clienteNombre,
                required int personas,
                required DateTime inicio,
                Value<String> comentario = const Value.absent(),
                required String estado,
                Value<String?> mesaId = const Value.absent(),
                Value<String?> mesaNombre = const Value.absent(),
                Value<int?> mesaCapacidad = const Value.absent(),
                Value<String?> motivoRechazo = const Value.absent(),
                Value<DateTime?> llegadaAt = const Value.absent(),
                Value<DateTime?> finalizadaAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> syncConflict = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReservasCompanion.insert(
                id: id,
                clienteUid: clienteUid,
                clienteNombre: clienteNombre,
                personas: personas,
                inicio: inicio,
                comentario: comentario,
                estado: estado,
                mesaId: mesaId,
                mesaNombre: mesaNombre,
                mesaCapacidad: mesaCapacidad,
                motivoRechazo: motivoRechazo,
                llegadaAt: llegadaAt,
                finalizadaAt: finalizadaAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                pendingSync: pendingSync,
                lastError: lastError,
                syncConflict: syncConflict,
                localVersion: localVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReservasTable, ReservaRow>(table),
                  BaseReferences<_$AppDatabase, $ReservasTable, ReservaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReservasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReservasTable,
      ReservaRow,
      $$ReservasTableFilterComposer,
      $$ReservasTableOrderingComposer,
      $$ReservasTableAnnotationComposer,
      $$ReservasTableCreateCompanionBuilder,
      $$ReservasTableUpdateCompanionBuilder,
      (ReservaRow, BaseReferences<_$AppDatabase, $ReservasTable, ReservaRow>),
      ReservaRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReservasTableTableManager get reservas =>
      $$ReservasTableTableManager(_db, _db.reservas);
}
