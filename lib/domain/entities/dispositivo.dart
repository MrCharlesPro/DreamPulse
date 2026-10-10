enum EstadoDispositivo { desconectado, buscando, conectado, error }

class Dispositivo {
  const Dispositivo({
    required this.id,
    required this.nombre,
    required this.simulado,
    this.conectado = false,
  });

  final String id;
  final String nombre;
  final bool simulado;
  final bool conectado;
}

class NocheDispositivo {
  const NocheDispositivo({
    required this.inicio,
    required this.fin,
    required this.calidad,
  });

  final DateTime inicio;
  final DateTime fin;
  final int calidad;
}
