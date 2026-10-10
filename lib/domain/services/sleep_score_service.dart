import '../entities/puntaje_sueno.dart';
import '../entities/registro_sueno.dart';

class SleepScoreService {
  const SleepScoreService();

  PuntajeSueno calcular({
    required RegistroSueno registro,
    required double metaHoras,
    required List<RegistroSueno> recientes,
  }) {
    final horas = registro.duracion.inMinutes / 60;
    final duracion = (horas / metaHoras * 40).round().clamp(0, 40);
    final calidad = (registro.calidad / 5 * 35).round().clamp(0, 35);
    final inicios = recientes.map((r) => _horaCircular(r.inicio)).toList();
    final variacion = inicios.isEmpty
        ? 0.0
        : inicios.fold<double>(0, (a, b) => a + b) / inicios.length;
    final desviacion = recientes.isEmpty
        ? 0.0
        : (inicios
                  .map((hora) => hora - variacion)
                  .fold<double>(0, (a, b) => a + b.abs()) /
              inicios.length);
    final regularidad = (25 * (1 - (desviacion / 12).clamp(0, 1)))
        .round()
        .clamp(0, 25);
    return PuntajeSueno(
      total: (duracion + calidad + regularidad).clamp(0, 100),
      duracion: duracion,
      calidad: calidad,
      regularidad: regularidad,
    );
  }

  double _horaCircular(DateTime date) {
    final hora = date.hour + date.minute / 60;
    return hora < 12 ? hora + 24 : hora;
  }
}
