import 'package:final_movil/models/perfil.dart';
import 'package:final_movil/services/auth_service.dart';
import 'package:final_movil/views/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthService implements AuthService {
  int llamadas = 0;

  @override
  Stream<User?> authStateChanges() => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<Perfil> login({required String email, required String password}) async {
    llamadas++;
    throw const AuthException('Correo o contrasena incorrectos.');
  }

  @override
  Future<Perfil> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    llamadas++;
    throw const AuthException('Ya existe una cuenta con ese correo.');
  }

  @override
  Future<Perfil> loadPerfil(User user) => throw UnimplementedError();

  @override
  Future<void> logout() async {}
}

void main() {
  late FakeAuthService auth;

  setUp(() => auth = FakeAuthService());

  Future<void> abrirLogin(WidgetTester tester) {
    return tester.pumpWidget(MaterialApp(home: LoginPage(authService: auth)));
  }

  testWidgets('muestra errores con el formulario vacio sin llamar al servicio', (tester) async {
    await abrirLogin(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesion'));
    await tester.pump();

    expect(find.text('Escribe tu correo'), findsOneWidget);
    expect(find.text('Escribe tu contrasena'), findsOneWidget);
    expect(auth.llamadas, 0);
  });

  testWidgets('muestra el mensaje del servicio cuando las credenciales fallan', (tester) async {
    await abrirLogin(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'cliente@g62reservas.test');
    await tester.enterText(find.byType(TextFormField).at(1), 'clave-mala');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesion'));
    await tester.pump();

    expect(auth.llamadas, 1);
    expect(find.text('Correo o contrasena incorrectos.'), findsOneWidget);
  });

  testWidgets('el modo registro pide el nombre', (tester) async {
    await abrirLogin(tester);

    await tester.tap(find.text('No tengo cuenta: registrarme'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pump();

    expect(find.text('Escribe tu nombre'), findsOneWidget);
    expect(auth.llamadas, 0);
  });
}
