import 'package:flutter/material.dart';

import '../models/reserva.dart';

class SyncBadge extends StatelessWidget {
  final Reserva reserva;

  const SyncBadge({super.key, required this.reserva});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final (IconData icono, String texto, Color color) = switch (reserva) {
      Reserva(syncConflict: true) => (
        Icons.error_outline,
        'Rechazada por el servidor',
        colors.error,
      ),
      Reserva(pendingSync: true) => (
        Icons.cloud_upload_outlined,
        'Pendiente de envio',
        colors.tertiary,
      ),
      _ => (Icons.cloud_done_outlined, 'Sincronizada', colors.primary),
    };

    return Semantics(
      label: 'Sincronizacion: $texto',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 4),
          Text(texto, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
