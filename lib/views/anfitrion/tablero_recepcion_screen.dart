import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/app_dependencies.dart';
import '../../core/app_logger.dart';
import '../../core/formatters.dart';
import '../../core/hora_restaurante.dart';
import '../../domain/reserva_exception.dart';
import '../../domain/reserva_rules.dart';
import '../../models/estado_reserva.dart';
import '../../models/perfil.dart';
import '../../models/reserva.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/reserva_card.dart';

class TableroRecepcionScreen extends StatefulWidget {
  final AppDependencies deps;
  final Perfil perfil;

  const TableroRecepcionScreen({super.key, required this.deps, required this.perfil});

  @override
  State<TableroRecepcionScreen> createState() => _TableroRecepcionScreenState();
}

class _TableroRecepcionScreenState extends State<TableroRecepcionScreen> {
  late DateTime _dia;
  late Stream<List<Reserva>> _reservas;
  final _busqueda = TextEditingController();
  Timer? _reloj;
  bool _ocupado = false;

  static const _visibles = {
    EstadoReserva.confirmada,
    EstadoReserva.enMesa,
    EstadoReserva.finalizada,
    EstadoReserva.ausente,
  };

  @override
  void initState() {
    super.initState();
    _dia = HoraRestaurante.hoy();
    _reservas = widget.deps.reservaRepository.watchReservasDelDia(_dia);
    // refresca los botones de llegada
    _reloj = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _reloj?.cancel();
    _busqueda.dispose();
    super.dispose();
  }

  void _cambiarDia(DateTime dia) {
    setState(() {
      _dia = dia;
      _reservas = widget.deps.reservaRepository.watchReservasDelDia(dia);
    });
  }

  Future<void> _accion(
    Reserva reserva,
    String titulo,
    String mensaje,
    Future<Reserva> Function() operacion,
    String exito,
  ) async {
    if (_ocupado) return;
    final ok = await showConfirmDialog(context, title: titulo, message: mensaje);
    if (!ok || !mounted) return;

    setState(() => _ocupado = true);
    try {
      await operacion();
      if (!mounted) return;
      showResultSnack(context, exito);
      _cambiarDia(_dia);
    } on ReservaException catch (e) {
      if (!mounted) return;
      showResultSnack(context, e.message, error: true);
    } catch (e, st) {
      AppLogger.error('Error inesperado en recepcion', error: e, stackTrace: st);
      if (!mounted) return;
      showResultSnack(context, 'No se pudo completar la accion.', error: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  List<Widget> _acciones(Reserva r, DateTime now) {
    final repo = widget.deps.reservaRepository;
    final acciones = <Widget>[];
    final desde = r.inicio.subtract(AppConstants.margenLlegada);
    final hasta = r.inicio.add(AppConstants.margenLlegada);

    if (r.estado == EstadoReserva.confirmada) {
      final enVentana = ReservaRules.puedeRegistrarLlegada(r, now);
      acciones.add(
        FilledButton.icon(
          onPressed: _ocupado || !enVentana
              ? null
              : () => _accion(
                  r,
                  'Registrar llegada',
                  '${r.clienteNombre} · ${r.mesaNombre ?? ''}',
                  () => repo.registrarLlegada(reserva: r, anfitrion: widget.perfil),
                  'Llegada registrada: ${r.clienteNombre} en mesa',
                ),
          icon: const Icon(Icons.login),
          label: const Text('Registrar llegada'),
        ),
      );
      if (!enVentana && now.isBefore(desde)) {
        acciones.add(
          Text('Llegada desde ${Formatters.hora(desde)} hasta ${Formatters.hora(hasta)}'),
        );
      }
      if (ReservaRules.puedeMarcarAusente(r, now)) {
        acciones.add(
          OutlinedButton.icon(
            onPressed: _ocupado
                ? null
                : () => _accion(
                    r,
                    'Marcar ausente',
                    '${r.clienteNombre} no llego. La reserva queda en el historial como AUSENTE.',
                    () => repo.marcarAusente(reserva: r, anfitrion: widget.perfil),
                    'Reserva marcada como ausente',
                  ),
            icon: const Icon(Icons.person_off_outlined),
            label: const Text('Marcar ausente'),
          ),
        );
      }
    }

    if (ReservaRules.puedeFinalizar(r)) {
      acciones.add(
        FilledButton.tonalIcon(
          onPressed: _ocupado
              ? null
              : () => _accion(
                  r,
                  'Finalizar atencion',
                  'Se libera ${r.mesaNombre ?? 'la mesa'}.',
                  () => repo.finalizar(reserva: r, anfitrion: widget.perfil),
                  'Atencion finalizada, mesa liberada',
                ),
          icon: const Icon(Icons.done_all),
          label: const Text('Finalizar'),
        ),
      );
    }
    return acciones;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Reserva>>(
      stream: _reservas,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          AppLogger.warning('Tablero de recepcion sin datos', error: snapshot.error);
          return ErrorView(
            message: 'No se pudo leer el servicio del dia. Revisa tu conexion.',
            onRetry: () => _cambiarDia(_dia),
          );
        }
        if (!snapshot.hasData) return const LoadingView();

        final now = DateTime.now();
        final filtro = _busqueda.text.trim().toLowerCase();
        final reservas = snapshot.data!
            .where((r) => _visibles.contains(r.estado))
            .where(
              (r) =>
                  filtro.isEmpty ||
                  r.clienteNombre.toLowerCase().contains(filtro) ||
                  r.id.startsWith(filtro),
            )
            .toList();

        final porLlegar = reservas.where((r) => r.estado == EstadoReserva.confirmada).length;
        final enMesa = reservas.where((r) => r.estado == EstadoReserva.enMesa).length;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Dia anterior',
                      onPressed: () => _cambiarDia(_dia.subtract(const Duration(days: 1))),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        Formatters.mismoDia(_dia, HoraRestaurante.hoy(now))
                            ? 'Hoy · ${Formatters.dia(_dia)}'
                            : Formatters.dia(_dia),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dia siguiente',
                      onPressed: () => _cambiarDia(_dia.add(const Duration(days: 1))),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _Contador('Por llegar', porLlegar, Icons.schedule)),
                    const SizedBox(width: 12),
                    Expanded(child: _Contador('En mesa', enMesa, Icons.restaurant)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _busqueda,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar por nombre o id',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (reservas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: EmptyView(
                      message: 'No hay reservas confirmadas para este dia',
                      icon: Icons.room_service_outlined,
                    ),
                  )
                else
                  ...reservas.map(
                    (r) => ReservaCard(
                      reserva: r,
                      mostrarCliente: true,
                      acciones: _acciones(r, now),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Contador extends StatelessWidget {
  final String label;
  final int valor;
  final IconData icon;

  const _Contador(this.label, this.valor, this.icon);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: colors.onSecondaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: TextStyle(color: colors.onSecondaryContainer)),
            ),
            Text(
              '$valor',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
