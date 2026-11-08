enum EstadoReserva {
  solicitada('SOLICITADA', 'Solicitada'),
  confirmada('CONFIRMADA', 'Confirmada'),
  enMesa('EN_MESA', 'En mesa'),
  finalizada('FINALIZADA', 'Finalizada'),
  rechazada('RECHAZADA', 'Rechazada'),
  cancelada('CANCELADA', 'Cancelada'),
  ausente('AUSENTE', 'Ausente');

  final String value;
  final String label;

  const EstadoReserva(this.value, this.label);

  bool get isTerminal =>
      this == finalizada ||
      this == rechazada ||
      this == cancelada ||
      this == ausente;

  bool get isActiva => this == solicitada || this == confirmada || this == enMesa;

  static EstadoReserva fromValue(String value) {
    return EstadoReserva.values.firstWhere(
      (estado) => estado.value == value,
      orElse: () => throw FormatException('Estado desconocido: $value'),
    );
  }
}
