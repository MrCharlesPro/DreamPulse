import 'package:flutter/foundation.dart';

import '../../domain/entities/estadisticas_sueno.dart';
import '../../domain/entities/recomendacion.dart';
import '../../domain/entities/registro_sueno.dart';
import '../../domain/services/estadisticas_service.dart';
import '../../domain/services/recomendaciones_service.dart';

class StatsController extends ChangeNotifier {
  StatsController({
    required this._estadisticasService,
    required this._recomendacionesService,
  });

  final EstadisticasService _estadisticasService;
  final RecomendacionesService _recomendacionesService;
  int _dias = 7;

  int get dias => _dias;
  void cambiarRango(int dias) {
    _dias = dias;
    notifyListeners();
  }

  EstadisticasSueno calcular(List<RegistroSueno> registros, double meta) =>
      _estadisticasService.calcular(registros, dias: _dias, metaHoras: meta);

  List<Recomendacion> recomendaciones(
    List<RegistroSueno> registros,
    double meta,
  ) => _recomendacionesService.generar(registros: registros, metaHoras: meta);
}
