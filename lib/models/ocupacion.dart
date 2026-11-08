enum TipoOcupacion {
  reserva('reserva'),
  bloqueo('bloqueo');

  final String value;
  const TipoOcupacion(this.value);

  static TipoOcupacion fromValue(String? value) =>
      value == 'bloqueo' ? TipoOcupacion.bloqueo : TipoOcupacion.reserva;
}

class Ocupacion {
  final String id;
  final String mesaId;
  final String franjaId;
  final String dia;
  final TipoOcupacion tipo;
  final String? reservaId;
  final String? motivo;

  const Ocupacion({
    required this.id,
    required this.mesaId,
    required this.franjaId,
    required this.dia,
    required this.tipo,
    this.reservaId,
    this.motivo,
  });

  factory Ocupacion.fromJson(String id, Map<String, dynamic> json) {
    return Ocupacion(
      id: id,
      mesaId: json['mesaId'] as String,
      franjaId: json['franjaId'] as String,
      dia: json['dia'] as String,
      tipo: TipoOcupacion.fromValue(json['tipo'] as String?),
      reservaId: json['reservaId'] as String?,
      motivo: json['motivo'] as String?,
    );
  }
}
