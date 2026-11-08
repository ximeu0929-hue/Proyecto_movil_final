import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/app_constants.dart';
import '../domain/reserva_exception.dart';
import '../domain/reserva_rules.dart';
import '../models/estado_reserva.dart';
import '../models/franja.dart';
import '../models/mesa.dart';
import '../models/ocupacion.dart';
import '../models/perfil.dart';
import '../models/reserva.dart';
import 'reserva_remote_data_source.dart';

class FirestoreReservaRemoteDataSource implements ReservaRemoteDataSource {
  final FirebaseFirestore firestore;

  FirestoreReservaRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _reservas =>
      firestore.collection('reservas');
  CollectionReference<Map<String, dynamic>> get _slots =>
      firestore.collection('slots');
  CollectionReference<Map<String, dynamic>> get _clienteFranja =>
      firestore.collection('cliente_franja');
  CollectionReference<Map<String, dynamic>> get _bloqueos =>
      firestore.collection('bloqueos');

  // Mapeo

  static DateTime? _fecha(Object? value) =>
      value is Timestamp ? value.toDate() : null;

  static Reserva fromMap(Map<String, dynamic> data) {
    return Reserva(
      id: data['id'] as String,
      clienteUid: data['clienteUid'] as String,
      clienteNombre: data['clienteNombre'] as String? ?? '',
      personas: (data['personas'] as num).toInt(),
      inicio: _fecha(data['inicio'])!,
      comentario: data['comentario'] as String? ?? '',
      estado: EstadoReserva.fromValue(data['estado'] as String),
      mesaId: data['mesaId'] as String?,
      mesaNombre: data['mesaNombre'] as String?,
      mesaCapacidad: (data['mesaCapacidad'] as num?)?.toInt(),
      motivoRechazo: data['motivoRechazo'] as String?,
      llegadaAt: _fecha(data['llegadaAt']),
      finalizadaAt: _fecha(data['finalizadaAt']),
      createdAt: _fecha(data['createdAt']) ?? DateTime.now(),
      updatedAt: _fecha(data['updatedAt']) ?? DateTime.now(),
      version: (data['version'] as num?)?.toInt() ?? 1,
      pendingSync: false,
    );
  }

  static Reserva _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    return fromMap(snap.data()!);
  }

  static Map<String, dynamic> toCreateMap(Reserva r) {
    return {
      'id': r.id,
      'clienteUid': r.clienteUid,
      'clienteNombre': r.clienteNombre,
      'personas': r.personas,
      'inicio': Timestamp.fromDate(r.inicio),
      'franjaId': r.franjaId,
      'dia': r.dia,
      'comentario': r.comentario,
      'estado': EstadoReserva.solicitada.value,
      'createdAt': Timestamp.fromDate(r.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'version': 1,
    };
  }

  Future<T> _guard<T>(Future<T> Function() operacion) async {
    try {
      return await operacion().timeout(AppConstants.firestoreTimeout);
    } on ReservaException {
      rethrow;
    } on TimeoutException {
      throw const RequiereConexion();
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw const PermisoDenegado();
        case 'unavailable':
        case 'deadline-exceeded':
          throw const RequiereConexion();
        case 'not-found':
          throw const ReservaNoEncontrada();
        default:
          rethrow;
      }
    }
  }

  // Lecturas

  @override
  Future<Reserva?> getReserva(String id) {
    return _guard(() async {
      final snap = await _reservas.doc(id).get();
      return snap.exists ? _fromSnapshot(snap) : null;
    });
  }

  @override
  Stream<List<Reserva>> watchReservasCliente(String uid) {
    return _reservas
        .where('clienteUid', isEqualTo: uid)
        .snapshots()
        .map((query) => query.docs.map(_fromSnapshot).toList());
  }

  @override
  Stream<List<Reserva>> watchReservasDelDia(String dia) {
    return _reservas.where('dia', isEqualTo: dia).snapshots().map((query) {
      final lista = query.docs.map(_fromSnapshot).toList();
      lista.sort((a, b) => a.inicio.compareTo(b.inicio));
      return lista;
    });
  }

  @override
  Stream<List<Ocupacion>> watchOcupacionDelDia(String dia) {
    return _slots
        .where('dia', isEqualTo: dia)
        .snapshots()
        .map(
          (query) => query.docs
              .map((doc) => Ocupacion.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  // Escrituras

  @override
  Future<Reserva> crearReserva(Reserva reserva) {
    return _guard(() {
      final ref = _reservas.doc(reserva.id);
      return firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        // ya existe: no se sobrescribe
        if (snap.exists) return _fromSnapshot(snap);

        tx.set(ref, toCreateMap(reserva));
        return reserva.copyWith(version: 1, pendingSync: false);
      });
    });
  }

  @override
  Future<Reserva> confirmar({
    required String reservaId,
    required int expectedVersion,
    required Mesa mesa,
    required Perfil actor,
  }) {
    return _guard(() {
      final ref = _reservas.doc(reservaId);
      return firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) throw const ReservaNoEncontrada();
        final actual = _fromSnapshot(snap);

        if (actual.version != expectedVersion) throw const ConflictoVersion();
        ReservaRules.validarTransicion(
          reserva: actual,
          destino: EstadoReserva.confirmada,
          rol: actor.rol,
          now: DateTime.now(),
        );
        if (!ReservaRules.tieneCapacidad(mesa, actual.personas)) {
          throw CapacidadInsuficiente(mesa.capacidad, actual.personas);
        }

        final slotId = Reserva.slotIdDe(mesa.id, actual.franjaId);
        final slotRef = _slots.doc(slotId);
        final lockRef = _clienteFranja.doc(actual.clienteFranjaId);

        final slotSnap = await tx.get(slotRef);
        if (slotSnap.exists) {
          final tipo = TipoOcupacion.fromValue(slotSnap.data()?['tipo'] as String?);
          throw tipo == TipoOcupacion.bloqueo
              ? const MesaBloqueada()
              : const MesaOcupada();
        }
        final lockSnap = await tx.get(lockRef);
        if (lockSnap.exists) throw const ReservaDuplicada();

        tx.set(slotRef, {
          'mesaId': mesa.id,
          'franjaId': actual.franjaId,
          'dia': actual.dia,
          'tipo': TipoOcupacion.reserva.value,
          'reservaId': actual.id,
          'createdBy': actor.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.set(lockRef, {
          'clienteUid': actual.clienteUid,
          'franjaId': actual.franjaId,
          'reservaId': actual.id,
        });

        final cambios = <String, dynamic>{
          'estado': EstadoReserva.confirmada.value,
          'mesaId': mesa.id,
          'mesaNombre': mesa.nombre,
          'mesaCapacidad': mesa.capacidad,
          'slotId': slotId,
          'decididoPor': actor.uid,
          'updatedAt': FieldValue.serverTimestamp(),
          'version': actual.version + 1,
        };
        tx.update(ref, cambios);

        return _aplicar(snap.data()!, cambios);
      });
    });
  }

  @override
  Future<Reserva> transicion({
    required String reservaId,
    required int expectedVersion,
    required EstadoReserva destino,
    required Perfil actor,
    String? motivo,
  }) {
    return _guard(() {
      final ref = _reservas.doc(reservaId);
      return firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) throw const ReservaNoEncontrada();
        final actual = _fromSnapshot(snap);

        if (actual.version != expectedVersion) throw const ConflictoVersion();
        ReservaRules.validarTransicion(
          reserva: actual,
          destino: destino,
          rol: actor.rol,
          now: DateTime.now(),
        );

        final cambios = <String, dynamic>{
          'estado': destino.value,
          'updatedAt': FieldValue.serverTimestamp(),
          'version': actual.version + 1,
        };

        switch (destino) {
          case EstadoReserva.rechazada:
            if (motivo == null || motivo.trim().isEmpty) {
              throw const MotivoRequerido();
            }
            cambios['motivoRechazo'] = motivo.trim();
            cambios['decididoPor'] = actor.uid;
          case EstadoReserva.cancelada:
            if (actual.clienteUid != actor.uid) throw const PermisoDenegado();
            cambios['canceladaAt'] = FieldValue.serverTimestamp();
            // libera mesa y candado
            if (actual.estado == EstadoReserva.confirmada) {
              tx.delete(_slots.doc(actual.slotId));
              tx.delete(_clienteFranja.doc(actual.clienteFranjaId));
            }
          case EstadoReserva.enMesa:
            cambios['llegadaAt'] = FieldValue.serverTimestamp();
            cambios['atendidoPor'] = actor.uid;
          case EstadoReserva.finalizada:
            cambios['finalizadaAt'] = FieldValue.serverTimestamp();
            cambios['atendidoPor'] = actor.uid;
          case EstadoReserva.ausente:
            cambios['ausenteAt'] = FieldValue.serverTimestamp();
            cambios['atendidoPor'] = actor.uid;
          default:
            throw TransicionInvalida(actual.estado.label, destino.label);
        }

        tx.update(ref, cambios);
        return _aplicar(snap.data()!, cambios);
      });
    });
  }

  static Reserva _aplicar(
    Map<String, dynamic> anterior,
    Map<String, dynamic> cambios,
  ) {
    final ahora = Timestamp.now();
    final combinado = {...anterior};
    cambios.forEach((key, value) {
      combinado[key] = value is FieldValue ? ahora : value;
    });
    return fromMap(combinado);
  }

  @override
  Future<void> bloquearMesa({
    required Mesa mesa,
    required Franja franja,
    required String motivo,
    required Perfil actor,
  }) {
    return _guard(() {
      final slotId = Reserva.slotIdDe(mesa.id, franja.id);
      final slotRef = _slots.doc(slotId);
      return firestore.runTransaction((tx) async {
        final slotSnap = await tx.get(slotRef);
        if (slotSnap.exists) {
          final tipo = TipoOcupacion.fromValue(slotSnap.data()?['tipo'] as String?);
          throw tipo == TipoOcupacion.bloqueo
              ? const MesaBloqueada()
              : const MesaOcupada();
        }

        final datos = {
          'mesaId': mesa.id,
          'franjaId': franja.id,
          'dia': franja.dia,
          'tipo': TipoOcupacion.bloqueo.value,
          'motivo': motivo,
          'createdBy': actor.uid,
          'createdAt': FieldValue.serverTimestamp(),
        };
        tx.set(slotRef, datos);
        tx.set(_bloqueos.doc(slotId), {
          ...datos,
          'mesaNombre': mesa.nombre,
          'inicio': Timestamp.fromDate(franja.inicio),
        });
      });
    });
  }

  @override
  Future<void> desbloquearMesa({required Ocupacion ocupacion}) {
    return _guard(() {
      final slotRef = _slots.doc(ocupacion.id);
      return firestore.runTransaction((tx) async {
        final slotSnap = await tx.get(slotRef);
        if (!slotSnap.exists) return;
        final tipo = TipoOcupacion.fromValue(slotSnap.data()?['tipo'] as String?);
        if (tipo != TipoOcupacion.bloqueo) throw const MesaOcupada();

        tx.delete(slotRef);
        tx.delete(_bloqueos.doc(ocupacion.id));
      });
    });
  }
}
