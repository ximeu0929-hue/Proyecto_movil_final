import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_dependencies.dart';
import '../core/app_logger.dart';
import '../models/perfil.dart';
import '../models/rol.dart';
import '../widgets/dialogs.dart';
import '../widgets/offline_banner.dart';
import 'admin/tablero_asignacion_screen.dart';
import 'anfitrion/tablero_recepcion_screen.dart';
import 'cliente/mesas_screen.dart';
import 'cliente/mis_reservas_screen.dart';

class HomeShell extends StatefulWidget {
  final Perfil perfil;
  final AppDependencies deps;

  const HomeShell({super.key, required this.perfil, required this.deps});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _Destino {
  final String titulo;
  final IconData icono;
  final IconData iconoActivo;
  final Widget pantalla;

  const _Destino(this.titulo, this.icono, this.iconoActivo, this.pantalla);
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final List<_Destino> _destinos;

  bool get _esCliente => widget.perfil.rol == Rol.cliente;

  @override
  void initState() {
    super.initState();
    _destinos = _destinosPara(widget.perfil);

    if (_esCliente) {
      unawaited(widget.deps.syncService.start(widget.perfil.uid));
      widget.deps.reservaRepository.iniciarEscuchaCliente(widget.perfil.uid);
    }
  }

  @override
  void dispose() {
    unawaited(widget.deps.syncService.stop());
    widget.deps.reservaRepository.detenerEscuchaCliente();
    super.dispose();
  }

  List<_Destino> _destinosPara(Perfil perfil) {
    final deps = widget.deps;
    final mesas = _Destino(
      'Mesas',
      Icons.table_restaurant_outlined,
      Icons.table_restaurant,
      MesasScreen(deps: deps, perfil: perfil),
    );

    switch (perfil.rol) {
      case Rol.cliente:
        return [
          mesas,
          _Destino(
            'Mis reservas',
            Icons.event_note_outlined,
            Icons.event_note,
            MisReservasScreen(deps: deps, perfil: perfil),
          ),
        ];
      case Rol.adminSalon:
        return [
          _Destino(
            'Asignacion',
            Icons.dashboard_outlined,
            Icons.dashboard,
            TableroAsignacionScreen(deps: deps, perfil: perfil),
          ),
          mesas,
        ];
      case Rol.anfitrion:
        return [
          _Destino(
            'Recepcion',
            Icons.room_service_outlined,
            Icons.room_service,
            TableroRecepcionScreen(deps: deps, perfil: perfil),
          ),
          mesas,
        ];
    }
  }

  Future<void> _cerrarSesion() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cerrar sesion',
      message: 'Las solicitudes pendientes quedan guardadas en este telefono '
          'y se enviaran cuando vuelvas a iniciar sesion con esta cuenta.',
      confirmLabel: 'Cerrar sesion',
    );
    if (!ok) return;

    await widget.deps.syncService.stop();
    widget.deps.reservaRepository.detenerEscuchaCliente();
    await widget.deps.authService.logout();
  }

  void _cambiarTema() {
    final actual = widget.deps.themeMode.value;
    final siguiente = actual == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    widget.deps.themeMode.value = siguiente;
    unawaited(widget.deps.preferences.setTema(siguiente));
  }

  Future<void> _eventoPruebaCrashlytics() async {
    if (!kDebugMode) return;
    await widget.deps.crashService.simulateNonFatalError();
    AppLogger.debug('Evento de prueba enviado a Crashlytics');
    if (!mounted) return;
    showResultSnack(context, 'Evento de prueba enviado a Crashlytics');
  }

  Future<void> _crashFatalPrueba() async {
    if (!kDebugMode) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Forzar crash fatal',
      message: 'La app se va a cerrar para probar Crashlytics. '
          'Vuelve a abrirla para que se envie el reporte.',
      confirmLabel: 'Cerrar la app',
    );
    if (!ok) return;
    widget.deps.crashService.simulateFatalCrash();
  }

  @override
  Widget build(BuildContext context) {
    final destino = _destinos[_index];
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(destino.titulo),
            Text(
              '${widget.perfil.nombre} · ${widget.perfil.rol.label}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: esOscuro ? 'Tema claro' : 'Tema oscuro',
            onPressed: _cambiarTema,
            icon: Icon(esOscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'Mas opciones',
            onSelected: (value) {
              if (value == 'salir') unawaited(_cerrarSesion());
              if (value == 'crash') unawaited(_eventoPruebaCrashlytics());
              if (value == 'fatal') unawaited(_crashFatalPrueba());
            },
            itemBuilder: (context) => [
              if (kDebugMode) ...[
                const PopupMenuItem(
                  value: 'crash',
                  child: ListTile(
                    leading: Icon(Icons.bug_report_outlined),
                    title: Text('Evento de prueba Crashlytics'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'fatal',
                  child: ListTile(
                    leading: Icon(Icons.dangerous_outlined),
                    title: Text('Forzar crash fatal'),
                  ),
                ),
              ],
              const PopupMenuItem(
                value: 'salir',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar sesion'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          OfflineBanner(offline: widget.deps.syncService.offline),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: _destinos.map((d) => d.pantalla).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinos
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icono),
                selectedIcon: Icon(d.iconoActivo),
                label: d.titulo,
              ),
            )
            .toList(),
      ),
    );
  }
}
