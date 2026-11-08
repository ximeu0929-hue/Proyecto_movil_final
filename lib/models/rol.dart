enum Rol {
  cliente('cliente', 'Cliente'),
  adminSalon('admin_salon', 'Administrador de salon'),
  anfitrion('anfitrion', 'Anfitrion');

  final String value;
  final String label;

  const Rol(this.value, this.label);

  static Rol fromValue(String? value) {
    return Rol.values.firstWhere(
      (rol) => rol.value == value,
      orElse: () => Rol.cliente,
    );
  }
}
