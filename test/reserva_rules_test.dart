import 'package:final_movil/core/hora_restaurante.dart';
import 'package:final_movil/domain/reserva_exception.dart';
import 'package:final_movil/domain/reserva_rules.dart';
import 'package:final_movil/domain/reserva_state_machine.dart';
import 'package:final_movil/models/estado_reserva.dart';
import 'package:final_movil/models/franja.dart';
import 'package:final_movil/models/mesa.dart';
import 'package:final_movil/models/reserva.dart';
import 'package:final_movil/models/rol.dart';
import 'package:flutter_test/flutter_test.dart';

final _inicio = HoraRestaurante.instante(2030, 3, 15, 19, 30); // franja fija 19:30

Reserva _reserva({
  EstadoReserva estado = EstadoReserva.confirmada,
  DateTime? inicio,
  DateTime? llegadaAt,
  String id = 'r1',
}) {
  return Reserva(
    id: id,
    clienteUid: 'cliente-1',
    clienteNombre: 'Ana',
    personas: 4,
    inicio: inicio ?? _inicio,
    estado: estado,
    createdAt: DateTime(2030),
    updatedAt: DateTime(2030),
    llegadaAt: llegadaAt,
  );
}

Mesa _mesa(String id, int capacidad) => Mesa(
  id: id,
  nombre: 'Mesa $id',
  capacidad: capacidad,
  ubicacion: 'Salon',
  caracteristicas: const [],
);

void main() {
  group('Regla 1 · 1 a 8 personas, futura y franja fija', () {
    test('acepta de 1 a 8 personas', () {
      expect(ReservaRules.personasValidas(1), isTrue);
      expect(ReservaRules.personasValidas(8), isTrue);
    });

    test('rechaza 0 y 9 personas', () {
      expect(ReservaRules.personasValidas(0), isFalse);
      expect(ReservaRules.personasValidas(9), isFalse);
      expect(
        () => ReservaRules.validarSolicitud(personas: 9, inicio: _inicio, now: DateTime(2030)),
        throwsA(isA<PersonasInvalidas>()),
      );
    });

    test('rechaza una franja que ya paso', () {
      expect(
        () => ReservaRules.validarSolicitud(
          personas: 2,
          inicio: _inicio,
          now: _inicio.add(const Duration(minutes: 1)),
        ),
        throwsA(isA<FechaNoFutura>()),
      );
    });

    test('rechaza una hora que no es inicio de franja', () {
      expect(
        () => ReservaRules.validarSolicitud(
          personas: 2,
          inicio: HoraRestaurante.instante(2030, 3, 15, 19, 45),
          now: DateTime(2030),
        ),
        throwsA(isA<FranjaInvalida>()),
      );
    });

    test('las franjas duran 90 minutos y son 6 por dia', () {
      final franjas = Franja.delDia(DateTime(2030, 3, 15));
      expect(franjas, hasLength(6));
      for (final f in franjas) {
        expect(f.fin.difference(f.inicio), const Duration(minutes: 90));
      }
      expect(Franja(_inicio).id, '20300315-1930');
    });

    test('la franja es la del restaurante aunque el telefono este en UTC (BUG-09)', () {
      // 00:30 UTC del 16 de marzo = 19:30 del 15 de marzo en Bogota.
      final franja = Franja(DateTime.utc(2030, 3, 16, 0, 30));
      expect(franja.id, '20300315-1930');
      expect(franja.dia, '2030-03-15');
      expect(franja.etiqueta, '19:30 - 21:00');
      expect(Franja.esInicioValido(DateTime.utc(2030, 3, 16, 0, 30)), isTrue);
      expect(Franja.esInicioValido(DateTime.utc(2030, 3, 15, 19, 30)), isFalse);
      expect(
        Franja.delDia(DateTime(2030, 3, 15)).map((f) => f.etiqueta),
        contains('19:30 - 21:00'),
      );
    });
  });

  group('Regla 2 · capacidad y mesa libre', () {
    final mesas = [_mesa('M1', 2), _mesa('M2', 4), _mesa('M3', 6), _mesa('M4', 8)];

    test('una mesa pequena no sirve para un grupo mayor', () {
      expect(ReservaRules.tieneCapacidad(_mesa('M1', 2), 4), isFalse);
      expect(ReservaRules.tieneCapacidad(_mesa('M2', 4), 4), isTrue);
    });

    test('solo ofrece mesas con capacidad y libres, la mas ajustada primero', () {
      final validas = ReservaRules.mesasValidas(
        mesas: mesas,
        personas: 4,
        ocupadas: {'M2'},
      );
      expect(validas.map((m) => m.id), ['M3', 'M4']);
    });
  });

  group('Regla 3 · una reserva activa por cliente y franja', () {
    test('detecta reserva activa en la misma franja', () {
      final existentes = [_reserva(estado: EstadoReserva.confirmada)];
      expect(ReservaRules.tieneReservaEnFranja(existentes, Franja(_inicio).id), isTrue);
    });

    test('una cancelada no cuenta como activa', () {
      final existentes = [_reserva(estado: EstadoReserva.cancelada)];
      expect(ReservaRules.tieneReservaEnFranja(existentes, Franja(_inicio).id), isFalse);
    });

    test('cancelar se permite hasta 2 horas antes, no despues', () {
      final r = _reserva();
      expect(
        ReservaRules.puedeCancelar(r, _inicio.subtract(const Duration(hours: 2))),
        isTrue,
      );
      expect(
        ReservaRules.puedeCancelar(r, _inicio.subtract(const Duration(minutes: 119))),
        isFalse,
      );
    });
  });

  group('Regla 4 · ventana de llegada de +-15 minutos', () {
    test('dentro de la ventana', () {
      expect(
        ReservaRules.dentroDeVentanaLlegada(_inicio, _inicio.subtract(const Duration(minutes: 15))),
        isTrue,
      );
      expect(
        ReservaRules.dentroDeVentanaLlegada(_inicio, _inicio.add(const Duration(minutes: 15))),
        isTrue,
      );
    });

    test('fuera de la ventana se bloquea EN_MESA', () {
      final tarde = _inicio.add(const Duration(minutes: 16));
      expect(ReservaRules.dentroDeVentanaLlegada(_inicio, tarde), isFalse);
      expect(
        () => ReservaRules.validarTransicion(
          reserva: _reserva(),
          destino: EstadoReserva.enMesa,
          rol: Rol.anfitrion,
          now: tarde,
        ),
        throwsA(isA<FueraDeMargen>()),
      );
    });

    test('ausente solo despues de 15 minutos y sin llegada', () {
      expect(
        ReservaRules.puedeMarcarAusente(_reserva(), _inicio.add(const Duration(minutes: 10))),
        isFalse,
      );
      expect(
        ReservaRules.puedeMarcarAusente(_reserva(), _inicio.add(const Duration(minutes: 16))),
        isTrue,
      );
    });

    test('finalizar exige EN_MESA', () {
      expect(ReservaRules.puedeFinalizar(_reserva(estado: EstadoReserva.enMesa)), isTrue);
      expect(ReservaRules.puedeFinalizar(_reserva()), isFalse);
    });

    test('vencida se muestra sin cambiar el estado', () {
      final r = _reserva();
      expect(ReservaRules.estaVencida(r, _inicio.add(const Duration(minutes: 20))), isTrue);
      expect(r.estado, EstadoReserva.confirmada);
    });
  });

  group('Maquina de estados', () {
    test('cada rol solo hace sus transiciones', () {
      expect(
        ReservaStateMachine.canTransition(
          EstadoReserva.solicitada,
          EstadoReserva.confirmada,
          Rol.adminSalon,
        ),
        isTrue,
      );
      expect(
        ReservaStateMachine.canTransition(
          EstadoReserva.solicitada,
          EstadoReserva.confirmada,
          Rol.cliente,
        ),
        isFalse,
      );
      expect(
        ReservaStateMachine.canTransition(
          EstadoReserva.confirmada,
          EstadoReserva.enMesa,
          Rol.anfitrion,
        ),
        isTrue,
      );
    });

    test('los estados terminales no se reactivan', () {
      for (final terminal in EstadoReserva.values.where((e) => e.isTerminal)) {
        for (final rol in Rol.values) {
          expect(ReservaStateMachine.siguientes(terminal, rol), isEmpty);
        }
      }
    });

    test('finalizar sin pasar por EN_MESA es transicion invalida', () {
      expect(
        () => ReservaRules.validarTransicion(
          reserva: _reserva(),
          destino: EstadoReserva.finalizada,
          rol: Rol.anfitrion,
          now: _inicio,
        ),
        throwsA(isA<TransicionInvalida>()),
      );
    });
  });
}
