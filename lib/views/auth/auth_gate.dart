import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/app_dependencies.dart';
import '../../models/perfil.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../home_shell.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  final AppDependencies deps;

  const AuthGate({super.key, required this.deps});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<User?> _sub;
  User? _user;
  bool _iniciando = true;
  Future<Perfil>? _perfil;

  @override
  void initState() {
    super.initState();
    _user = widget.deps.authService.currentUser;
    if (_user != null) _perfil = _cargarPerfil(_user!);

    _sub = widget.deps.authService.authStateChanges().listen((user) {
      if (!mounted) return;
      final cambioDeCuenta = user?.uid != _user?.uid;
      setState(() {
        _iniciando = false;
        if (!cambioDeCuenta) return;
        _user = user;
        _perfil = user == null ? null : _cargarPerfil(user);
      });
      if (cambioDeCuenta && user == null) {
        unawaited(widget.deps.crashService.setUserIdentifier(''));
      }
    });
  }

  Future<Perfil> _cargarPerfil(User user) {
    unawaited(widget.deps.crashService.setUserIdentifier(user.uid));
    return widget.deps.authService.loadPerfil(user);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _reintentarPerfil() {
    final user = _user;
    if (user == null) return;
    final perfil = _cargarPerfil(user);
    setState(() {
      _perfil = perfil;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      if (_iniciando) return const Scaffold(body: LoadingView());
      return LoginPage(authService: widget.deps.authService);
    }

    return FutureBuilder<Perfil>(
      key: ValueKey(user.uid),
      future: _perfil,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: LoadingView(message: 'Cargando tu perfil...'));
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ErrorView(
                      message: 'No se pudo cargar tu perfil',
                      detail: snapshot.error.toString(),
                      onRetry: _reintentarPerfil,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.deps.authService.logout,
                    child: const Text('Cerrar sesion'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }

        return HomeShell(
          key: ValueKey('home-${user.uid}'),
          perfil: snapshot.data!,
          deps: widget.deps,
        );
      },
    );
  }
}
