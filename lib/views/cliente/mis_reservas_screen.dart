import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_dependencies.dart';
import '../../models/perfil.dart';
import '../../models/reserva.dart';
import '../../services/preferences_service.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/reserva_card.dart';
import 'reserva_detail_page.dart';

class MisReservasScreen extends StatefulWidget {
  final AppDependencies deps;
  final Perfil perfil;

  const MisReservasScreen({super.key, required this.deps, required this.perfil});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  late final Stream<List<Reserva>> _stream;
  FiltroReservas _filtro = FiltroReservas.activas;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _stream = widget.deps.reservaRepository.watchMisReservas(widget.perfil.uid);
    _cargarFiltro();
  }

  Future<void> _cargarFiltro() async {
    final filtro = await widget.deps.preferences.getFiltro();
    if (!mounted) return;
    setState(() => _filtro = filtro);
  }

  void _cambiarFiltro(FiltroReservas filtro) {
    setState(() => _filtro = filtro);
    unawaited(widget.deps.preferences.setFiltro(filtro));
  }

  Future<void> _sincronizar() async {
    if (_sincronizando) return;
    setState(() => _sincronizando = true);

    final (sent, failed) = await widget.deps.syncService.sincronizar();
    if (!mounted) return;
    setState(() => _sincronizando = false);

    final String mensaje;
    if (sent == 0 && failed == 0) {
      mensaje = 'No hay solicitudes pendientes por enviar';
    } else if (failed == 0) {
      mensaje = 'Se enviaron $sent solicitud(es)';
    } else {
      mensaje = 'Enviadas: $sent. Sin enviar: $failed (siguen pendientes)';
    }
    showResultSnack(context, mensaje, error: failed > 0);
  }

  List<Reserva> _aplicarFiltro(List<Reserva> todas) {
    switch (_filtro) {
      case FiltroReservas.activas:
        return todas.where((r) => r.pendingSync || !r.estado.isTerminal).toList();
      case FiltroReservas.historial:
        return todas.where((r) => !r.pendingSync && r.estado.isTerminal).toList();
      case FiltroReservas.todas:
        return todas;
    }
  }

  void _abrir(Reserva reserva) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReservaDetailPage(
          deps: widget.deps,
          perfil: widget.perfil,
          reservaId: reserva.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: StreamBuilder<List<Reserva>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorView(
                message: 'No se pudieron leer tus reservas',
                onRetry: () => setState(() {}),
              );
            }
            if (!snapshot.hasData) return const LoadingView();

            final todas = snapshot.data!;
            final pendientes = todas.where((r) => r.pendingSync && !r.syncConflict).length;
            final visibles = _aplicarFiltro(todas);

            return RefreshIndicator(
              onRefresh: _sincronizar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SegmentedButton<FiltroReservas>(
                    segments: FiltroReservas.values
                        .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                        .toList(),
                    selected: {_filtro},
                    onSelectionChanged: (s) => _cambiarFiltro(s.first),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _sincronizando ? null : _sincronizar,
                    icon: _sincronizando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(
                      pendientes == 0
                          ? 'Sincronizar pendientes'
                          : 'Sincronizar pendientes ($pendientes)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (visibles.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: EmptyView(
                        message: 'No tienes reservas en esta vista',
                        icon: Icons.event_busy_outlined,
                      ),
                    )
                  else
                    ...visibles.map(
                      (r) => ReservaCard(
                        reserva: r,
                        mostrarSync: true,
                        onTap: () => _abrir(r),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
