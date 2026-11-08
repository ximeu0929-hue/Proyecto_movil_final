import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FiltroReservas {
  activas('Activas'),
  historial('Historial'),
  todas('Todas');

  final String label;
  const FiltroReservas(this.label);
}

class PreferencesService {
  static const _kFiltro = 'filtro_mis_reservas';
  static const _kTema = 'tema';

  Future<FiltroReservas> getFiltro() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kFiltro);
    return FiltroReservas.values.firstWhere(
      (f) => f.name == value,
      orElse: () => FiltroReservas.activas,
    );
  }

  Future<void> setFiltro(FiltroReservas filtro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFiltro, filtro.name);
  }

  Future<ThemeMode> getTema() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kTema);
    return ThemeMode.values.firstWhere(
      (t) => t.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setTema(ThemeMode tema) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTema, tema.name);
  }
}
