import '../entities/resumen_mes_sueno.dart';
import '../entities/registro_sueno.dart';

enum SleepBand { green, lime, amber, orange, red, empty }

class MonthlySleepService {
  const MonthlySleepService();

  static SleepBand bandForHours(double hours, double goal) {
    if (hours <= 0 || goal <= 0) return SleepBand.empty;
    final ratio = hours / goal;
    if (ratio >= 1) return SleepBand.green;
    if (ratio >= .9) return SleepBand.lime;
    if (ratio >= .75) return SleepBand.amber;
    if (ratio >= .6) return SleepBand.orange;
    return SleepBand.red;
  }

  static SleepBand bandForQuality(int quality) {
    if (quality <= 0) return SleepBand.empty;
    return switch (quality) {
      >= 5 => SleepBand.green,
      4 => SleepBand.lime,
      3 => SleepBand.amber,
      2 => SleepBand.orange,
      _ => SleepBand.red,
    };
  }

  ResumenMesSueno resumir({
    required List<RegistroSueno> registros,
    required DateTime mes,
    required double metaHoras,
  }) {
    final cantidadDias = DateTime(mes.year, mes.month + 1, 0).day;
    final porDia = <int, RegistroSueno>{};
    for (final registro in registros) {
      if (registro.inicio.year == mes.year &&
          registro.inicio.month == mes.month) {
        porDia.putIfAbsent(registro.inicio.day, () => registro);
      }
    }
    final noches = List.generate(
      cantidadDias,
      (index) => ResumenDiaSueno(dia: index + 1, registro: porDia[index + 1]),
    );
    final registradas = porDia.values.toList()
      ..sort((a, b) => a.inicio.compareTo(b.inicio));
    final horas = registradas.map((r) => r.duracion.inMinutes / 60).toList();
    return ResumenMesSueno(
      noches: noches,
      promedio: horas.isEmpty
          ? 0
          : horas.reduce((a, b) => a + b) / horas.length,
      nochesVerdes: horas
          .where((h) => bandForHours(h, metaHoras) == SleepBand.green)
          .length,
      nochesRojas: horas
          .where((h) => bandForHours(h, metaHoras) == SleepBand.red)
          .length,
      mejor: registradas.isEmpty
          ? null
          : registradas.reduce((a, b) => a.duracion >= b.duracion ? a : b),
      peor: registradas.isEmpty
          ? null
          : registradas.reduce((a, b) => a.duracion <= b.duracion ? a : b),
    );
  }
}
