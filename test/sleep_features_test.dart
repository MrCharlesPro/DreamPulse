import 'package:dreampulse/domain/entities/etiqueta_sueno.dart';
import 'package:dreampulse/domain/entities/registro_sueno.dart';
import 'package:dreampulse/domain/services/achievement_service.dart';
import 'package:dreampulse/domain/services/sleep_insight_service.dart';
import 'package:flutter_test/flutter_test.dart';

RegistroSueno noche(
  String id,
  DateTime inicio, {
  int horas = 8,
  int calidad = 4,
  bool ejercicio = false,
}) => RegistroSueno(
  id: id,
  inicio: inicio,
  fin: inicio.add(Duration(hours: horas)),
  calidad: calidad,
  origen: OrigenRegistro.manual,
  etiquetas: ejercicio ? const [EtiquetaSueno.ejercicio] : const [],
);

void main() {
  test('el formato Hive anterior carga notas y etiquetas vacías', () {
    final antigua = RegistroSueno.fromMap({
      'id': 'antes',
      'inicio': '2026-04-02T22:00:00.000',
      'fin': '2026-04-03T06:00:00.000',
      'calidad': 4,
      'origen': 'manual',
    });

    expect(antigua.notas, isEmpty);
    expect(antigua.etiquetas, isEmpty);
  });

  test('calcula una racha consecutiva y logros de descanso', () {
    final registros = List.generate(
      7,
      (indice) => noche('$indice', DateTime(2026, 4, 8 - indice, 22)),
    );
    final logros = const AchievementService().calcular(registros, 8);

    expect(logros.first.desbloqueado, isTrue);
    expect(logros.first.progreso, 7);
    expect(logros[1].desbloqueado, isTrue);
    expect(logros[2].desbloqueado, isTrue);
  });

  test('detecta asociaciones repetidas entre etiquetas y calidad', () {
    final registros = [
      noche('e1', DateTime(2026, 4, 8), calidad: 5, ejercicio: true),
      noche('e2', DateTime(2026, 4, 7), calidad: 5, ejercicio: true),
      noche('n1', DateTime(2026, 4, 6), calidad: 2),
      noche('n2', DateTime(2026, 4, 5), calidad: 2),
    ];
    final insights = const SleepInsightService().generar(registros);

    expect(insights, hasLength(1));
    expect(insights.single.titulo, contains('ejercicio'));
    expect(insights.single.detalle, contains('no una causa comprobada'));
  });
}
