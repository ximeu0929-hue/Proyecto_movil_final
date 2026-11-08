import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/app_dependencies.dart';
import '../../core/app_logger.dart';
import '../../core/formatters.dart';
import '../../core/hora_restaurante.dart';
import '../../domain/reserva_exception.dart';
import '../../models/franja.dart';
import '../../models/perfil.dart';
import '../../models/reserva.dart';
import '../../repositories/reserva_repository.dart';
import '../../widgets/dialogs.dart';

class NuevaReservaScreen extends StatefulWidget {
  final AppDependencies deps;
  final Perfil perfil;
  final int? personasIniciales;
  final Reserva? reservaACorregir;

  const NuevaReservaScreen({
    super.key,
    required this.deps,
    required this.perfil,
    this.personasIniciales,
    this.reservaACorregir,
  });

  @override
  State<NuevaReservaScreen> createState() => _NuevaReservaScreenState();
}

class _NuevaReservaScreenState extends State<NuevaReservaScreen> {
  final _comentario = TextEditingController();
  late DateTime _dia;
  Franja? _franja;
  late int _personas;
  bool _enviando = false;

  bool get _corrigiendo => widget.reservaACorregir != null;

  @override
  void initState() {
    super.initState();
    final previa = widget.reservaACorregir;
    _personas = previa?.personas ?? widget.personasIniciales ?? 2;
    _comentario.text = previa?.comentario ?? '';

    if (previa != null && previa.inicio.isAfter(DateTime.now())) {
      _dia = HoraRestaurante.fechaDe(previa.inicio);
      _franja = previa.franja;
    } else {
      _dia = HoraRestaurante.hoy();
      // si ya no hay franjas hoy, manana
      if (_franjasDisponibles(_dia).isEmpty) _dia = _dia.add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  List<Franja> _franjasDisponibles(DateTime dia) {
    final ahora = DateTime.now();
    return Franja.delDia(dia).where((f) => f.inicio.isAfter(ahora)).toList();
  }

  Future<void> _elegirDia() async {
    final hoy = HoraRestaurante.hoy();
    final elegido = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: AppConstants.diasReservables)),
      helpText: 'Dia de la reserva',
    );
    if (elegido == null || !mounted) return;
    setState(() {
      _dia = elegido;
      if (_franja != null && !Formatters.mismoDia(HoraRestaurante.fechaDe(_franja!.inicio), elegido)) {
        _franja = null;
      }
    });
  }

  Future<void> _enviar() async {
    if (_enviando) return;
    final franja = _franja;
    if (franja == null) {
      showResultSnack(context, 'Elige una franja horaria', error: true);
      return;
    }

    setState(() => _enviando = true);

    try {
      final repo = widget.deps.reservaRepository;
      final (_, resultado) = _corrigiendo
          ? await repo.corregirSolicitud(
              reserva: widget.reservaACorregir!,
              personas: _personas,
              inicio: franja.inicio,
              comentario: _comentario.text,
            )
          : await repo.solicitarReserva(
              cliente: widget.perfil,
              personas: _personas,
              inicio: franja.inicio,
              comentario: _comentario.text,
            );

      if (!mounted) return;
      final mensaje = switch (resultado) {
        ResultadoEnvio.sincronizada =>
          'Solicitud enviada. Queda SOLICITADA hasta que el salon asigne una mesa.',
        ResultadoEnvio.pendiente =>
          'Guardada en el telefono. Se enviara cuando haya conexion.',
        ResultadoEnvio.rechazada =>
          'El servidor rechazo la solicitud. Revisala en Mis reservas.',
      };
      showResultSnack(context, mensaje, error: resultado == ResultadoEnvio.rechazada);
      Navigator.pop(context);
    } on ReservaException catch (e) {
      if (!mounted) return;
      showResultSnack(context, e.message, error: true);
    } catch (e, st) {
      AppLogger.error('Error inesperado al solicitar reserva', error: e, stackTrace: st);
      if (!mounted) return;
      showResultSnack(context, 'No se pudo guardar la solicitud.', error: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final franjas = _franjasDisponibles(_dia);

    return Scaffold(
      appBar: AppBar(
        title: Text(_corrigiendo ? 'Corregir solicitud' : 'Solicitar reserva'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_corrigiendo && widget.reservaACorregir!.lastError != null)
                  Card(
                    color: colors.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Motivo del rechazo: ${widget.reservaACorregir!.lastError}',
                        style: TextStyle(color: colors.onErrorContainer),
                      ),
                    ),
                  ),
                _Titulo('Personas'),
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Menos personas',
                      onPressed: _personas > AppConstants.minPersonas
                          ? () => setState(() => _personas--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Expanded(
                      child: Text(
                        '$_personas',
                        textAlign: TextAlign.center,
                        semanticsLabel: '$_personas personas',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Mas personas',
                      onPressed: _personas < AppConstants.maxPersonas
                          ? () => setState(() => _personas++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                Text(
                  'De 1 a 8 personas por reserva.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                _Titulo('Dia'),
                OutlinedButton.icon(
                  onPressed: _elegirDia,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(Formatters.dia(_dia)),
                ),
                const SizedBox(height: 24),
                _Titulo('Franja (90 minutos)'),
                if (franjas.isEmpty)
                  Text(
                    'No quedan franjas para este dia. Elige otro.',
                    style: TextStyle(color: colors.error),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: franjas
                        .map(
                          (f) => ChoiceChip(
                            label: Text(f.etiqueta),
                            selected: _franja == f,
                            onSelected: (_) => setState(() => _franja = f),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 24),
                _Titulo('Comentario (opcional)'),
                TextField(
                  controller: _comentario,
                  maxLength: 200,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Ej: cumpleanos, silla para bebe',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _enviando ? null : _enviar,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  icon: _enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(_corrigiendo ? 'Guardar y reenviar' : 'Enviar solicitud'),
                ),
                const SizedBox(height: 8),
                Text(
                  'La solicitud se guarda primero en el telefono. La mesa se asigna '
                  'solo cuando el salon la confirma con conexion.',
                  textAlign: TextAlign.center,
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

class _Titulo extends StatelessWidget {
  final String text;
  const _Titulo(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
