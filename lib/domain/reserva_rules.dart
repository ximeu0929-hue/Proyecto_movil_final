import '../core/app_constants.dart';
import '../models/estado_reserva.dart';
import '../models/franja.dart';
import '../models/mesa.dart';
import '../models/reserva.dart';
import '../models/rol.dart';
import 'reserva_exception.dart';
import 'reserva_state_machine.dart';

class ReservaRules {
  ReservaRules._();

  // Regla 1: reserva futura, 1 a 8 personas, franja fija

  static bool personasValidas(int personas) =>
      personas >= AppConstants.minPersonas &&
      personas <= AppConstants.maxPersonas;

  static bool esFutura(DateTime inicio, DateTime now) => inicio.isAfter(now);

  static void validarSolicitud({
    required int personas,
    required DateTime inicio,
    required DateTime now,
  }) {
    if (!personasValidas(personas)) throw const PersonasInvalidas();
    if (!Franja.esInicioValido(inicio)) throw const FranjaInvalida();
    if (!esFutura(inicio, now)) throw const FechaNoFutura();
  }

  // Regla 2: mesa con capacidad suficiente y libre

  static bool tieneCapacidad(Mesa mesa, int personas) =>
      mesa.capacidad >= personas;

  static List<Mesa> mesasValidas({
    required List<Mesa> mesas,
    required int personas,
    required Set<String> ocupadas,
  }) {
    final validas = mesas
        .where((m) => tieneCapacidad(m, personas) && !ocupadas.contains(m.id))
        .toList();
    // primero la mesa mas pequena que sirva
    validas.sort((a, b) => a.capacidad.compareTo(b.capacidad));
    return validas;
  }

  // Regla 3: una reserva activa por cliente y franja

  static bool tieneReservaEnFranja(
    Iterable<Reserva> delCliente,
    String franjaId, {
    String? excluirId,
  }) {
    return delCliente.any(
      (r) => r.id != excluirId && r.franjaId == franjaId && r.estado.isActiva,
    );
  }

  static bool puedeCancelar(Reserva reserva, DateTime now) {
    if (!ReservaStateMachine.canTransition(
      reserva.estado,
      EstadoReserva.cancelada,
      Rol.cliente,
    )) {
      return false;
    }
    final limite = reserva.inicio.subtract(AppConstants.plazoCancelacion);
    return !now.isAfter(limite);
  }

  // Regla 4: ventana de llegada y finalizacion

  static bool dentroDeVentanaLlegada(DateTime inicio, DateTime now) {
    final desde = inicio.subtract(AppConstants.margenLlegada);
    final hasta = inicio.add(AppConstants.margenLlegada);
    return !now.isBefore(desde) && !now.isAfter(hasta);
  }

  static bool puedeRegistrarLlegada(Reserva reserva, DateTime now) =>
      reserva.estado == EstadoReserva.confirmada &&
      dentroDeVentanaLlegada(reserva.inicio, now);

  static bool puedeMarcarAusente(Reserva reserva, DateTime now) =>
      reserva.estado == EstadoReserva.confirmada &&
      reserva.llegadaAt == null &&
      now.isAfter(reserva.inicio.add(AppConstants.margenLlegada));

  static bool puedeFinalizar(Reserva reserva) =>
      reserva.estado == EstadoReserva.enMesa;

  static bool estaVencida(Reserva reserva, DateTime now) {
    switch (reserva.estado) {
      case EstadoReserva.solicitada:
        return now.isAfter(reserva.inicio);
      case EstadoReserva.confirmada:
        return now.isAfter(reserva.inicio.add(AppConstants.margenLlegada));
      default:
        return false;
    }
  }

  static void validarTransicion({
    required Reserva reserva,
    required EstadoReserva destino,
    required Rol rol,
    required DateTime now,
  }) {
    if (!ReservaStateMachine.canTransition(reserva.estado, destino, rol)) {
      throw TransicionInvalida(reserva.estado.label, destino.label);
    }

    switch (destino) {
      case EstadoReserva.confirmada:
        if (!esFutura(reserva.inicio, now)) throw const FechaNoFutura();
      case EstadoReserva.cancelada:
        if (!puedeCancelar(reserva, now)) throw const FueraDePlazoCancelacion();
      case EstadoReserva.enMesa:
        if (!dentroDeVentanaLlegada(reserva.inicio, now)) {
          throw const FueraDeMargen();
        }
      case EstadoReserva.ausente:
        if (!puedeMarcarAusente(reserva, now)) {
          throw const AusenciaAnticipada();
        }
      default:
        break;
    }
  }
}
