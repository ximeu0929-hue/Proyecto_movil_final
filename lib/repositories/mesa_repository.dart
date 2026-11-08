import '../models/mesa.dart';
import '../services/mesa_service.dart';

class MesaRepository {
  final MesaService service;

  MesaRepository({required this.service});

  Future<List<Mesa>>? _enCurso;
  List<Mesa>? _cache;

  Future<List<Mesa>> getMesas({bool forceRefresh = false}) {
    final cache = _cache;
    if (!forceRefresh && cache != null) return Future.value(cache);

    final enCurso = _enCurso;
    if (!forceRefresh && enCurso != null) return enCurso;

    final peticion = _cargar();
    _enCurso = peticion;
    return peticion;
  }

  Future<List<Mesa>> _cargar() async {
    try {
      final mesas = await service.getMesas();
      _cache = mesas;
      return mesas;
    } finally {
      _enCurso = null;
    }
  }
}
