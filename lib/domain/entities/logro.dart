class Logro {
  const Logro({
    required this.id,
    required this.titulo,
    required this.detalle,
    required this.icono,
    required this.desbloqueado,
    this.progreso = 0,
    this.objetivo = 1,
  });

  final String id;
  final String titulo;
  final String detalle;
  final String icono;
  final bool desbloqueado;
  final int progreso;
  final int objetivo;
}
