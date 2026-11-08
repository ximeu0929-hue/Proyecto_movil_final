import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/app_dependencies.dart';
import '../../models/mesa.dart';
import '../../models/perfil.dart';
import '../../models/rol.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import 'nueva_reserva_screen.dart';

class MesasScreen extends StatefulWidget {
  final AppDependencies deps;
  final Perfil perfil;

  const MesasScreen({super.key, required this.deps, required this.perfil});

  @override
  State<MesasScreen> createState() => _MesasScreenState();
}

class _MesasScreenState extends State<MesasScreen> {
  late Future<List<Mesa>> _futureMesas;

  bool get _esCliente => widget.perfil.rol == Rol.cliente;

  @override
  void initState() {
    super.initState();
    _futureMesas = widget.deps.mesaRepository.getMesas();
  }

  void _reintentar() {
    setState(() {
      _futureMesas = widget.deps.mesaRepository.getMesas(forceRefresh: true);
    });
  }

  Future<void> _refrescar() async {
    _reintentar();
    try {
      await _futureMesas;
    } catch (_) {
      return;
    }
  }

  void _solicitar({int? personas}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NuevaReservaScreen(
          deps: widget.deps,
          perfil: widget.perfil,
          personasIniciales: personas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _esCliente
          ? FloatingActionButton.extended(
              onPressed: () => _solicitar(),
              icon: const Icon(Icons.add),
              label: const Text('Solicitar reserva'),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Mesa>>(
      future: _futureMesas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Cargando opciones...');
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: 'No pudimos cargar las mesas',
            detail: snapshot.error.toString(),
            onRetry: _reintentar,
          );
        }

        final mesas = snapshot.data ?? [];
        if (mesas.isEmpty) {
          return const EmptyView(message: 'Todavia no hay mesas disponibles');
        }

        return RefreshIndicator(
          onRefresh: _refrescar,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: mesas.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _Encabezado(total: mesas.length, esCliente: _esCliente);
              final mesa = mesas[index - 1];
              return _MesaCard(
                mesa: mesa,
                onSolicitar: _esCliente
                    ? () => _solicitar(
                        personas: mesa.capacidad.clamp(
                          AppConstants.minPersonas,
                          AppConstants.maxPersonas,
                        ),
                      )
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}

class _Encabezado extends StatelessWidget {
  final int total;
  final bool esCliente;

  const _Encabezado({required this.total, required this.esCliente});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$total mesas en el salon',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            esCliente
                ? 'Franjas de 90 minutos, grupos de 1 a 8 personas. '
                      'El salon asigna la mesa al confirmar tu solicitud.'
                : 'Catalogo de referencia. La ocupacion real se ve en el tablero.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MesaCard extends StatelessWidget {
  final Mesa mesa;
  final VoidCallback? onSolicitar;

  const _MesaCard({required this.mesa, this.onSolicitar});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined, color: colors.onPrimaryContainer, size: 20),
                  Text(
                    '${mesa.capacidad}',
                    semanticsLabel: 'Capacidad ${mesa.capacidad} personas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mesa.nombre,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(mesa.ubicacion, style: TextStyle(color: colors.onSurfaceVariant)),
                  if (mesa.caracteristicas.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: mesa.caracteristicas
                          .map(
                            (c) => Chip(
                              label: Text(c),
                              visualDensity: VisualDensity.compact,
                              side: BorderSide.none,
                              backgroundColor: colors.surfaceContainerHighest,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (onSolicitar != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: onSolicitar,
                      icon: const Icon(Icons.event_available_outlined),
                      label: Text('Solicitar para ${mesa.capacidad.clamp(1, 8)}'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
