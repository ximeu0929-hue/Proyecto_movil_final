import 'package:final_movil/validators/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators.validateEmail', () {
    test('retorna error si el correo esta vacio', () {
      expect(AuthValidators.validateEmail(''), 'Escribe tu correo');
      expect(AuthValidators.validateEmail('   '), 'Escribe tu correo');
    });

    test('retorna error si el correo no tiene formato valido', () {
      expect(AuthValidators.validateEmail('laura'), 'El correo no es valido');
      expect(AuthValidators.validateEmail('laura@correo'), 'El correo no es valido');
    });

    test('retorna null si el correo es valido', () {
      expect(AuthValidators.validateEmail('cliente@g62reservas.test'), isNull);
      expect(AuthValidators.validateEmail('  cliente@g62reservas.test '), isNull);
    });
  });

  group('AuthValidators.validatePassword', () {
    test('retorna error si la contrasena esta vacia', () {
      expect(AuthValidators.validatePassword(''), 'Escribe tu contrasena');
      expect(AuthValidators.validatePassword(null), 'Escribe tu contrasena');
    });

    test('retorna error si la contrasena es corta', () {
      expect(AuthValidators.validatePassword('123'), 'Minimo 6 caracteres');
    });

    test('retorna null si cumple el minimo', () {
      expect(AuthValidators.validatePassword('123456'), isNull);
    });
  });

  group('AuthValidators.validateNombre', () {
    test('retorna error si el nombre esta vacio o es muy largo', () {
      expect(AuthValidators.validateNombre(''), 'Escribe tu nombre');
      expect(AuthValidators.validateNombre('a' * 81), 'Maximo 80 caracteres');
    });

    test('retorna null si el nombre es valido', () {
      expect(AuthValidators.validateNombre('Laura'), isNull);
    });
  });
}
