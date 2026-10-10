import 'package:flutter/foundation.dart';

import '../../domain/entities/estadisticas_sueno.dart';
import '../../domain/entities/resumen_mes_sueno.dart';
import '../../domain/entities/recomendacion.dart';
import '../../domain/entities/registro_sueno.dart';
import '../../domain/entities/logro.dart';
import '../../domain/entities/puntaje_sueno.dart';
import '../../domain/services/achievement_service.dart';
import '../../domain/services/estadisticas_service.dart';
import '../../domain/services/monthly_sleep_service.dart';
import '../../domain/services/recomendaciones_service.dart';
import '../../domain/services/sleep_insight_service.dart';
import '../../domain/services/sleep_score_service.dart';

class StatsController extends ChangeNotifier {
  StatsController({
    required this._estadisticasService,
    required this._recomendacionesService,
    required this._monthlySleepService,
    required this._sleepInsightService,
    required this._sleepScoreService,
    required this._achievementService,
  });

  final EstadisticasService _estadisticasService;
  final RecomendacionesService _recomendacionesService;
  final MonthlySleepService _monthlySleepService;
  final SleepInsightService _sleepInsightService;
  final SleepScoreService _sleepScoreService;
  final AchievementService _achievementService;
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

  ResumenMesSueno resumirMes(
    List<RegistroSueno> registros,
    DateTime mes,
    double meta,
  ) => _monthlySleepService.resumir(
    registros: registros,
    mes: mes,
    metaHoras: meta,
  );

  List<Recomendacion> insights(List<RegistroSueno> registros) =>
      _sleepInsightService.generar(registros);

  PuntajeSueno puntaje(List<RegistroSueno> registros, double meta) {
    if (registros.isEmpty) {
      return const PuntajeSueno(
        total: 0,
        duracion: 0,
        calidad: 0,
        regularidad: 0,
      );
    }
    return _sleepScoreService.calcular(
      registro: registros.first,
      metaHoras: meta,
      recientes: registros.take(7).toList(),
    );
  }

  List<Logro> logros(List<RegistroSueno> registros, double meta) =>
      _achievementService.calcular(registros, meta);
}
