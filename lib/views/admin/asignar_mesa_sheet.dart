import 'package:flutter/material.dart';

import '../../domain/reserva_rules.dart';
import '../../models/mesa.dart';
import '../../models/reserva.dart';

Future<Mesa?> showAsignarMesaSheet(
  BuildContext context, {
  required Reserva reserva,
  required List<Mesa> mesas,
  required Set<String> ocupadas,
}) {
  final validas = ReservaRules.mesasValidas(
    mesas: mesas,
    personas: reserva.personas,
    ocupadas: ocupadas,
  );
  final idsValidas = validas.map((m) => m.id).toSet();
  final noValidas = mesas.where((m) => !idsValidas.contains(m.id)).toList();

  String motivo(Mesa m) {
    if (!ReservaRules.tieneCapacidad(m, reserva.personas)) {
      return 'Capacidad ${m.capacidad}: no alcanza para ${reserva.personas}';
    }
    return 'Ocupada o bloqueada en esta franja';
  }

  return showModalBottomSheet<Mesa>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final colors = Theme.of(context).colorScheme;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                'Mesa para ${reserva.personas} personas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${reserva.clienteNombre} · ${reserva.franja.etiqueta}',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              if (validas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay mesas libres con capacidad suficiente en esta franja.',
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ...validas.map(
                (m) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                    title: Text(m.nombre),
                    subtitle: Text('${m.ubicacion} · capacidad ${m.capacidad}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pop(context, m),
                  ),
                ),
              ),
              if (noValidas.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('No disponibles', style: TextStyle(color: colors.onSurfaceVariant)),
                ...noValidas.map(
                  (m) => ListTile(
                    enabled: false,
                    leading: const Icon(Icons.block),
                    title: Text(m.nombre),
                    subtitle: Text(motivo(m)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
