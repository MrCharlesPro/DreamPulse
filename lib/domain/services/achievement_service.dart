import '../entities/logro.dart';
import '../entities/registro_sueno.dart';

class AchievementService {
  const AchievementService();

  List<Logro> calcular(List<RegistroSueno> registros, double metaHoras) {
    final ordenados = registros.toList()
      ..sort((a, b) => b.inicio.compareTo(a.inicio));
    var racha = 0;
    DateTime? anterior;
    for (final registro in ordenados) {
      if (registro.duracion.inMinutes / 60 < metaHoras) break;
      if (anterior != null && anterior.difference(registro.inicio).inDays > 1) {
        break;
      }
      racha++;
      anterior = registro.inicio;
    }
    final ochoHoras = registros.any((r) => r.duracion.inMinutes == 480);
    return [
      Logro(
        id: 'racha-7',
        titulo: 'Semana de descanso',
        detalle: 'Cumple tu meta durante 7 noches seguidas.',
        icono: '🔥',
        desbloqueado: racha >= 7,
        progreso: racha.clamp(0, 7),
        objetivo: 7,
      ),
      Logro(
        id: 'primera-semana',
        titulo: 'Primera semana',
        detalle: 'Registra 7 noches de sueño.',
        icono: '🌙',
        desbloqueado: registros.length >= 7,
        progreso: registros.length.clamp(0, 7),
        objetivo: 7,
      ),
      Logro(
        id: 'ocho-perfectas',
        titulo: 'Ocho horas perfectas',
        detalle: 'Registra una noche de exactamente ocho horas.',
        icono: '✨',
        desbloqueado: ochoHoras,
        progreso: ochoHoras ? 1 : 0,
      ),
    ];
  }
}
