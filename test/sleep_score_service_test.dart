import 'package:dreampulse/domain/entities/registro_sueno.dart';
import 'package:dreampulse/domain/services/sleep_score_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('una noche ideal obtiene puntaje perfecto', () {
    final registro = RegistroSueno(
      id: 'ideal',
      inicio: DateTime(2026, 4, 2, 22),
      fin: DateTime(2026, 4, 3, 6),
      calidad: 5,
      origen: OrigenRegistro.manual,
    );

    final resultado = const SleepScoreService().calcular(
      registro: registro,
      metaHoras: 8,
      recientes: [registro],
    );

    expect(resultado.total, 100);
    expect(resultado.duracion, 40);
    expect(resultado.calidad, 35);
    expect(resultado.regularidad, 25);
  });
}
