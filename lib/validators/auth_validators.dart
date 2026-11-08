class AuthValidators {
  AuthValidators._();

  static const int minPassword = 6;
  static const int maxNombre = 80;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validateNombre(String? value) {
    final nombre = value?.trim() ?? '';
    if (nombre.isEmpty) return 'Escribe tu nombre';
    if (nombre.length > maxNombre) return 'Maximo $maxNombre caracteres';
    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Escribe tu correo';
    if (!_emailRegex.hasMatch(email)) return 'El correo no es valido';
    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Escribe tu contrasena';
    if (password.length < minPassword) return 'Minimo $minPassword caracteres';
    return null;
  }
}
