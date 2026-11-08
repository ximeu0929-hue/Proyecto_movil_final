import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/app_constants.dart';
import '../core/app_logger.dart';
import '../models/mesa.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class MesaService {
  final String baseUrl;
  final http.Client client;

  MesaService(this.baseUrl, {http.Client? client})
    : client = client ?? http.Client();

  Future<List<Mesa>> getMesas() async {
    final http.Response response;

    try {
      AppLogger.debug('Consultando catalogo de mesas');
      response = await client
          .get(Uri.parse(baseUrl))
          .timeout(AppConstants.httpTimeout);
    } on TimeoutException {
      AppLogger.warning('Timeout consultando el catalogo');
      throw const ApiException('El servidor tardo demasiado en responder');
    } on SocketException {
      AppLogger.warning('Sin conexion consultando el catalogo');
      throw const ApiException('No hay conexion. Revisa tu internet');
    } on http.ClientException catch (e) {
      AppLogger.warning('Fallo de red consultando el catalogo', error: e);
      throw const ApiException('No hay conexion. Revisa tu internet');
    }

    if (response.statusCode == 404) {
      throw const ApiException('No se encontro el catalogo de mesas');
    }

    if (response.statusCode >= 500) {
      throw const ApiException('El servidor no esta disponible');
    }

    if (response.statusCode != 200) {
      throw ApiException('Error HTTP ${response.statusCode}');
    }

    try {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final mesas = data
          .map((item) => Mesa.fromJson(item as Map<String, dynamic>))
          .toList();
      AppLogger.debug('Mesas obtenidas: ${mesas.length}');
      return mesas;
    } on FormatException catch (e) {
      AppLogger.warning('JSON del catalogo invalido', error: e);
      throw const ApiException('La respuesta no tiene el formato esperado');
    } on TypeError catch (e) {
      AppLogger.warning('JSON del catalogo con tipos inesperados', error: e);
      throw const ApiException('La respuesta no tiene el formato esperado');
    }
  }
}
