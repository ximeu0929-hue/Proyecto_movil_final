import 'package:flutter/material.dart';

import '../models/estado_reserva.dart';

class EstadoChip extends StatelessWidget {
  final EstadoReserva estado;
  final bool vencida;

  const EstadoChip({super.key, required this.estado, this.vencida = false});

  static (Color, Color, IconData) estilo(EstadoReserva estado, Brightness b) {
    final dark = b == Brightness.dark;
    Color tono(MaterialColor c) => dark ? c.shade800 : c.shade100;
    Color texto(MaterialColor c) => dark ? c.shade50 : c.shade900;

    switch (estado) {
      case EstadoReserva.solicitada:
        return (tono(Colors.amber), texto(Colors.amber), Icons.schedule);
      case EstadoReserva.confirmada:
        return (tono(Colors.blue), texto(Colors.blue), Icons.event_available);
      case EstadoReserva.enMesa:
        return (tono(Colors.green), texto(Colors.green), Icons.restaurant);
      case EstadoReserva.finalizada:
        return (tono(Colors.blueGrey), texto(Colors.blueGrey), Icons.done_all);
      case EstadoReserva.rechazada:
        return (tono(Colors.red), texto(Colors.red), Icons.block);
      case EstadoReserva.cancelada:
        return (tono(Colors.grey), texto(Colors.grey), Icons.cancel_outlined);
      case EstadoReserva.ausente:
        return (tono(Colors.deepOrange), texto(Colors.deepOrange), Icons.person_off_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fondo, texto, icono) = estilo(estado, Theme.of(context).brightness);
    final label = vencida ? '${estado.label} · vencida' : estado.label;

    return Semantics(
      label: 'Estado: $label',
      child: Chip(
        avatar: Icon(icono, size: 16, color: texto),
        label: Text(label, style: TextStyle(color: texto, fontWeight: FontWeight.w600)),
        backgroundColor: fondo,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
