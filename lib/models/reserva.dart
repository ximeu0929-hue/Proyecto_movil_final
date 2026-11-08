import 'estado_reserva.dart';
import 'franja.dart';

class Reserva {
  final String id;
  final String clienteUid;
  final String clienteNombre;
  final int personas;
  final DateTime inicio;
  final String comentario;
  final EstadoReserva estado;

  final String? mesaId;
  final String? mesaNombre;
  final int? mesaCapacidad;
  final String? motivoRechazo;
  final DateTime? llegadaAt;
  final DateTime? finalizadaAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  final int version;

  // Solo locales
  final bool pendingSync;
  final String? lastError;
  final bool syncConflict;

  final int localVersion;

  const Reserva({
    required this.id,
    required this.clienteUid,
    required this.clienteNombre,
    required this.personas,
    required this.inicio,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.comentario = '',
    this.mesaId,
    this.mesaNombre,
    this.mesaCapacidad,
    this.motivoRechazo,
    this.llegadaAt,
    this.finalizadaAt,
    this.version = 1,
    this.pendingSync = false,
    this.lastError,
    this.syncConflict = false,
    this.localVersion = 1,
  });

  Franja get franja => Franja(inicio);
  String get franjaId => franja.id;
  String get dia => franja.dia;

  String? get slotId => mesaId == null ? null : slotIdDe(mesaId!, franjaId);

  static String slotIdDe(String mesaId, String franjaId) => '${mesaId}_$franjaId';

  String get clienteFranjaId => '${clienteUid}_$franjaId';

  Reserva copyWith({
    int? personas,
    DateTime? inicio,
    String? comentario,
    EstadoReserva? estado,
    DateTime? updatedAt,
    int? version,
    bool? pendingSync,
    String? Function()? lastError,
    bool? syncConflict,
    int? localVersion,
  }) {
    return Reserva(
      id: id,
      clienteUid: clienteUid,
      clienteNombre: clienteNombre,
      personas: personas ?? this.personas,
      inicio: inicio ?? this.inicio,
      comentario: comentario ?? this.comentario,
      estado: estado ?? this.estado,
      mesaId: mesaId,
      mesaNombre: mesaNombre,
      mesaCapacidad: mesaCapacidad,
      motivoRechazo: motivoRechazo,
      llegadaAt: llegadaAt,
      finalizadaAt: finalizadaAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      pendingSync: pendingSync ?? this.pendingSync,
      lastError: lastError != null ? lastError() : this.lastError,
      syncConflict: syncConflict ?? this.syncConflict,
      localVersion: localVersion ?? this.localVersion,
    );
  }
}
