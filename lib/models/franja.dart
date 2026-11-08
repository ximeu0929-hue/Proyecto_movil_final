import '../core/app_constants.dart';
import '../core/hora_restaurante.dart';

class Franja {
  static const List<(int, int)> horasInicio = [
    (12, 0),
    (13, 30),
    (15, 0),
    (18, 0),
    (19, 30),
    (21, 0),
  ];

  final DateTime inicio;

  Franja(DateTime inicio) : inicio = _alMinuto(inicio);

  static DateTime _alMinuto(DateTime instante) {
    final p = HoraRestaurante.pared(instante);
    return HoraRestaurante.instante(p.year, p.month, p.day, p.hour, p.minute);
  }

  DateTime get fin => inicio.add(AppConstants.duracionFranja);

  DateTime get _paredInicio => HoraRestaurante.pared(inicio);

  String get dia => diaId(_paredInicio);

  String get id =>
      '${dia.replaceAll('-', '')}-${_dos(_paredInicio.hour)}${_dos(_paredInicio.minute)}';

  String get etiqueta {
    final f = HoraRestaurante.pared(fin);
    return '${_dos(_paredInicio.hour)}:${_dos(_paredInicio.minute)} - ${_dos(f.hour)}:${_dos(f.minute)}';
  }

  static List<Franja> delDia(DateTime fecha) {
    return horasInicio
        .map((h) => Franja(
              HoraRestaurante.instante(fecha.year, fecha.month, fecha.day, h.$1, h.$2),
            ))
        .toList();
  }

  static bool esInicioValido(DateTime inicio) {
    final p = HoraRestaurante.pared(inicio);
    return inicio.second == 0 &&
        inicio.millisecond == 0 &&
        horasInicio.any((h) => h.$1 == p.hour && h.$2 == p.minute);
  }

  static String diaId(DateTime fecha) =>
      '${fecha.year}-${_dos(fecha.month)}-${_dos(fecha.day)}';

  static String _dos(int n) => n.toString().padLeft(2, '0');

  @override
  bool operator ==(Object other) =>
      other is Franja && other.inicio.isAtSameMomentAs(inicio);

  @override
  int get hashCode => inicio.millisecondsSinceEpoch.hashCode;
}
