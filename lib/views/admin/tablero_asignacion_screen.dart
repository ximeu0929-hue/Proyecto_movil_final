import 'package:flutter/material.dart';

import '../../core/app_dependencies.dart';
import '../../core/app_logger.dart';
import '../../core/formatters.dart';
import '../../core/hora_restaurante.dart';
import '../../domain/reserva_exception.dart';
import '../../models/estado_reserva.dart';
import '../../models/franja.dart';
import '../../models/mesa.dart';
import '../../models/ocupacion.dart';
import '../../models/perfil.dart';
import '../../models/reserva.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/reserva_card.dart';
import 'asignar_mesa_sheet.dart';

class TableroAsignacionScreen extends StatefulWidget {
  final AppDependencies deps;
  final Perfil perfil;

  const TableroAsignacionScreen({super.key, required this.deps, required this.perfil});

  @override
  State<TableroAsignacionScreen> createState() => _TableroAsignacionScreenState();
}

class _TableroAsignacionScreenState extends State<TableroAsignacionScreen> {
  late DateTime _dia;
  late Franja _franja;
  late Future<List<Mesa>> _futureMesas;
  late Stream<List<Reserva>> _reservas;
  late Stream<List<Ocupacion>> _ocupacion;
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    _futureMesas = widget.deps.mesaRepository.getMesas();
    _seleccionarDia(HoraRestaurante.hoy(), notificar: false);
  }

  void _seleccionarDia(DateTime dia, {bool notificar = true}) {
    void aplicar() {
      _dia = dia;
      final franjas = Franja.delDia(dia);
      final ahora = DateTime.now();
      _franja = franjas.firstWhere(
        (f) => f.fin.isAfter(ahora),
        orElse: () => franjas.first,
      );
      _reservas = widget.deps.reservaRepository.watchReservasDelDia(dia);
      _ocupacion = widget.deps.reservaRepository.watchOcupacionDelDia(dia);
    }

    if (notificar) {
      setState(aplicar);
    } else {
      aplicar();
    }
  }

  Future<void> _elegirDia() async {
    final hoy = HoraRestaurante.hoy();
    final elegido = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: hoy.subtract(const Duration(days: 7)),
      lastDate: hoy.add(const Duration(days: 60)),
    );
    if (elegido == null || !mounted) return;
    _seleccionarDia(elegido);
  }

  void _reintentar() {
    setState(() {
      _futureMesas = widget.deps.mesaRepository.getMesas(forceRefresh: true);
    });
    _seleccionarDia(_dia);
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
      AppLogger.error('Error inesperado en tablero de asignacion', error: e, stackTrace: st);
      if (!mounted) return;
      showResultSnack(context, 'No se pudo completar la accion.', error: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _asignar(Reserva reserva, List<Mesa> mesas, Set<String> ocupadas) async {
    final mesa = await showAsignarMesaSheet(
      context,
      reserva: reserva,
      mesas: mesas,
      ocupadas: ocupadas,
    );
    if (mesa == null || !mounted) return;

    final ok = await showConfirmDialog(
      context,
      title: 'Confirmar reserva',
      message: '${reserva.clienteNombre} · ${reserva.personas} personas\n'
          '${Formatters.diaDe(reserva.inicio)} · ${reserva.franja.etiqueta}\n'
          'Mesa: ${mesa.nombre} (capacidad ${mesa.capacidad})',
    );
    if (!ok) return;

    await _accion(() async {
      await widget.deps.reservaRepository.confirmar(
        reserva: reserva,
        mesa: mesa,
        admin: widget.perfil,
      );
      return 'Reserva confirmada en ${mesa.nombre}';
    });
  }

  Future<void> _rechazar(Reserva reserva) async {
    final motivo = await showMotivoDialog(
      context,
      title: 'Rechazar solicitud',
      hint: 'Motivo visible para el cliente',
      confirmLabel: 'Rechazar',
    );
    if (motivo == null) return;
    await _accion(() async {
      await widget.deps.reservaRepository.rechazar(
        reserva: reserva,
        motivo: motivo,
        admin: widget.perfil,
      );
      return 'Solicitud rechazada';
    });
  }

  Future<void> _tocarMesa(Mesa mesa, Ocupacion? ocupacion) async {
    if (ocupacion?.tipo == TipoOcupacion.reserva) return;

    if (ocupacion == null) {
      if (!_franja.inicio.isAfter(DateTime.now())) {
        showResultSnack(context, 'Solo se bloquean franjas futuras.', error: true);
        return;
      }
      final motivo = await showMotivoDialog(
        context,
        title: 'Bloquear ${mesa.nombre}',
        hint: 'Ej: mantenimiento, evento privado',
        confirmLabel: 'Bloquear',
      );
      if (motivo == null) return;
      await _accion(() async {
        await widget.deps.reservaRepository.bloquearMesa(
          mesa: mesa,
          franja: _franja,
          motivo: motivo,
          admin: widget.perfil,
        );
        return '${mesa.nombre} bloqueada en ${_franja.etiqueta}';
      });
      return;
    }

    if (!mounted) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Desbloquear ${mesa.nombre}',
      message: 'Motivo del bloqueo: ${ocupacion.motivo ?? '-'}',
      confirmLabel: 'Desbloquear',
    );
    if (!ok) return;
    await _accion(() async {
      await widget.deps.reservaRepository.desbloquearMesa(ocupacion);
      return '${mesa.nombre} disponible de nuevo';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Mesa>>(
      future: _futureMesas,
      builder: (context, mesasSnap) {
        if (mesasSnap.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Cargando mesas...');
        }
        if (mesasSnap.hasError) {
          return ErrorView(
            message: 'No pudimos cargar el catalogo de mesas',
            detail: mesasSnap.error.toString(),
            onRetry: _reintentar,
          );
        }
        final mesas = mesasSnap.data ?? [];

        return StreamBuilder<List<Reserva>>(
          stream: _reservas,
          builder: (context, reservasSnap) {
            return StreamBuilder<List<Ocupacion>>(
              stream: _ocupacion,
              builder: (context, ocupacionSnap) {
                final error = reservasSnap.error ?? ocupacionSnap.error;
                if (error != null) {
                  AppLogger.warning('Tablero de asignacion sin datos', error: error);
                  return ErrorView(
                    message: 'No se pudo leer el tablero. Revisa tu conexion.',
                    onRetry: _reintentar,
                  );
                }
                if (!reservasSnap.hasData || !ocupacionSnap.hasData) {
                  return const LoadingView();
                }
                return _buildTablero(mesas, reservasSnap.data!, ocupacionSnap.data!);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTablero(
    List<Mesa> mesas,
    List<Reserva> reservasDia,
    List<Ocupacion> ocupacionDia,
  ) {
    final colors = Theme.of(context).colorScheme;
    final franjas = Franja.delDia(_dia);
    final pendientesPorFranja = <String, int>{};
    for (final r in reservasDia.where((r) => r.estado == EstadoReserva.solicitada)) {
      pendientesPorFranja.update(r.franjaId, (n) => n + 1, ifAbsent: () => 1);
    }

    final enFranja = reservasDia.where((r) => r.franjaId == _franja.id).toList();
    final pendientes = enFranja.where((r) => r.estado == EstadoReserva.solicitada).toList();
    final otras = enFranja.where((r) => r.estado != EstadoReserva.solicitada).toList();

    final ocupacionFranja = {
      for (final o in ocupacionDia.where((o) => o.franjaId == _franja.id)) o.mesaId: o,
    };
    final reservasPorId = {for (final r in reservasDia) r.id: r};

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Dia
            Row(
              children: [
                IconButton(
                  tooltip: 'Dia anterior',
                  onPressed: () => _seleccionarDia(_dia.subtract(const Duration(days: 1))),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _elegirDia,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(Formatters.dia(_dia), style: const TextStyle(fontSize: 18)),
                  ),
                ),
                IconButton(
                  tooltip: 'Dia siguiente',
                  onPressed: () => _seleccionarDia(_dia.add(const Duration(days: 1))),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Franjas
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: franjas.map((f) {
                  final n = pendientesPorFranja[f.id] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(n > 0 ? '${f.etiqueta}  ($n)' : f.etiqueta),
                      selected: f == _franja,
                      onSelected: (_) => setState(() => _franja = f),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Pendientes
            _Seccion('Solicitudes pendientes (${pendientes.length})'),
            if (pendientes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: EmptyView(
                  message: 'No hay solicitudes pendientes en esta franja',
                  icon: Icons.inbox_outlined,
                ),
              )
            else
              ...pendientes.map(
                (r) => ReservaCard(
                  reserva: r,
                  mostrarCliente: true,
                  acciones: [
                    FilledButton.tonalIcon(
                      onPressed: _ocupado
                          ? null
                          : () => _asignar(r, mesas, ocupacionFranja.keys.toSet()),
                      icon: const Icon(Icons.table_restaurant_outlined),
                      label: const Text('Asignar mesa'),
                    ),
                    TextButton.icon(
                      onPressed: _ocupado ? null : () => _rechazar(r),
                      style: TextButton.styleFrom(foregroundColor: colors.error),
                      icon: const Icon(Icons.block),
                      label: const Text('Rechazar'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Mesas
            _Seccion('Mesas en ${_franja.etiqueta}'),
            Text(
              'Toca una mesa libre para bloquearla, o una bloqueada para liberarla.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: mesas.map((m) {
                final ocupacion = ocupacionFranja[m.id];
                return _MesaTile(
                  mesa: m,
                  ocupacion: ocupacion,
                  reserva: reservasPorId[ocupacion?.reservaId],
                  onTap: _ocupado ? null : () => _tocarMesa(m, ocupacion),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Historial de la franja
            if (otras.isNotEmpty) ...[
              _Seccion('Otras reservas de la franja'),
              ...otras.map((r) => ReservaCard(reserva: r, mostrarCliente: true)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String text;
  const _Seccion(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MesaTile extends StatelessWidget {
  final Mesa mesa;
  final Ocupacion? ocupacion;
  final Reserva? reserva;
  final VoidCallback? onTap;

  const _MesaTile({
    required this.mesa,
    required this.ocupacion,
    required this.reserva,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final (Color fondo, IconData icono, String estado) = switch (ocupacion?.tipo) {
      null => (
        dark ? Colors.green.shade900 : Colors.green.shade50,
        Icons.check_circle_outline,
        'Libre',
      ),
      TipoOcupacion.bloqueo => (
        dark ? Colors.grey.shade800 : Colors.grey.shade300,
        Icons.lock_outline,
        'Bloqueada',
      ),
      TipoOcupacion.reserva => (
        dark ? Colors.blue.shade900 : Colors.blue.shade50,
        Icons.event_seat,
        reserva == null
            ? 'Reservada'
            : '${reserva!.estado.label} · ${reserva!.clienteNombre}',
      ),
    };

    return SizedBox(
      width: 160,
      child: Material(
        color: fondo,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icono, size: 18, color: colors.onSurface),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        mesa.id,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text('${mesa.capacidad} p'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(mesa.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  ocupacion?.tipo == TipoOcupacion.bloqueo && ocupacion?.motivo != null
                      ? '$estado: ${ocupacion!.motivo}'
                      : estado,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
