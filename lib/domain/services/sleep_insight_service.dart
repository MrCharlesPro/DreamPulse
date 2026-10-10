import '../entities/etiqueta_sueno.dart';
import '../entities/recomendacion.dart';
import '../entities/registro_sueno.dart';

class SleepInsightService {
  const SleepInsightService();

  List<Recomendacion> generar(List<RegistroSueno> registros) {
    final insights = <Recomendacion>[];
    for (final etiqueta in EtiquetaSueno.values) {
      final conEtiqueta = registros
          .where((r) => r.etiquetas.contains(etiqueta))
          .toList();
      final sinEtiqueta = registros
          .where((r) => !r.etiquetas.contains(etiqueta))
          .toList();
      if (conEtiqueta.length < 2 || sinEtiqueta.length < 2) continue;
      final conCalidad =
          conEtiqueta.map((r) => r.calidad).reduce((a, b) => a + b) /
          conEtiqueta.length;
      final sinCalidad =
          sinEtiqueta.map((r) => r.calidad).reduce((a, b) => a + b) /
          sinEtiqueta.length;
      if ((conCalidad - sinCalidad).abs() < .75) continue;
      final mejor = conCalidad > sinCalidad;
      insights.add(
        Recomendacion(
          titulo: mejor
              ? 'Mejor calidad los días con ${etiqueta.titulo.toLowerCase()}'
              : 'Menor calidad los días con ${etiqueta.titulo.toLowerCase()}',
          detalle:
              'Calidad media ${conCalidad.toStringAsFixed(1)}/5 con etiqueta frente a ${sinCalidad.toStringAsFixed(1)}/5 sin ella. Es una observación de tus registros, no una causa comprobada.',
        ),
      );
    }
    return insights;
  }
}
