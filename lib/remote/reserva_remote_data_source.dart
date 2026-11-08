import '../models/estado_reserva.dart';
import '../models/franja.dart';
import '../models/mesa.dart';
import '../models/ocupacion.dart';
import '../models/perfil.dart';
import '../models/reserva.dart';

abstract class ReservaRemoteDataSource {
  Future<Reserva> crearReserva(Reserva reserva);

  Future<Reserva?> getReserva(String id);

  Stream<List<Reserva>> watchReservasCliente(String uid);

  Stream<List<Reserva>> watchReservasDelDia(String dia);

  Stream<List<Ocupacion>> watchOcupacionDelDia(String dia);

  Future<Reserva> confirmar({
    required String reservaId,
    required int expectedVersion,
    required Mesa mesa,
    required Perfil actor,
  });

  Future<Reserva> transicion({
    required String reservaId,
    required int expectedVersion,
    required EstadoReserva destino,
    required Perfil actor,
    String? motivo,
  });

  Future<void> bloquearMesa({
    required Mesa mesa,
    required Franja franja,
    required String motivo,
    required Perfil actor,
  });

  Future<void> desbloquearMesa({required Ocupacion ocupacion});
}
