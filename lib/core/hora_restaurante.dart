class HoraRestaurante {
  HoraRestaurante._();

  static const Duration offset = Duration(hours: -5);

  static DateTime pared(DateTime instante) => instante.toUtc().add(offset);

  static DateTime instante(int year, int month, int day, [int hour = 0, int minute = 0]) =>
      DateTime.utc(year, month, day, hour, minute).subtract(offset);

  static DateTime hoy([DateTime? ahora]) {
    final p = pared(ahora ?? DateTime.now());
    return DateTime(p.year, p.month, p.day);
  }

  static DateTime fechaDe(DateTime instante) {
    final p = pared(instante);
    return DateTime(p.year, p.month, p.day);
  }
}
