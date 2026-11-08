import 'rol.dart';

class Perfil {
  final String uid;
  final String email;
  final String nombre;
  final Rol rol;

  const Perfil({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.rol,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      uid: json['uid'] as String,
      email: json['email'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      rol: Rol.fromValue(json['rol'] as String?),
    );
  }
}
