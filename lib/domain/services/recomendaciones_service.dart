import '../entities/recomendacion.dart';
import '../entities/registro_sueno.dart';

class RecomendacionesService {
  const RecomendacionesService();

  List<Recomendacion> generar({
    required List<RegistroSueno> registros,
    required double metaHoras,
  }) {
    if (registros.isEmpty) {
      return const [
        Recomendacion(
          titulo: 'Empieza un diario de sueño',
          detalle: 'Un horario constante facilita entender cómo descansas.',
        ),
      ];
    }
    final recomendaciones = <Recomendacion>[];
    final ultimos = registros.take(7).toList();
    final promedioHoras =
        ultimos.map((r) => r.duracion.inMinutes / 60).reduce((a, b) => a + b) /
        ultimos.length;
    final promedioCalidad =
        ultimos.map((r) => r.calidad).reduce((a, b) => a + b) / ultimos.length;
    if (promedioHoras < metaHoras) {
      recomendaciones.add(
        const Recomendacion(
          titulo: 'Prioriza un poco más de descanso',
          detalle:
              'Tu descanso reciente está por debajo de tu meta. Prueba adelantar la hora de dormir gradualmente.',
        ),
      );
    }
    if (promedioCalidad < 3) {
      recomendaciones.add(
        const Recomendacion(
          titulo: 'Cuida tu rutina nocturna',
          detalle:
              'Una habitación fresca, oscura y tranquila puede favorecer un descanso de mejor calidad.',
        ),
      );
    }
    if (ultimos.length >= 3) {
      final horas = ultimos.map((r) {
        final hora = r.inicio.hour + r.inicio.minute / 60;
        return hora < 12 ? hora + 24 : hora;
      }).toList();
      if (horas.reduce((a, b) => a > b ? a : b) -
              horas.reduce((a, b) => a < b ? a : b) >
          2) {
        recomendaciones.add(
          const Recomendacion(
            titulo: 'Busca un horario más constante',
            detalle:
                'Intenta acostarte a una hora parecida, incluso los fines de semana.',
          ),
        );
      }
    }
    if (recomendaciones.isEmpty) {
      recomendaciones.add(
        const Recomendacion(
          titulo: '¡Vas por buen camino!',
          detalle:
              'Continúa con tu rutina y mantén horarios regulares para cuidar tu descanso.',
        ),
      );
    }
    return recomendaciones;
  }
}
