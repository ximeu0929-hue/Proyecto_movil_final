import 'package:flutter/material.dart';

import '../../core/app_dependencies.dart';
import '../../core/app_logger.dart';
import '../../core/formatters.dart';
import '../../domain/reserva_exception.dart';
import '../../domain/reserva_rules.dart';
import '../../models/estado_reserva.dart';
import '../../models/perfil.dart';
import '../../models/reserva.dart';
import '../../repositories/reserva_repository.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/estado_chip.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/sync_badge.dart';
import 'nueva_reserva_screen.dart';

class ReservaDetailPage extends StatefulWidget {
  final AppDependencies deps;
  final Perfil perfil;
  final String reservaId;

  const ReservaDetailPage({
    super.key,
    required this.deps,
    required this.perfil,
    required this.reservaId,
  });

  @override
  State<ReservaDetailPage> createState() => _ReservaDetailPageState();
}

class _ReservaDetailPageState extends State<ReservaDetailPage> {
  late final Stream<Reserva?> _stream;
  bool _ocupado = false;

  ReservaRepository get _repo => widget.deps.reservaRepository;

  @override
  void initState() {
    super.initState();
    _stream = _repo
        .watchMisReservas(widget.perfil.uid)
        .map((lista) => lista.where((r) => r.id == widget.reservaId).firstOrNull);
  }

  Future<void> _accion(Future<String> Function() operacion) async {
    if (_ocupado) return;
    setState(() => _ocupado = true);
    try {
      final mensaje = await operacion();
      if (!mounted) return;
      showResultSnack(context, mensaje);
    } on ReservaException catch (e) {
      if (!mounted) return;
      showResultSnack(context, e.message, error: true);
    } catch (e, st) {
      AppLogger.error('Error inesperado en detalle de reserva', error: e, stackTrace: st);
      if (!mounted) return;
      showResultSnack(context, 'No se pudo completar la accion.', error: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _cancelar(Reserva reserva) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cancelar reserva',
      message: reserva.estado == EstadoReserva.confirmada
          ? 'Se liberara la mesa asignada. Esta accion no se puede deshacer.'
          : 'La solicitud quedara cancelada. Esta accion no se puede deshacer.',
      confirmLabel: 'Cancelar reserva',
      destructive: true,
    );
    if (!ok) return;
    await _accion(() async {
      await _repo.cancelar(reserva: reserva, cliente: widget.perfil);
      return 'Reserva cancelada';
    });
  }

  Future<void> _descartar(Reserva reserva) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Descartar intento',
      message: 'Esta solicitud nunca llego al restaurante. Se borrara de este telefono.',
      confirmLabel: 'Descartar',
      destructive: true,
    );
    if (!ok) return;
    await _accion(() async {
      await _repo.descartarSolicitud(reserva);
      if (mounted) Navigator.pop(context);
      return 'Intento descartado';
    });
  }

  Future<void> _reintentar(Reserva reserva) async {
    await _accion(() async {
      final resultado = await _repo.reintentar(reserva);
      return switch (resultado) {
        ResultadoEnvio.sincronizada => 'Solicitud enviada',
        ResultadoEnvio.pendiente => 'Sigue pendiente: no hay conexion',
        ResultadoEnvio.rechazada => 'El servidor rechazo la solicitud',
      };
    });
  }

  void _corregir(Reserva reserva) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NuevaReservaScreen(
          deps: widget.deps,
          perfil: widget.perfil,
          reservaACorregir: reserva,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la reserva')),
      body: StreamBuilder<Reserva?>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          final reserva = snapshot.data;
          if (reserva == null) {
            return const Center(child: Text('La reserva ya no esta en este telefono.'));
          }
          return _buildDetalle(reserva);
        },
      ),
    );
  }

  Widget _buildDetalle(Reserva reserva) {
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final vencida = ReservaRules.estaVencida(reserva, now);
    final puedeCancelar = !reserva.pendingSync && ReservaRules.puedeCancelar(reserva, now);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      Formatters.diaDe(reserva.inicio),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  EstadoChip(estado: reserva.estado, vencida: vencida),
                ],
              ),
              const SizedBox(height: 8),
              SyncBadge(reserva: reserva),
              if (reserva.pendingSync)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'El restaurante todavia no recibe esta solicitud. '
                    'No esta confirmada ni tiene mesa.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              if (reserva.lastError != null)
                Card(
                  margin: const EdgeInsets.only(top: 12),
                  color: colors.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      reserva.lastError!,
                      style: TextStyle(color: colors.onErrorContainer),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _Fila(Icons.schedule, 'Franja', reserva.franja.etiqueta),
              _Fila(Icons.groups_outlined, 'Personas', '${reserva.personas}'),
              _Fila(
                Icons.table_restaurant_outlined,
                'Mesa',
                reserva.mesaNombre ?? 'Se asigna al confirmar',
              ),
              if (reserva.comentario.isNotEmpty)
                _Fila(Icons.notes, 'Comentario', reserva.comentario),
              if (reserva.motivoRechazo != null)
                _Fila(Icons.block, 'Motivo de rechazo', reserva.motivoRechazo!),
              if (reserva.llegadaAt != null)
                _Fila(Icons.login, 'Llegada', Formatters.diaHora(reserva.llegadaAt!)),
              if (reserva.finalizadaAt != null)
                _Fila(Icons.logout, 'Finalizada', Formatters.diaHora(reserva.finalizadaAt!)),
              _Fila(Icons.tag, 'Id', reserva.id.substring(0, 8)),
              const SizedBox(height: 24),
              if (reserva.pendingSync && !reserva.syncConflict)
                _Boton(
                  icon: Icons.sync,
                  label: 'Reintentar envio',
                  onPressed: _ocupado ? null : () => _reintentar(reserva),
                ),
              if (reserva.pendingSync) ...[
                _Boton(
                  icon: Icons.edit_outlined,
                  label: 'Corregir',
                  onPressed: _ocupado ? null : () => _corregir(reserva),
                ),
                _Boton(
                  icon: Icons.delete_outline,
                  label: 'Descartar intento',
                  destructive: true,
                  onPressed: _ocupado ? null : () => _descartar(reserva),
                ),
              ],
              if (puedeCancelar)
                _Boton(
                  icon: Icons.cancel_outlined,
                  label: 'Cancelar reserva',
                  destructive: true,
                  onPressed: _ocupado ? null : () => _cancelar(reserva),
                ),
              if (!reserva.pendingSync &&
                  !puedeCancelar &&
                  !reserva.estado.isTerminal &&
                  reserva.estado != EstadoReserva.enMesa)
                Text(
                  'Ya no se puede cancelar: el plazo termina 2 horas antes del inicio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Fila(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primary),
      title: Text(label, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}

class _Boton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool destructive;

  const _Boton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: destructive ? colors.error : null,
        ),
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
