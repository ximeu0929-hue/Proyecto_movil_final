sealed class ReservaException implements Exception {
  final String message;
  const ReservaException(this.message);

  @override
  String toString() => message;
}

class PersonasInvalidas extends ReservaException {
  const PersonasInvalidas()
    : super('La reserva debe ser para 1 a 8 personas.');
}

class FechaNoFutura extends ReservaException {
  const FechaNoFutura() : super('La franja seleccionada ya paso. Elige una futura.');
}

class FranjaInvalida extends ReservaException {
  const FranjaInvalida()
    : super('Solo se puede reservar en las franjas fijas de 90 minutos.');
}

class CapacidadInsuficiente extends ReservaException {
  const CapacidadInsuficiente(int capacidad, int personas)
    : super('La mesa es para $capacidad y el grupo es de $personas personas.');
}

class MesaOcupada extends ReservaException {
  const MesaOcupada()
    : super('La mesa ya tiene una reserva confirmada en esa franja.');
}

class MesaBloqueada extends ReservaException {
  const MesaBloqueada() : super('La mesa esta bloqueada en esa franja.');
}

class ReservaDuplicada extends ReservaException {
  const ReservaDuplicada()
    : super('El cliente ya tiene una reserva activa en esa franja.');
}

class FueraDeMargen extends ReservaException {
  const FueraDeMargen()
    : super('La llegada solo se registra desde 15 minutos antes hasta 15 minutos despues del inicio.');
}

class AusenciaAnticipada extends ReservaException {
  const AusenciaAnticipada()
    : super('Solo se puede marcar ausente 15 minutos despues del inicio.');
}

class FueraDePlazoCancelacion extends ReservaException {
  const FueraDePlazoCancelacion()
    : super('Solo se puede cancelar hasta 2 horas antes del inicio.');
}

class TransicionInvalida extends ReservaException {
  const TransicionInvalida(String desde, String hacia)
    : super('No se puede pasar de $desde a $hacia.');
}

class ConflictoVersion extends ReservaException {
  const ConflictoVersion()
    : super('La reserva cambio mientras la veias. Se actualizo con el estado actual.');
}

class ReservaNoEncontrada extends ReservaException {
  const ReservaNoEncontrada() : super('La reserva ya no existe en el servidor.');
}

class RequiereConexion extends ReservaException {
  const RequiereConexion()
    : super('Esta accion necesita conexion. Intenta de nuevo cuando vuelva internet.');
}

class PermisoDenegado extends ReservaException {
  const PermisoDenegado()
    : super('El servidor rechazo la operacion por las reglas de seguridad.');
}

class MotivoRequerido extends ReservaException {
  const MotivoRequerido() : super('Escribe un motivo.');
}
