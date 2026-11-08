import 'hora_restaurante.dart';

class Formatters {
  Formatters._();

  static const _dias = ['lun', 'mar', 'mie', 'jue', 'vie', 'sab', 'dom'];
  static const _meses = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  static String _dos(int n) => n.toString().padLeft(2, '0');

  static String dia(DateTime fecha) =>
      '${_dias[fecha.weekday - 1]} ${fecha.day} ${_meses[fecha.month - 1]}';

  static String diaDe(DateTime instante) => dia(HoraRestaurante.fechaDe(instante));

  static String hora(DateTime instante) {
    final p = HoraRestaurante.pared(instante);
    return '${_dos(p.hour)}:${_dos(p.minute)}';
  }

  static String diaHora(DateTime instante) => '${diaDe(instante)} · ${hora(instante)}';

  static bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
