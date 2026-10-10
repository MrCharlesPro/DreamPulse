class EstadisticasSueno {
  const EstadisticasSueno({
    required this.promedioHoras,
    required this.promedioCalidad,
    required this.promedioInicio,
    required this.consistenciaHorario,
    required this.mejorHoras,
    required this.peorHoras,
    required this.deudaHoras,
    required this.etiquetas,
    required this.horasPorNoche,
    required this.calidadPorNoche,
  });

  final double promedioHoras;
  final double promedioCalidad;
  final double promedioInicio;
  final double consistenciaHorario;
  final double mejorHoras;
  final double peorHoras;
  final double deudaHoras;
  final List<String> etiquetas;
  final List<double> horasPorNoche;
  final List<double> calidadPorNoche;

  factory EstadisticasSueno.vacia() => const EstadisticasSueno(
    promedioHoras: 0,
    promedioCalidad: 0,
    promedioInicio: 0,
    consistenciaHorario: 0,
    mejorHoras: 0,
    peorHoras: 0,
    deudaHoras: 0,
    etiquetas: [],
    horasPorNoche: [],
    calidadPorNoche: [],
  );
}
