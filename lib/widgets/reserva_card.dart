import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../domain/reserva_rules.dart';
import '../models/reserva.dart';
import 'estado_chip.dart';
import 'sync_badge.dart';

class ReservaCard extends StatelessWidget {
  final Reserva reserva;
  final VoidCallback? onTap;

  final bool mostrarCliente;

  final bool mostrarSync;

  final List<Widget> acciones;

  const ReservaCard({
    super.key,
    required this.reserva,
    this.onTap,
    this.mostrarCliente = false,
    this.mostrarSync = false,
    this.acciones = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final vencida = ReservaRules.estaVencida(reserva, DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mostrarCliente
                          ? reserva.clienteNombre
                          : Formatters.diaDe(reserva.inicio),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  EstadoChip(estado: reserva.estado, vencida: vencida),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _Dato(
                    icon: Icons.schedule,
                    text: mostrarCliente
                        ? reserva.franja.etiqueta
                        : '${Formatters.diaDe(reserva.inicio)} · ${reserva.franja.etiqueta}',
                  ),
                  _Dato(
                    icon: Icons.groups_outlined,
                    text: '${reserva.personas} ${reserva.personas == 1 ? 'persona' : 'personas'}',
                  ),
                  if (reserva.mesaNombre != null)
                    _Dato(icon: Icons.table_restaurant_outlined, text: reserva.mesaNombre!),
                ],
              ),
              if (reserva.comentario.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '"${reserva.comentario}"',
                  style: TextStyle(color: colors.onSurfaceVariant, fontStyle: FontStyle.italic),
                ),
              ],
              if (mostrarSync) ...[
                const SizedBox(height: 8),
                SyncBadge(reserva: reserva),
                if (reserva.lastError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      reserva.lastError!,
                      style: TextStyle(fontSize: 12, color: colors.error),
                    ),
                  ),
              ],
              if (acciones.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: acciones),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Dato({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }
}
