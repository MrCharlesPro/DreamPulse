abstract final class SleepUtils {
  static const _meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  static const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

  static DateTime fechaDespertar(DateTime inicio, DateTime fin) {
    if (!fin.isAfter(inicio)) return fin.add(const Duration(days: 1));
    return fin;
  }

  static Duration duracion(DateTime inicio, DateTime fin) =>
      fechaDespertar(inicio, fin).difference(inicio);

  static String formatoDuracion(Duration duracion) {
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes.remainder(60);
    return '${horas}h ${minutos.toString().padLeft(2, '0')}m';
  }

  static String formatoHoras(double horas) {
    final totalMinutos = (horas * 60).round();
    return '${totalMinutos ~/ 60}h ${(totalMinutos % 60).toString().padLeft(2, '0')}m';
  }

  static String fecha(DateTime valor) =>
      '${valor.day} ${_meses[valor.month - 1]} ${valor.year}';
  static String dia(DateTime valor) => _dias[valor.weekday - 1];
  static String hora(DateTime valor) =>
      '${valor.hour.toString().padLeft(2, '0')}:${valor.minute.toString().padLeft(2, '0')}';
}
