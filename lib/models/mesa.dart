class Mesa {
  final String id;
  final String nombre;
  final int capacidad;
  final String ubicacion;
  final List<String> caracteristicas;

  const Mesa({
    required this.id,
    required this.nombre,
    required this.capacidad,
    required this.ubicacion,
    required this.caracteristicas,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nombre = json['nombre'];
    final capacidad = json['capacidad'];

    if (id == null || nombre is! String || capacidad is! num) {
      throw const FormatException('Mesa con campos incompletos');
    }

    return Mesa(
      id: id.toString(),
      nombre: nombre,
      capacidad: capacidad.toInt(),
      ubicacion: json['ubicacion'] as String? ?? 'Salon',
      caracteristicas: (json['caracteristicas'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'capacidad': capacidad,
    'ubicacion': ubicacion,
    'caracteristicas': caracteristicas,
  };
}
