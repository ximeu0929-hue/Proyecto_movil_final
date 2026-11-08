import 'dart:async';

import 'package:final_movil/services/mesa_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

MesaService _servicio(Future<http.Response> Function(http.Request) handler) =>
    MesaService('https://ejemplo.test/mesas.json', client: MockClient(handler));

void main() {
  test('HTTP 200 se transforma en modelos Mesa', () async {
    final service = _servicio(
      (_) async => http.Response(
        '[{"id":"M01","nombre":"Mesa 1","capacidad":2,"ubicacion":"Ventana","caracteristicas":["Luz"]}]',
        200,
      ),
    );

    final mesas = await service.getMesas();
    expect(mesas, hasLength(1));
    expect(mesas.first.capacidad, 2);
    expect(mesas.first.caracteristicas, ['Luz']);
  });

  test('lista vacia no es error', () async {
    final service = _servicio((_) async => http.Response('[]', 200));
    expect(await service.getMesas(), isEmpty);
  });

  test('404 da un mensaje claro', () async {
    final service = _servicio((_) async => http.Response('no', 404));
    expect(
      service.getMesas(),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('No se encontro'))),
    );
  });

  test('500 indica servidor no disponible', () async {
    final service = _servicio((_) async => http.Response('boom', 500));
    expect(
      service.getMesas(),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('no esta disponible'))),
    );
  });

  test('JSON invalido no se muestra como traza', () async {
    final service = _servicio((_) async => http.Response('{"error": ', 200));
    expect(
      service.getMesas(),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('formato'))),
    );
  });

  test('sin conexion se informa como ApiException', () async {
    final service = _servicio((_) async => throw http.ClientException('sin red'));
    expect(
      service.getMesas(),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('conexion'))),
    );
  });

  test('timeout se informa como ApiException', () async {
    final service = _servicio((_) async => throw TimeoutException('lento'));
    expect(
      service.getMesas(),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('tardo'))),
    );
  });
}
