import 'package:final_movil/models/estado_reserva.dart';
import 'package:final_movil/models/reserva.dart';
import 'package:final_movil/widgets/empty_view.dart';
import 'package:final_movil/widgets/error_view.dart';
import 'package:final_movil/widgets/estado_chip.dart';
import 'package:final_movil/widgets/loading_view.dart';
import 'package:final_movil/widgets/sync_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

Reserva _reserva({bool pending = false, bool conflict = false}) => Reserva(
  id: 'r1',
  clienteUid: 'u1',
  clienteNombre: 'Ana',
  personas: 2,
  inicio: DateTime(2030, 1, 1, 19, 30),
  estado: EstadoReserva.solicitada,
  createdAt: DateTime(2029),
  updatedAt: DateTime(2029),
  pendingSync: pending,
  syncConflict: conflict,
);

void main() {
  testWidgets('LoadingView muestra el indicador de carga', (tester) async {
    await tester.pumpWidget(_app(const LoadingView()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('EmptyView muestra el mensaje que recibe', (tester) async {
    await tester.pumpWidget(_app(const EmptyView(message: 'No hay mesas')));

    expect(find.text('No hay mesas'), findsOneWidget);
  });

  testWidgets('ErrorView avisa al tocar Reintentar', (tester) async {
    var veces = 0;

    await tester.pumpWidget(
      _app(ErrorView(message: 'Fallo la carga', onRetry: () => veces++)),
    );

    expect(find.text('Fallo la carga'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    expect(veces, 1);
  });

  testWidgets('EstadoChip muestra el estado del negocio', (tester) async {
    await tester.pumpWidget(
      _app(const EstadoChip(estado: EstadoReserva.confirmada, vencida: true)),
    );

    expect(find.text('Confirmada · vencida'), findsOneWidget);
  });

  testWidgets('SyncBadge distingue pendiente, rechazada y sincronizada', (tester) async {
    await tester.pumpWidget(_app(SyncBadge(reserva: _reserva(pending: true))));
    expect(find.text('Pendiente de envio'), findsOneWidget);

    await tester.pumpWidget(
      _app(SyncBadge(reserva: _reserva(pending: true, conflict: true))),
    );
    expect(find.text('Rechazada por el servidor'), findsOneWidget);

    await tester.pumpWidget(_app(SyncBadge(reserva: _reserva())));
    expect(find.text('Sincronizada'), findsOneWidget);
  });
}
