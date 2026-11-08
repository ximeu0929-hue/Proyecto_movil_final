import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_logger.dart';
import '../models/perfil.dart';
import '../remote/perfil_remote_data_source.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

abstract class AuthService {
  Stream<User?> authStateChanges();

  User? get currentUser;

  Future<Perfil> login({
    required String email,
    required String password,
  });

  Future<Perfil> register({
    required String nombre,
    required String email,
    required String password,
  });

  Future<Perfil> loadPerfil(User user);

  Future<void> logout();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    required this.perfiles,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  final PerfilRemoteDataSource perfiles;

  Completer<Perfil>? _registroEnCurso;

  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<Perfil> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return await loadPerfil(credential.user!);
    } on FirebaseAuthException catch (e) {
      AppLogger.warning('Inicio de sesion rechazado: ${e.code}');
      throw AuthException(mensajeDeCodigo(e.code));
    }
  }

  @override
  Future<Perfil> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final registro = Completer<Perfil>();
    _registroEnCurso = registro;
    registro.future.ignore();

    try {
      final perfil = await _crearCuenta(nombre: nombre, email: email, password: password);
      registro.complete(perfil);
      return perfil;
    } catch (e) {
      registro.completeError(e);
      rethrow;
    } finally {
      _registroEnCurso = null;
    }
  }

  Future<Perfil> _crearCuenta({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(nombre.trim());

      return await perfiles.crearPerfilCliente(
        uid: user.uid,
        email: user.email ?? email.trim(),
        nombre: nombre.trim(),
      );
    } on FirebaseAuthException catch (e) {
      AppLogger.warning('Registro rechazado: ${e.code}');
      throw AuthException(mensajeDeCodigo(e.code));
    } on FirebaseException catch (e) {
      AppLogger.warning('No se pudo crear el perfil: ${e.code}');
      throw const AuthException(
        'La cuenta se creo pero no se pudo guardar el perfil. Inicia sesion de nuevo.',
      );
    } on TimeoutException {
      throw const AuthException('Sin conexion. Revisa tu internet.');
    }
  }

  @override
  Future<Perfil> loadPerfil(User user) async {
    final registro = _registroEnCurso;
    if (registro != null) return registro.future;

    try {
      final perfil = await perfiles.getPerfil(user.uid);
      if (perfil != null) return perfil;

      return await perfiles.crearPerfilCliente(
        uid: user.uid,
        email: user.email ?? '',
        nombre: user.displayName ?? 'Cliente',
      );
    } on TimeoutException {
      throw const AuthException(
        'Sin conexion. No se pudo cargar tu perfil; intenta de nuevo.',
      );
    } on FirebaseException catch (e) {
      AppLogger.warning('No se pudo leer el perfil: ${e.code}');
      throw const AuthException(
        'No se pudo cargar tu perfil. Revisa tu conexion e intenta de nuevo.',
      );
    }
  }

  @override
  Future<void> logout() => _firebaseAuth.signOut();

  static String mensajeDeCodigo(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Correo o contrasena incorrectos.';
      case 'invalid-email':
        return 'El correo no es valido.';
      case 'weak-password':
        return 'La contrasena es muy debil: usa al menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'user-disabled':
        return 'Esta cuenta esta deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
      case 'network-request-failed':
        return 'Sin conexion. Revisa tu internet.';
      case 'operation-not-allowed':
      case 'configuration-not-found':
      case 'CONFIGURATION_NOT_FOUND':
        return 'El inicio con correo no esta habilitado en el proyecto.';
      default:
        return 'No fue posible completar la operacion. Intenta de nuevo.';
    }
  }
}
