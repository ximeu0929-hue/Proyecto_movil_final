import 'package:final_movil/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los codigos de Firebase Auth se traducen a mensajes claros', () {
    expect(FirebaseAuthService.mensajeDeCodigo('invalid-credential'), 'Correo o contrasena incorrectos.');
    expect(FirebaseAuthService.mensajeDeCodigo('invalid-email'), 'El correo no es valido.');
    expect(FirebaseAuthService.mensajeDeCodigo('weak-password'), contains('debil'));
    expect(FirebaseAuthService.mensajeDeCodigo('email-already-in-use'), contains('Ya existe'));
    expect(FirebaseAuthService.mensajeDeCodigo('network-request-failed'), contains('Sin conexion'));
    expect(FirebaseAuthService.mensajeDeCodigo('configuration-not-found'), contains('no esta habilitado'));
    expect(FirebaseAuthService.mensajeDeCodigo('codigo-raro'), contains('No fue posible'));
  });
}
