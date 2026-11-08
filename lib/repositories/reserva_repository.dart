import '../models/franja.dart';
import '../models/mesa.dart';
import '../models/ocupacion.dart';
import '../models/perfil.dart';
import '../models/reserva.dart';

enum ResultadoEnvio {
  sincronizada,

  pendiente,

  rechazada,
}

abstract class ReservaRepository {
  // Cliente (local-first)

  Stream<List<Reserva>> watchMisReservas(String uid);

  Future<(Reserva, ResultadoEnvio)> solicitarReserva({
    required Perfil cliente,
    required int personas,
    required DateTime inicio,
    String comentario = '',
  });

  Future<(Reserva, ResultadoEnvio)> corregirSolicitud({
    required Reserva reserva,
    required int personas,
    required DateTime inicio,
    String comentario = '',
  });

  Future<void> descartarSolicitud(Reserva reserva);

  Future<ResultadoEnvio> reintentar(Reserva reserva);

  Future<(int sent, int failed)> syncPending(String uid);

  Future<Reserva> cancelar({required Reserva reserva, required Perfil cliente});

  void iniciarEscuchaCliente(String uid);

  void detenerEscuchaCliente();

  // Administrador de salon

  Stream<List<Reserva>> watchReservasDelDia(DateTime dia);

  Stream<List<Ocupacion>> watchOcupacionDelDia(DateTime dia);

  Future<Reserva> confirmar({
    required Reserva reserva,
    required Mesa mesa,
    required Perfil admin,
  });

  Future<Reserva> rechazar({
    required Reserva reserva,
    required String motivo,
    required Perfil admin,
  });

  Future<void> bloquearMesa({
    required Mesa mesa,
    required Franja franja,
    required String motivo,
    required Perfil admin,
  });

  Future<void> desbloquearMesa(Ocupacion ocupacion);

  // Anfitrion

  Future<Reserva> registrarLlegada({
    required Reserva reserva,
    required Perfil anfitrion,
  });

  Future<Reserva> finalizar({
    required Reserva reserva,
    required Perfil anfitrion,
  });

  Future<Reserva> marcarAusente({
    required Reserva reserva,
    required Perfil anfitrion,
  });
}
