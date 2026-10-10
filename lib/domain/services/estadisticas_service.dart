import 'dart:math' as math;

import '../entities/estadisticas_sueno.dart';
import '../entities/registro_sueno.dart';

class EstadisticasService {
  const EstadisticasService();

  EstadisticasSueno calcular(
    List<RegistroSueno> registros, {
    required int dias,
    required double metaHoras,
    DateTime? fechaReferencia,
  }) {
    final ahora = fechaReferencia ?? DateTime.now();
    final limite = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
    ).subtract(Duration(days: dias - 1));
    final finDia = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
    ).add(const Duration(days: 1));
    final seleccion =
        registros
            .where(
              (r) => !r.inicio.isBefore(limite) && r.inicio.isBefore(finDia),
            )
            .toList()
          ..sort((a, b) => a.inicio.compareTo(b.inicio));
    if (seleccion.isEmpty) return EstadisticasSueno.vacia();

    final duraciones = seleccion
        .map((r) => r.duracion.inMinutes / 60)
        .toList(growable: false);
    final horarios = seleccion
        .map((r) {
          final hora = r.inicio.hour + r.inicio.minute / 60;
          return hora < 12 ? hora + 24 : hora;
        })
        .toList(growable: false);
    final promedio = duraciones.reduce((a, b) => a + b) / duraciones.length;
    final mediaHorario = horarios.reduce((a, b) => a + b) / horarios.length;
    final varianzaHorario =
        horarios
            .map((hora) => (hora - mediaHorario) * (hora - mediaHorario))
            .reduce((a, b) => a + b) /
        horarios.length;
    final labels = seleccion
        .map((r) => '${r.inicio.day}/${r.inicio.month}')
        .toList();
    return EstadisticasSueno(
      promedioHoras: promedio,
      promedioCalidad:
          seleccion.map((r) => r.calidad).reduce((a, b) => a + b) /
          seleccion.length,
      promedioInicio: mediaHorario >= 24 ? mediaHorario - 24 : mediaHorario,
      consistenciaHorario: math.sqrt(varianzaHorario),
      mejorHoras: duraciones.reduce((a, b) => a > b ? a : b),
      peorHoras: duraciones.reduce((a, b) => a < b ? a : b),
      deudaHoras:
          duraciones.fold<double>(
            0,
            (deuda, horas) => deuda + (metaHoras - horas).clamp(0, metaHoras),
          ) /
          seleccion.length,
      etiquetas: labels,
      horasPorNoche: duraciones,
      calidadPorNoche: seleccion.map((r) => r.calidad.toDouble()).toList(),
    );
  }
}
