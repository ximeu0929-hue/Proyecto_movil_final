import '../models/estado_reserva.dart';
import '../models/rol.dart';

class ReservaStateMachine {
  ReservaStateMachine._();

  static const Map<EstadoReserva, Map<EstadoReserva, Rol>> _transiciones = {
    EstadoReserva.solicitada: {
      EstadoReserva.confirmada: Rol.adminSalon,
      EstadoReserva.rechazada: Rol.adminSalon,
      EstadoReserva.cancelada: Rol.cliente,
    },
    EstadoReserva.confirmada: {
      EstadoReserva.enMesa: Rol.anfitrion,
      EstadoReserva.ausente: Rol.anfitrion,
      EstadoReserva.cancelada: Rol.cliente,
    },
    EstadoReserva.enMesa: {
      EstadoReserva.finalizada: Rol.anfitrion,
    },
  };

  static bool canTransition(EstadoReserva from, EstadoReserva to, Rol rol) {
    return _transiciones[from]?[to] == rol;
  }

  static List<EstadoReserva> siguientes(EstadoReserva from, Rol rol) {
    final destinos = _transiciones[from] ?? const {};
    return destinos.entries
        .where((entry) => entry.value == rol)
        .map((entry) => entry.key)
        .toList();
  }
}
