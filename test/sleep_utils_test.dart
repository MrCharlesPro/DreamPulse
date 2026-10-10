import 'package:dreampulse/core/utils/sleep_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calcula duración cuando el sueño cruza medianoche', () {
    final inicio = DateTime(2026, 10, 8, 23);
    final fin = DateTime(2026, 10, 9, 7);

    expect(SleepUtils.duracion(inicio, fin), const Duration(hours: 8));
    expect(
      SleepUtils.formatoDuracion(SleepUtils.duracion(inicio, fin)),
      '8h 00m',
    );
  });

  test('normaliza la hora de despertar previa al inicio al día siguiente', () {
    final inicio = DateTime(2026, 10, 8, 23);
    final fin = DateTime(2026, 10, 8, 7);

    expect(SleepUtils.fechaDespertar(inicio, fin), DateTime(2026, 10, 9, 7));
  });
}
