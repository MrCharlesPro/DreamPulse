import 'package:dreampulse/domain/entities/registro_sueno.dart';
import 'package:dreampulse/domain/services/estadisticas_service.dart';
import 'package:dreampulse/domain/services/recomendaciones_service.dart';
import 'package:flutter_test/flutter_test.dart';

RegistroSueno noche(DateTime inicio, int duracion, int calidad) =>
    RegistroSueno(
      id: inicio.toIso8601String(),
      inicio: inicio,
      fin: inicio.add(Duration(hours: duracion)),
      calidad: calidad,
      origen: OrigenRegistro.manual,
    );

void main() {
  test('calcula promedio, calidad, mejor noche y deuda del periodo', () {
    final referencia = DateTime(2026, 10, 10, 12);
    final registros = [
      noche(DateTime(2026, 10, 9, 22), 6, 2),
      noche(DateTime(2026, 10, 10, 23), 8, 4),
    ];
    final resultado = const EstadisticasService().calcular(
      registros,
      dias: 7,
      metaHoras: 8,
      fechaReferencia: referencia,
    );

    expect(resultado.promedioHoras, 7);
    expect(resultado.promedioCalidad, 3);
    expect(resultado.mejorHoras, 8);
    expect(resultado.peorHoras, 6);
    expect(resultado.deudaHoras, 1);
    expect(resultado.consistenciaHorario, greaterThan(0));
  });

  test('recomienda más descanso y mejor calidad cuando corresponde', () {
    final registros = [
      noche(DateTime(2026, 10, 9, 23), 5, 1),
      noche(DateTime(2026, 10, 8, 23), 6, 2),
    ];
    final resultado = const RecomendacionesService().generar(
      registros: registros,
      metaHoras: 8,
    );

    expect(
      resultado.map((item) => item.titulo),
      contains('Prioriza un poco más de descanso'),
    );
    expect(
      resultado.map((item) => item.titulo),
      contains('Cuida tu rutina nocturna'),
    );
  });
}
